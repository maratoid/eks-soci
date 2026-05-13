package cmd

import (
	"tool/cli"
	"tool/file"
	"encoding/yaml"
	"maratg.com/buildkit/objects"
)

command: dump: $short: "Dump all builder stateful set kubernetes manifests to stdout"
command: dump: $long: """
	Dump all builder stateful set kubernetes manifests to stdout.
	
	Use '-t values=path/to/values.yaml,...' to override default values in 'values/values.cue'
	Use '-t namespace=<namespace>' to override target namespace

	YAML values are unified in order, starting with 'values/values.cue'
	Each value in 'values/values.cue' can only be overridden once.

	For example:
		cue cmd dump -t values=example/values/values.yaml,example/values/other.yaml -t namespace=whoa
	"""
command: dump: {
	read: [
		for f in _valueFilesList {
			file.Read & {
				filename: f
				contents: string
			}
		},
	]

	print: cli.Print & {
		_values: {
			for r in read {
				yaml.Unmarshal(r.contents)
			}
		} & {
			namespace: _namespace
		}
		text: yaml.MarshalStream((objects.#MakeObjects & {values: _values}).objectsList)
	}
}
