@experiment(aliasv2)

package objects

import apps "cue.dev/x/k8s.io/api/apps/v1"

#MakeObjects: {
	let _P = self
	objects: ss: apps.#StatefulSet & {
		spec: replicas: _P.values.replicas
		spec: persistentVolumeClaimRetentionPolicy: whenDeleted: _P.values.deleteRetentionPolicy
		spec: persistentVolumeClaimRetentionPolicy: whenScaled:  _P.values.scaleRetentionPolicy
		spec: selector: matchLabels: {
			"app.kubernetes.io/name": _P.values.baseName
		}
		spec: serviceName:         objects.svc.metadata.name
		spec: podManagementPolicy: "OrderedReady"
		spec: volumeClaimTemplates: [
			{
				metadata: name:    "\(_P.values.baseName)-containerd-root"
				spec: accessModes: _P.values.storageMode
				spec: resources: requests: storage: _P.values.storageSize
			},
		]

		spec: template: metadata: labels: {"app.kubernetes.io/name": _P.values.baseName}
		spec: template: spec: serviceAccountName: objects.sa.metadata.name
		spec: template: spec: nodeSelector: {role: "worker"}
		spec: template: spec: affinity: podAntiAffinity: requiredDuringSchedulingIgnoredDuringExecution: [
			{
				labelSelector: matchLabels: {"app.kubernetes.io/name": _P.values.baseName}
				topologyKey: "kubernetes.io/hostname"
			},
		]
		spec: template: spec: initContainers: [
			{
				name: "qemu"
				args: ["--install", "all"]
				securityContext: privileged:               true
				securityContext: allowPrivilegeEscalation: true
				image: _P.values.qemuImage
				resources: requests: memory: "128Mi"
				resources: requests: cpu:    "500m"
				resources: limits: memory:   "128Mi"
			},
		]
		spec: template: spec: containers: [
			{
				name:  "containerd"
				image: _P.values.buildkitImage
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
				env: [
					{
						name:  "BUILDKIT_HOST"
						value: "unix:///builder/run/buildkit/buildkitd.sock"
					},
					{
						name:  "OTEL_TRACES_EXPORTER"
						value: "none"
					},
				]
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
						subPath:   "containerd.toml"
					},
					{
						name:      "config"
						readOnly:  true
						mountPath: "/etc/soci-snapshotter-grpc/config.toml"
						subPath:   "soci.toml"
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
						name:             "\(_P.values.baseName)-containerd-root"
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
				secret: secretName: _P.values.tlsSecret
			},
		]
	}
}
