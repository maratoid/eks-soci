package buildkit

import apps "cue.dev/x/k8s.io/api/apps/v1"

_baseStatefulSet: apps.#StatefulSet & _values.components.statefulset

#MakeStatefulSet: _baseStatefulSet & {
    spec: selector: matchLabels: {
        "app.kubernetes.io/name": #BaseName
    } 
    spec: serviceName: "\(#BaseName)-\(_values.suffix.service)"
    spec: podManagementPolicy: "OrderedReady"
    spec: volumeClaimTemplates: [
        {
            metadata: name: "\(#BaseName)-containerd-root"
        }
    ]

    spec: template: metadata: labels: { "app.kubernetes.io/name": #BaseName }
    spec: template: spec: serviceAccountName: "\(#BaseName)-\(_values.suffix.serviceaccount)"
    spec: template: spec: nodeSelector: { role: "worker" }
    spec: template: spec: affinity: podAntiAffinity: requiredDuringSchedulingIgnoredDuringExecution: [
        {
            labelSelector: matchLabels: { "app.kubernetes.io/name": #BaseName }
            topologyKey: "kubernetes.io/hostname"
        }
    ]
    spec: template: spec: initContainers: [
        {
            name: "qemu"
            args: ["--install", "all"]
            securityContext: privileged: true
            securityContext: allowPrivilegeEscalation: true
        }
    ]
    spec: template: spec: containers: [
        {
            name: "containerd"
            readinessProbe: exec: command: ["buildctl", "debug", "workers"]
            readinessProbe: initialDelaySeconds: 5
            readinessProbe: periodSeconds: 30
            livenessProbe: exec: command: ["buildctl", "debug", "workers"]
            livenessProbe: initialDelaySeconds: 5
            livenessProbe: periodSeconds: 30
            securityContext: privileged: true
            securityContext: allowPrivilegeEscalation: true
            volumeMounts:[
                {
                    name: "config"
                    readOnly: true
                    mountPath: "/etc/buildkit/buildkitd.toml"
                    subPath: "buildkitd.toml"
                },
                {
                    name: "config"
                    readOnly: true
                    mountPath: "/etc/containerd/config.toml"
                    subPath: "containerd-config.toml"
                },
                {
                    name: "config"
                    readOnly: true
                    mountPath: "/etc/supervisor/supervisord.conf"
                    subPath: "supervisord.conf"
                },
                {
                    name: "certs"
                    readOnly: true
                    mountPath: "/certs"
                },
                {
                    name: "\(#BaseName)-containerd-root"
                    mountPropagation: "Bidirectional"
                    mountPath: "/builder"
                }
            ]
        }
    ]
    spec: template: spec: volumes: [
        {
            name: "config"
            configMap: name: "\(#BaseName)-\(_values.suffix.configmap)"
        },
        {
            name: "certs"
            secret: secretName: "\(#BaseName)-\(_values.suffix.secret)"
        }
    ]
}
