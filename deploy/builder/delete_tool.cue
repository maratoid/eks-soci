package cmd

import (
	"tool/cli"
	"tool/exec"
	"tool/file"
	"encoding/yaml"
	"maratg.com/buildkit/objects"
)

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
