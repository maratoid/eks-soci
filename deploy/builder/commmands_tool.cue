package buildkit

import "encoding/yaml"
import "strings"
import "tool/cli"

command: dump: cli.Print & {
	text: yaml.MarshalStream(_objects)
}

command: ls: cli.Print & {
	let Lines = [
		for x in _objects {
			"\(x.kind)  \t\(x.metadata.name)"
		}
	]
	text: strings.Join(Lines, "\n")
}