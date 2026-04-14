package cmd

import (
	"tool/cli"
	"tool/exec"
)

_certManagerVersion:   string | *"1.20.2"       @tag(version)

command: certmanager: {
	ask: cli.Ask & {
		prompt:   "Install cert-manager-crds and cert-manager v\(_certManagerVersion) (yes/no) ?"
		response: bool
	}

	crds: {
		if ask.response {
			exec.Run & {
				cmd: [
					"kubectl",
					"apply",
					"-f",
					"https://github.com/cert-manager/cert-manager/releases/download/v\(_certManagerVersion)/cert-manager.crds.yaml",
				]
			}
		}
	}

	manager: {
		if ask.response {
			exec.Run & {
				cmd: [
					"kubectl",
					"apply",
					"-f",
					"https://github.com/cert-manager/cert-manager/releases/download/v\(_certManagerVersion)/cert-manager.yaml",
				]
			}
		}
	}

}
