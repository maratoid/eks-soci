package cmd

import (
	"text/tabwriter"
	"tool/cli"
	"tool/exec"
	"strings"
	"list"
	"tool/file"
	"encoding/json"
	"encoding/yaml"
	"maratg.com/buildkit/objects"
)

command: dump: {
	_valueFiles: string @tag(values)
	_valueFilesList: *json.Unmarshal(_valueFiles) | []

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

command: ls: cli.Print & {
	let _computed = objects.#MakeObjects & {values: inputValues}
	let lines = [
		"KIND\tID\tNAME",
		"=====\t=====\t=====",
		for k, v in _computed.objects {
			"\(v.kind)\t\(k)\t\(v.metadata.name)"
		},
	]
	text: tabwriter.Write(strings.Join(lines, "\n"))
}

command: schema: exec.Run & {
	cmd: ["sh", "-c", "cue def ./values -e '#Values' | sed '1,4d; $d; s/\t//'"]
}

command: vals: {
	_valueFiles: string @tag(values)
	_valueFilesList: *json.Unmarshal(_valueFiles) | []

	print: exec.Run & {
		cmd: list.Concat([
			[
				"cue",
				"export",
				"maratg.com/buildkit/values",
				"--path",
				"#Values:",
				"-e",
				"#Values",
				"--out",
				"yaml",
			],
			_valueFilesList,
		])
	}
}

command: dryrun: {

	_valueFiles: string @tag(values)
	_valueFilesList: *json.Unmarshal(_valueFiles) | []

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
		} 
	
		text: yaml.MarshalStream((objects.#MakeObjects & {values: _values}).objectsList)
	}

	kube: exec.Run & {
		cmd: [
			"kubectl",
			"apply",
			"--dry-run=client",
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
