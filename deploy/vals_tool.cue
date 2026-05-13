package cmd

import (
	"tool/exec"
	"list"
	val "maratg.com/buildkit/values"
)

command: vals: $short: "Dump unified builder stateful set values to stdout"
command: vals: $long: """
	Dump unified builder stateful set values to stdout.
	
	Use '-t values=path/to/values.yaml,...' to override default values in 'values/values.cue'
	Use '-t namespace=<namespace>' to override target namespace

	YAML values are unified in order, starting with 'values/values.cue'
	Each value in 'values/values.cue' can only be overridden once.

	For example:
		cue cmd vals -t values=example/values/values.yaml,example/values/other.yaml -t namespace=whoa
	"""
command: vals: {
	print: exec.Run & {
		_ns: {
			if _namespace != _|_  {
				_namespace
			}
			if _namespace == _|_  {
				val.#Values.namespace
			}
		}
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
				"-t",
				"namespace=\(_ns)",
			],
			_valueFilesList,
		])
	}
}
