package values

import core "cue.dev/x/k8s.io/api/core/v1"

#Values: {
	baseName:              string | *"buildkit"
	namespace:             string | *"buildkit" @tag(namespace)
	tlsSecret:             string | *"buildkit-tls"
	replicas:              int & >=0 | *2
	buildKitPort:          int & >0 & <65535 | *1234
	qemuImage:             string | *"tonistiigi/binfmt:qemu-v8.1.5"
	buildkitImage:         string | *"ghcr.io/maratoid/containerd-soci-builder:0.18.1"
	scaleRetentionPolicy:  *"Retain" | "Delete"
	deleteRetentionPolicy: *"Retain" | "Delete"
	storageSize:           string & =~"^([+-]?[0-9.]+)([eEinumkKMGTP]*[-+]?[0-9]*)$" | *"10Gi"
	storageMode: string | [string] | *["ReadWriteOnce"]
	labels: [string]: string | *{}
	annotations: [string]: string | *{}
	qemuResources?: {
		requests?: core.#ResourceList
		limits?:   core.#ResourceList
	}
	buildkitResources?: {
		requests?: core.#ResourceList
		limits?:   core.#ResourceList
	}
}
