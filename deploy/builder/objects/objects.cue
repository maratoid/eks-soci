package objects

import (
	val "maratg.com/buildkit/values"
	
)

#MakeObjects: {
	values: val.#Values

	objects: [ID=_]: {
		_test: ID & =~"^[a-z0-9]+$"
		_name: [
			if ID == "ns" { values.namespace },
			"\(values.baseName)-\(ID)",
			...,
		][0]

		metadata: name:        _name
		if ID != "ns" {
			metadata: namespace:   values.namespace
		}
		metadata: annotations: values.annotations
		metadata: labels: values.labels & {"app.kubernetes.io/name": values.baseName}
		...
	}

	objectsList: [for _, v in objects {v}]
}
