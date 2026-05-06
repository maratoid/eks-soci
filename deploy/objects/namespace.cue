@experiment(aliasv2)

package objects

import core "cue.dev/x/k8s.io/api/core/v1"

#MakeObjects: {
    let _P = self
    objects: ns: core.#Namespace & {
        metadata: annotations: _P.values.annotations & {
            "maratg.com/buildkit/namespace": "true"
        }
    }
}
