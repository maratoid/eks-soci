@experiment(aliasv2)
package objects

import core "cue.dev/x/k8s.io/api/core/v1"

_buildKitLog: {
	info: {
		debug: "false"
		trace: "false"
	}
	debug: {
		debug: "true"
		trace: "false"
	}
	trace: {
		debug: "true"
		trace: "true"
	}
}

_sociLog: {
	info: {
		debug: "false"
	}
	debug: {
		debug: "true"
	}
}

#MakeObjects: {
	let _P = self
	objects: cm: core.#ConfigMap & {
		data: "buildkitd.toml": """
			root = "/builder/buildkit"
			debug = \(_buildKitLog[_P.values.buildkitLogLevel].debug)
			trace = \(_buildKitLog[_P.values.buildkitLogLevel].trace)
			insecure-entitlements = [ "network.host", "security.insecure" ]

			[log]
				format = "json"

			[worker.oci]
				enabled = false

			[cdi]
				disabled = true

			[grpc]
				address = [ "tcp://0.0.0.0:\(_P.values.buildKitPort)" ]
				[grpc.tls]
					cert = "/certs/tls.crt"
					key = "/certs/tls.key"
					ca = "/certs/ca.crt"

			[worker.containerd]
				enabled = true
				address = "/builder/run/containerd/containerd.sock"
				namespace = "buildkit"
				snapshotter = "soci"
				gc = true
				gckeepstorage = "10%"

				[worker.containerd.runtime]
					name = "io.containerd.runc.v2"
					options = { Root = "/builder/run/runc" }

				[[worker.containerd.gcpolicy]]
					all = false
					filters = ["type==source.local", "type==exec.cachemount", "type==source.git.checkout"]
					keepBytes = "10GB"
					keepDuration = "48h"
				[[worker.containerd.gcpolicy]]
					all = false
					keepDuration = "168h"
					keepBytes = "10%"
				[[worker.containerd.gcpolicy]]
					all = false
					keepBytes = "10%"
				[[worker.containerd.gcpolicy]]
					all = true
					keepBytes = "10%"
			"""
		data: "soci.toml": """
			debug = \(_sociLog[_P.values.sociLogLevel].debug)
			resolve_result_entry = 120
			no_prometheus = true

			[directory_cache]
				max_lru_cache_entry = 100
				max_cache_fds = 100

			[fuse]
				log_fuse_operations = false

			[content_store]
				type = "containerd"
				namespace = "buildkit"
				containerd_address = '/builder/run/containerd/containerd.sock'
			
			[pull_modes.soci_v2]
				enable = true

			[pull_modes.parallel_pull_unpack]
				enable = false
				experimental_parallel_pull_as_fallback = true
				max_concurrent_downloads_per_image = 10
				concurrent_download_chunk_size = "16mb"
				max_concurrent_unpacks_per_image = 10
				discard_unpacked_layers = true

			[kubeconfig_keychain]
				enable_keychain = true
				kubeconfig_path = "/builder/kubeconfig"
			"""
		data: "supervisord.conf": """
			[unix_http_server]
			file=/builder/run/supervisord/supervisor.sock

			[supervisord]
			nodaemon=true
			logfile=/dev/stdout
			logfile_maxbytes=0
			logfile_backups=0
			loglevel=info
			user=root

			[rpcinterface:supervisor]
			supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

			[supervisorctl]
			serverurl=unix:///builder/run/supervisord/supervisor.sock

			[program:soci-snapshotter-grpc]
			command=/usr/local/bin/soci-snapshotter-grpc --address /builder/run/soci-snapshotter/soci-snapshotter-grpc.sock --root /builder/soci-snapshotter --config /etc/soci-snapshotter-grpc/config.toml
			stdout_logfile=/dev/stdout
			stdout_logfile_maxbytes=0
			stderr_logfile=/dev/stderr
			stderr_logfile_maxbytes=0
			autorestart=true
			startretries=5
			priority=1

			[program:containerd]
			command=containerd  --log-level \(_P.values.containerdLogLevel)
			stdout_logfile=/dev/stdout
			stdout_logfile_maxbytes=0
			stderr_logfile=/dev/stderr
			stderr_logfile_maxbytes=0
			autorestart=true
			startretries=5
			priority=100

			[program:buildkitd]
			command=buildkitd --addr unix:///builder/run/buildkit/buildkitd.sock
			stdout_logfile=/dev/stdout
			stdout_logfile_maxbytes=0
			stderr_logfile=/dev/stderr
			stderr_logfile_maxbytes=0
			autorestart=true
			startretries=50
			priority=200
			"""
		data: "containerd.toml": """
			version = 3
			root = '/builder/containerd'
			state = '/builder/run/containerd'
			temp = '/builder/tmp'
			disabled_plugins = [
				"io.containerd.grpc.v1.cri",
				"io.containerd.grpc.v1.sandbox-controllers",
				"io.containerd.cri.v1.runtime",
				"io.containerd.podsandbox.controller.v1.podsandbox",
				"io.containerd.cri.v1.images",
				"io.containerd.internal.v1.tracing",
				"io.containerd.nri.v1.nri",
				"io.containerd.snapshotter.v1.blockfile",
				"io.containerd.snapshotter.v1.btrfs",
				"io.containerd.snapshotter.v1.devmapper",
				"io.containerd.snapshotter.v1.zfs",
				"io.containerd.snapshotter.v1.erofs",
				"io.containerd.differ.v1.erofs",
				"io.containerd.tracing.processor.v1.otlp"				
			]
			imports = ['/etc/containerd/conf.d/*.toml']

			[grpc]
				address = "/builder/run/containerd/containerd.sock"
			
			[ttrpc]
				address = "/builder/run/containerd/containerd.sock.ttrpc"

			[proxy_plugins]
				[proxy_plugins.soci]
					type = "snapshot"
					address = "/builder/run/soci-snapshotter/soci-snapshotter-grpc.sock"
					[proxy_plugins.soci.exports]
						root = "/builder/soci-snapshotter"
						enable_remote_snapshot_annotations = "true"
			
			[plugins.'io.containerd.cri.v1.runtime']
				enable_cdi = false
			
			[[plugins."io.containerd.transfer.v1.local".unpack_config]]
				platform = "linux"
				snapshotter = "soci"
			"""
	}

}
