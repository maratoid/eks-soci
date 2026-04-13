package cmd

import (
	"text/tabwriter"
	"tool/cli"
	"tool/exec"
	"strings"
	 "list"
	"encoding/json"
	"maratg.com/buildkit/objects"
)

command: dump: {
	_valueFiles: string @tag(values)
	_valueFilesList: *json.Unmarshal(_valueFiles) | []
    
	// This task executes a shell echo command
    print: exec.Run & {
        cmd: list.Concat([
			[
				"cue",
				"eval", 
				".",
				"--path",
				"inputValues:",
				"-e", 
				"output", 
				"--out",
				"yaml"
			], 
			_valueFilesList
		])
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
