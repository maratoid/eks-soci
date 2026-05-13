package cmd

import (
	"tool/cli"
	"tool/exec"
	"tool/file"
	"encoding/yaml"
	"maratg.com/buildkit/objects"
)

command: dryrun: $short: "Dry-run create builder statefulset in kubernetes cluster"
command: dryrun: $long: """
	Dry-run create builder statefulset in kubernetes cluster.
	
	Use '-t values=path/to/values.yaml,...' to override default values in 'values/values.cue'
	Use '-t namespace=<namespace>' to override target namespace

	YAML values are unified in order, starting with 'values/values.cue'
	Each value in 'values/values.cue' can only be overridden once.

	For example:
		cue cmd dryrun -t values=example/values/values.yaml,example/values/other.yaml -t namespace=whoa
	"""
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
				if obj.kind != "Namespace" {obj}
			},
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
