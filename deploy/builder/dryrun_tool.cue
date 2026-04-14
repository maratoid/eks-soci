package cmd

import (
	"tool/cli"
	"tool/exec"
	"tool/file"
	"encoding/yaml"
	"maratg.com/buildkit/objects"
)

command: dryrun: {
	read: [
		for f in _valueFilesList {
			file.Read & {
				filename: f
				contents: string
			}
		},
	]

	dump: cli.Print & {
		_values: {
			for r in read {
				yaml.Unmarshal(r.contents)
			}
		} & {
			namespace: "default"
		}
	
		text: yaml.MarshalStream([ 
			for obj in (objects.#MakeObjects & {values: _values}).objectsList { 
				if obj.kind != "Namespace" { obj } 
			}
		])

	}

	kube: exec.Run & {
		cmd: [
			"kubectl",
			"apply",
			"--dry-run=server",
			"-f",
			"-",
		]
		stdin:  dump.text
		stdout: string
	}

	print: cli.Print & {
		text: kube.stdout
	}
}
