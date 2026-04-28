package cmd

import (
	"tool/cli"
	"tool/exec"
	"tool/file"
	"encoding/yaml"
	"maratg.com/buildkit/objects"
)

command: delete: $short: "Removes builder statefulset from kubernetes cluster"
command: delete: $long: """
	Removes builder statefulset from kubernetes cluster.
	
	Use '-t values=path/to/values.yaml,...' to override default values in 'values/values.cue'
	Use '-t namespace=<namespace>' to override target namespace

	YAML values are unified in order, starting with 'values/values.cue'
	'-t namespace=<namespace>' takes precedence over values, if set.

	For example:
		cue cmd delete -t values=example/values/values.yaml,example/values/other.yaml -t namespace=whoa
	"""
command: delete: {
	read: [
		for f in _valueFilesList {
			file.Read & {
				filename: f
				contents: string
			}
		},
	]

	dumpNamespace: cli.Print & {
		_values: {
			for r in read {
				yaml.Unmarshal(r.contents)
			}
		} & {
			namespace: _namespace
		}

		text: yaml.MarshalStream([(objects.#MakeObjects & {values: _values}).objects.ns])
	}

	createNs: exec.Run & {
		cmd: [
			"kubectl",
			"apply",
			"-f",
			"-",
		]
		stdin:  dumpNamespace.text
		stdout: string
	}

	printCreateNs: cli.Print & {
		text: createNs.stdout
	}

	dump: cli.Print & {
		$after: [printCreateNs]
		_values: {
			for r in read {
				yaml.Unmarshal(r.contents)
			}
		}

		text: yaml.MarshalStream([
			for obj in (objects.#MakeObjects & {values: _values}).objectsList if obj.kind != "Namespace" {obj},
		])
	}

	kube: exec.Run & {
		cmd: [
			"kubectl",
			"delete",
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
