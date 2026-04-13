package objects

import (
	val "maratg.com/buildkit/values"
	apps "cue.dev/x/k8s.io/api/apps/v1"
	core "cue.dev/x/k8s.io/api/core/v1"
	crd "cue.dev/x/crd/cert-manager.io/v1"
)

#MakeObjects: {
	values: val.#Values

	objects: [ID=_]: {
		_test: ID & =~"^[a-z0-9]+$"
		metadata: name:        "\(values.baseName)-\(ID)"
		metadata: namespace:   values.namespace
		metadata: annotations: values.annotations
		metadata: labels: values.labels & {"app.kubernetes.io/name": values.baseName}
		...
	}

	objects: ss: apps.#StatefulSet & {
		spec: replicas: values.replicas
		spec: persistentVolumeClaimRetentionPolicy: whenDeleted: values.deleteRetentionPolicy
		spec: persistentVolumeClaimRetentionPolicy: whenScaled:  values.scaleRetentionPolicy
		spec: selector: matchLabels: {
			"app.kubernetes.io/name": values.baseName
		}
		spec: serviceName:         objects.svc.metadata.name
		spec: podManagementPolicy: "OrderedReady"
		spec: volumeClaimTemplates: [
			{
				metadata: name:    "\(values.baseName)-containerd-root"
				spec: accessModes: values.storageMode
				spec: resources: requests: storage: values.storageSize
			},
		]

		spec: template: metadata: labels: {"app.kubernetes.io/name": values.baseName}
		spec: template: spec: serviceAccountName: objects.sa.metadata.name
		spec: template: spec: nodeSelector: {role: "worker"}
		spec: template: spec: affinity: podAntiAffinity: requiredDuringSchedulingIgnoredDuringExecution: [
			{
				labelSelector: matchLabels: {"app.kubernetes.io/name": values.baseName}
				topologyKey: "kubernetes.io/hostname"
			},
		]
		spec: template: spec: initContainers: [
			{
				name: "qemu"
				args: ["--install", "all"]
				securityContext: privileged:               true
				securityContext: allowPrivilegeEscalation: true
				image: values.qemuImage
				resources: requests: memory: "128Mi"
				resources: requests: cpu:    "500m"
				resources: limits: memory:   "128Mi"
			},
		]
		spec: template: spec: containers: [
			{
				name:  "containerd"
				image: values.buildkitImage
				resources: requests: memory: "3G"
				resources: requests: cpu:    "1"
				resources: limits: memory:   "3G"
				readinessProbe: exec: command: ["buildctl", "debug", "workers"]
				readinessProbe: initialDelaySeconds: 5
				readinessProbe: periodSeconds:       30
				livenessProbe: exec: command: ["buildctl", "debug", "workers"]
				livenessProbe: initialDelaySeconds:        5
				livenessProbe: periodSeconds:              30
				securityContext: privileged:               true
				securityContext: allowPrivilegeEscalation: true
				volumeMounts: [
					{
						name:      "config"
						readOnly:  true
						mountPath: "/etc/buildkit/buildkitd.toml"
						subPath:   "buildkitd.toml"
					},
					{
						name:      "config"
						readOnly:  true
						mountPath: "/etc/containerd/config.toml"
						subPath:   "containerd-config.toml"
					},
					{
						name:      "config"
						readOnly:  true
						mountPath: "/etc/supervisor/supervisord.conf"
						subPath:   "supervisord.conf"
					},
					{
						name:      "certs"
						readOnly:  true
						mountPath: "/certs"
					},
					{
						name:             "\(values.baseName)-containerd-root"
						mountPropagation: "Bidirectional"
						mountPath:        "/builder"
					},
				]
			},
		]
		spec: template: spec: volumes: [
			{
				name: "config"
				configMap: name: objects.cm.metadata.name
			},
			{
				name: "certs"
				secret: secretName: values.tlsSecret
			},
		]
	}

	objects: svc: core.#Service & {
		spec: type: "ClusterIP"
		spec: selector: {
			"app.kubernetes.io/name": values.baseName
		}
		spec: ports: [{
			port:     values.buildKitPort
			protocol: "TCP"
		}]
	}

	objects: sa: core.#ServiceAccount & {}

	objects: cert: crd.#Certificate & {
		spec: issuerRef: kind: "Issuer"
		spec: issuerRef: name: objects.iss.metadata.name
		spec: secretName: values.tlsSecret
		spec: dnsNames: [
			objects.svc.metadata.name,
			"\(objects.svc.metadata.name).svc",
			"\(objects.svc.metadata.name).svc.\(values.namespace)",
			"\(objects.svc.metadata.name).svc.\(values.namespace).cluster.local",
		]
	}

	objects: iss: crd.#Issuer & {
		spec: selfSigned: {}
	}

	objects: cm: core.#ConfigMap & {
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
		command=buildkitd --addr unix:///run/buildkit/buildkitd.sock --addr tcp://0.0.0.0:\(values.buildKitPort) --tlscacert /certs/ca.crt --tlscert /certs/tls.crt --tlskey /certs/tls.key
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

	objectsList: [for _, v in objects {v}]
}
