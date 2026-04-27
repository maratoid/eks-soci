package cmd

import (
	"tool/cli"
	"tool/exec"
	"tool/os"
)

_iacBinary: string | *"tofu" @tag(tfbin)

command: create: $short: "Create local kubernetes cluster with multipass and k3s."
command: create: $long: """
	Create local kubernetes cluster with multipass terraform provider and k3s.

	Terraform variables are under 'terraform/variables.tf'
	Use 'TF_VAR_variable_name=<value>' to override terraform variables.
	Use '-t tfbin=<binary name>' to override name of terraform binary ('tofu' by default).

	For example:
		'TF_VAR_worker_count=5 cue cmd create -t tfbin=terraform'
	"""
command: create: {
	ask: cli.Ask & {
		prompt:   "Create multipass cluster (yes/no) ?"
		response: bool
	}

	_env: os.Environ & {}

	tfrun: {
		if ask.response {
			exec.Run & {
				cmd: [
					_iacBinary,
					"-chdir=terraform",
					"apply",
					"-auto-approve",
				]
				env: _env.contents
			}
		}
	}
}

command: destroy: $short: "Destroy local multipass and k3s kubernetes cluster."
command: destroy: $long: """
	Destroy local kubernetes cluster created with multipass terraform provider and k3s.

	Terraform variables are under 'terraform/variables.tf'
	Use 'TF_VAR_variable_name=<value>' to override terraform variables.
	Use '-t tfbin=<binary name>' to override name of terraform binary.

	For example:
		'TF_VAR_worker_count=5 cue cmd destroy -t tfbin=tofu'
	"""
command: destroy: {
	ask: cli.Ask & {
		prompt:   "Destroy multipass cluster (yes/no) ?"
		response: bool
	}
	_env: os.Environ & {}

	tfrun: {
		if ask.response {
			exec.Run & {
				cmd: [
					_iacBinary,
					"-chdir=terraform",
					"destroy",
					"-auto-approve",
				]
				env: _env.contents 
			}
		}
	}
}
