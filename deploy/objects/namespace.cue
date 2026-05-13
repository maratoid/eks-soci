package objects

import core "cue.dev/x/k8s.io/api/core/v1"

#MakeObjects: {
    objects: ns: core.#Namespace
}
