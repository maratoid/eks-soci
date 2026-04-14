package cmd

import (
	"strings"
	"tool/cli"
	"text/tabwriter"
	"maratg.com/buildkit/objects"
)

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