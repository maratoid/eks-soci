package objects

import crd "cue.dev/x/crd/cert-manager.io/v1"

#MakeObjects: objects: iss: crd.#Issuer & {
	spec: selfSigned: {}
}
