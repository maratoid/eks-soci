package buildkit

import core "cue.dev/x/k8s.io/api/core/v1"

_baseConfigMap: core.#ConfigMap & _values.components.configmap

#MakeConfigMap: _baseConfigMap & {
    data: "buildkitd.toml": """
    root = "/builder/buildkit"
    debug = false

    [log]
        format = "json"
    [worker.oci]
        enabled = false
    [worker.containerd]
        enabled = true
        namespace = "buildkit"
        gc = true
        gckeepstorage = "10%"
        [[worker.containerd.gcpolicy]]
            all = false
            filters = ["type==source.local", "type==exec.cachemount", "type==source.git.checkout"]
            keepBytes = "10GB"
            keepDuration = "48h"
        [[worker.containerd.gcpolicy]]
            all = false
            keepDuration = "168h"
            keepBytes = "10%"
        [[worker.containerd.gcpolicy]]
            all = false
            keepBytes = "10%"
        [[worker.containerd.gcpolicy]]
            all = true
            keepBytes = "10%"
    """
    data: "supervisord.conf": """
    [unix_http_server]
    file=/run/supervisor.sock

    [supervisord]
    nodaemon=true
    logfile=/dev/stdout
    logfile_maxbytes=0
    logfile_backups=0
    loglevel=info
    user=root

    [rpcinterface:supervisor]
    supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

    [supervisorctl]
    serverurl=unix:///run/supervisor.sock

    [program:containerd]
    command=containerd
    stdout_logfile=/dev/stdout
    stdout_logfile_maxbytes=0
    stderr_logfile=/dev/stderr
    stderr_logfile_maxbytes=0
    autorestart=true
    startretries=5
    priority=100

    [program:buildkitd]
    command=buildkitd --addr unix:///run/buildkit/buildkitd.sock --addr tcp://0.0.0.0:1234 --tlscacert /certs/ca.crt --tlscert /certs/tls.crt --tlskey /certs/tls.key
    stdout_logfile=/dev/stdout
    stdout_logfile_maxbytes=0
    stderr_logfile=/dev/stderr
    stderr_logfile_maxbytes=0
    autorestart=true
    startretries=5
    priority=200
    """
    data: "containerd.toml": """
    root = "/builder/containerd"
    state = "/run/containerd"
    temp = "/tmp"
    version = 2
    disabled_plugins = [
        "io.containerd.grpc.v1.cri",
        "io.containerd.snapshotter.v1.blockfile",
        "io.containerd.snapshotter.v1.btrfs",
        "io.containerd.snapshotter.v1.devmapper",
        "io.containerd.snapshotter.v1.zfs",
        "io.containerd.tracing.processor.v1.otlp"
    ]
    """
}