package buildkit

import core "cue.dev/x/k8s.io/api/core/v1"

_baseServiceAccount: core.#ServiceAccount & _values.components.serviceaccount

#MakeServiceAccount: _baseServiceAccount & {}