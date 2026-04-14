package cmd

import (
	"tool/exec"
	"list"
)

command: vals: {
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
