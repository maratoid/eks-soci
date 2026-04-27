package cmd

import (
	"list"
	"tool/exec"
	"tool/file"
	"tool/os"
	"encoding/yaml"
	"encoding/json"
	"maratg.com/buildkit/objects"
)

#BuilderPlatform: {
	architecture: string
	os: string
}

#BuilderNode: {
	Name: string
	Endpoint: string
	Platforms: [#BuilderPlatform]
	Flags: string | null
	DriverOpts: string | null
	Files: string | null
}

#Builder: {
	Name: string
	Driver: string | *"remote"
	Nodes: [#BuilderNode]
}

command: builders: $short: "Creates local buildx builder configs"
command: builders: $long: """
	Creates local buildx builder configs.

	Use '-t values=path/to/values.yaml,...' if builder stateful set was deployed with '-t values=path/to/values.yaml,...'
	Use '-t namespace=<namespace>' if builder stateful set was deployed with '-t namespace=<namespace>'

	For example:
		cue cmd builders -t values=example/values/values.yaml,example/values/other.yaml -t namespace=whoa
	"""

command: builders: {
	read: [
		for f in _valueFilesList {
			file.Read & {
				filename: f
				contents: string
			}
		},
	]

	getHome: os.Getenv & {
		HOME: string
	}

	mkDir: exec.Run & {
		cmd: [
			"mkdir",
			"-p",
            "\(getHome.HOME)/.docker/buildx/instances",
		]
	}

	createConfs: {
		_values: {
			for r in read {
				yaml.Unmarshal(r.contents)
			}
		}

		_sequence: list.Range(0, (objects.#MakeObjects & {values: _values}).values.replicas, 1)

		_builders: [
			for _, i in _sequence {
				#Builder & {
					Name: "\((objects.#MakeObjects & {values: _values}).values.baseName)-\(i)"
					Nodes: [
						{
							Name: "\((objects.#MakeObjects & {values: _values}).values.baseName)-\(i)"
							Endpoint: "kube-pod://\((objects.#MakeObjects & {values: _values}).values.baseName)-\(i)?namespace=\((objects.#MakeObjects & {values: _values}).values.namespace)"
							Platforms: [
								{
									architecture: "amd64"
									os: "linux"
								}
							]
							Flags: null
							DriverOpts: null
							Files: null
						}
					]
				}
			}
		]

		for i, builder in _builders {
            "builder-\(i)": exec.Run & {
				$after: [mkDir]
				cmd:[
					"sh",
					"-c",
					"""
					cat << EOF > \(getHome.HOME)/.docker/buildx/instances/\((objects.#MakeObjects & {values: _values}).values.baseName)-\(i)
					\(json.Indent(json.Marshal(builder), "", "  "))
					EOF
					"""
				] 
			}
        }
	}
}
