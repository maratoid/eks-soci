package buildkit

import crd "cue.dev/x/crd/cert-manager.io/v1"

_baseIssuer: crd.#Issuer & _values.components.issuer

#MakeIssuer: _baseIssuer & {
    spec: selfSigned: {}
}