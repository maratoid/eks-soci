@experiment(aliasv2)
package objects

import core "cue.dev/x/k8s.io/api/core/v1"

#MakeObjects: {
	let _P = self
	objects: svc: core.#Service & {
		spec: type: "ClusterIP"
		spec: selector: {
			"app.kubernetes.io/name": _P.values.baseName
		}
		spec: ports: [{
			port:     _P.values.buildKitPort
			protocol: "TCP"
		}]
	}
}
