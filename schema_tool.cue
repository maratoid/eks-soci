package cmd

import (
	"tool/exec"
)

command: schema: $short: "Show builder statefulset values schema"
command: schema: $long: """
	Show builder statefulset values schema.

	For example:
		cue cmd schema
	"""
command: schema: exec.Run & {
	cmd: ["sh", "-c", "cue def ./values -e '#Values' | sed '1,4d; $d; s/\t//'"]
}
