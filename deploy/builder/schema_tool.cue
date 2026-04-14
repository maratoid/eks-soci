package cmd

import (
	"tool/exec"
)

command: schema: exec.Run & {
	cmd: ["sh", "-c", "cue def ./values -e '#Values' | sed '1,4d; $d; s/\t//'"]
}
