package buildkit

import crd "cue.dev/x/crd/cert-manager.io/v1"

_baseCertificate: crd.#Certificate & _values.components.certificate

#MakeCertificate: _baseCertificate & {
    spec: issuerRef: kind: "Issuer"
    spec: issuerRef: name: "\(#BaseName)-\(_values.suffix.issuer)"
    spec: secretName: "\(#BaseName)-\(_values.suffix.secret)"
    spec: dnsNames: [
        "\(#BaseName)-\(_values.suffix.service)",
        "\(#BaseName)-\(_values.suffix.service).svc",
        "\(#BaseName)-\(_values.suffix.service).svc.\(#Namespace)",
        "\(#BaseName)-\(_values.suffix.service).svc.\(#Namespace).cluster.local",
    ]
}