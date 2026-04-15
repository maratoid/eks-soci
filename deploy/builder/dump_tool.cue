package cmd

import (
	"tool/cli"
	"tool/file"
	"encoding/yaml"
	"maratg.com/buildkit/objects"
)

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
		}
		text: yaml.MarshalStream((objects.#MakeObjects & {values: _values}).objectsList)
	}
}
