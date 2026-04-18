@experiment(aliasv2)
package objects

import crd "cue.dev/x/crd/cert-manager.io/v1"

#MakeObjects: {
	let _P = self
	objects: cert: crd.#Certificate & {
		spec: issuerRef: kind: "Issuer"
		spec: issuerRef: name: objects.iss.metadata.name
		spec: secretName: _P.values.tlsSecret
		spec: dnsNames: [
			objects.svc.metadata.name,
			"\(objects.svc.metadata.name).svc",
			"\(objects.svc.metadata.name).svc.\(_P.values.namespace)",
			"\(objects.svc.metadata.name).svc.\(_P.values.namespace).cluster.local",
		]
	}
}
