package cmd

import (
	"tool/cli"
	"tool/exec"
)

_certManagerVersion: string | *"1.20.2" @tag(version)


command: certinstall: $short: "Deploys cert manager requirement to kubernetes cluster"
command: certinstall: $long: """
	Deploys cert manager requirement to kubernetes cluster.
	Use '-t version=<cert manager version>' to override default cert manager version

	For example:
		cue cmd certinstall -t version=1.20.0
	"""
command: certinstall: {
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
				$after: [crds]
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

command: certuninstall: $short: "Removes cert manager from kubernetes cluster"
command: certuninstall: $long: """
	Removes cert manager from kubernetes cluster.
	Use '-t version=<cert manager version>' to override default cert manager version

	For example:
		cue cmd certuninstall -t version=1.20.0
	"""
command: certuninstall: {
	ask: cli.Ask & {
		prompt:   "Uninstall cert-manager-crds and cert-manager v\(_certManagerVersion) (yes/no) ?"
		response: bool
	}

	manager: {
		if ask.response {
			exec.Run & {
				cmd: [
					"kubectl",
					"delete",
					"-f",
					"https://github.com/cert-manager/cert-manager/releases/download/v\(_certManagerVersion)/cert-manager.yaml",
				]
			}
		}
	}

	crds: {
		if ask.response {
			exec.Run & {
				$after: [manager]
				cmd: [
					"kubectl",
					"delete",
					"-f",
					"https://github.com/cert-manager/cert-manager/releases/download/v\(_certManagerVersion)/cert-manager.crds.yaml",
				]
			}
		}
	}
}
