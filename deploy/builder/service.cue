package buildkit

import core "cue.dev/x/k8s.io/api/core/v1"

_baseService: core.#Service & _values.components.service

#MakeService: _baseService & {
    spec: type: "ClusterIP"
    spec: selector: {
        "app.kubernetes.io/name": #BaseName
    } 
    spec: ports: [{
        port: 1234
        protocol: "TCP"
    }]
}