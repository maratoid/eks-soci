package cmd

import (
	"strings"
	"tool/cli"
	"text/tabwriter"
	"encoding/yaml"
	"tool/file"
	"maratg.com/buildkit/objects"
)

command: ls: $short: "List all builder statefulset kubernetes objects"
command: ls: $long: """
	List all builder statefulset kubernetes objects.

	For example:
		cue cmd ls
	"""
command: ls: {
	read: [
		for f in _valueFilesList {
			file.Read & {
				filename: f
				contents: string
			} 
		},
	]

	print: cli.Print & {
		let _values = {
			for r in read {
				yaml.Unmarshal(r.contents)
			}
		} & {
			namespace: _namespace
		}
		let lines = [
			"KIND\tID\tNAME",
			"=====\t=====\t=====",
			for k, v in (objects.#MakeObjects & {values: _values}).objects {
				"\(v.kind)\t\(k)\t\(v.metadata.name)"
			},
		]
		text: tabwriter.Write(strings.Join(lines, "\n"))
	}
}
