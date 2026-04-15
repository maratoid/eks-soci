@experiment(aliasv2)
package objects

import core "cue.dev/x/k8s.io/api/core/v1"

#MakeObjects: {
	let _P = self
	objects: cm: core.#ConfigMap & {
		data: "buildkitd.toml": """
			root = "/builder/buildkit"
			debug = false

			[log]
				format = "json"
			[worker.oci]
				enabled = false
			[worker.containerd]
				enabled = true
				namespace = "buildkit"
				snapshotter = "soci"
				gc = true
				gckeepstorage = "10%"
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
			[content_store]
				type = "containerd"
				namespace = "buildkit"
			"""
		data: "supervisord.conf": """
			[unix_http_server]
			file=/run/supervisor.sock

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
			serverurl=unix:///run/supervisor.sock

			[program:soci-snapshotter-grpc]
			command=/usr/local/bin/soci-snapshotter-grpc -log-level \(_P.values.sociLogLevel) -root /builder/soci-snapshotter-grpc -config /etc/soci-snapshotter-grpc/config.toml
			stdout_logfile=/dev/stdout
			stdout_logfile_maxbytes=0
			stderr_logfile=/dev/stderr
			stderr_logfile_maxbytes=0
			autorestart=true
			startretries=5
			priority=1

			[program:containerd]
			command=containerd
			stdout_logfile=/dev/stdout
			stdout_logfile_maxbytes=0
			stderr_logfile=/dev/stderr
			stderr_logfile_maxbytes=0
			autorestart=true
			startretries=5
			priority=100

			[program:buildkitd]
			command=buildkitd --addr unix:///run/buildkit/buildkitd.sock --addr tcp://0.0.0.0:\(_P.values.buildKitPort) --tlscacert /certs/ca.crt --tlscert /certs/tls.crt --tlskey /certs/tls.key
			stdout_logfile=/dev/stdout
			stdout_logfile_maxbytes=0
			stderr_logfile=/dev/stderr
			stderr_logfile_maxbytes=0
			autorestart=true
			startretries=5
			priority=200
			"""
		data: "containerd.toml": """
			version = 3
			root = '/builder/containerd'
			state = '/run/containerd'
			temp = '/tmp'
			disabled_plugins = [
				"io.containerd.cri.v1.runtime",
				"io.containerd.grpc.v1.cri",
				"io.containerd.podsandbox.controller.v1.podsandbox",
				"io.containerd.grpc.v1.sandbox-controllers",
				"io.containerd.snapshotter.v1.blockfile",
				"io.containerd.snapshotter.v1.btrfs",
				"io.containerd.snapshotter.v1.devmapper",
				"io.containerd.snapshotter.v1.zfs",
				"io.containerd.snapshotter.v1.erofs",
				"io.containerd.differ.v1.erofs",
				"io.containerd.tracing.processor.v1.otlp"
			]
			required_plugins = []
			oom_score = 0
			imports = ['/etc/containerd/conf.d/*.toml']

			[grpc]
				address = '/run/containerd/containerd.sock'
				tcp_address = ''
				tcp_tls_ca = ''
				tcp_tls_cert = ''
				tcp_tls_key = ''
				uid = 0
				gid = 0
				max_recv_message_size = 16777216
				max_send_message_size = 16777216
				tcp_tls_common_name = ''

			[ttrpc]
				address = ''
				uid = 0
				gid = 0

			[debug]
				address = ''
				uid = 0
				gid = 0
				level = ''
				format = ''

			[metrics]
				address = ''
				grpc_histogram = false

			[proxy_plugins]
				[proxy_plugins.soci]
					type = "snapshot"
					address = "/run/soci-snapshotter-grpc/soci-snapshotter-grpc.sock"
					[proxy_plugins.soci.exports]
						root = "/var/lib/soci-snapshotter-grpc"

			[plugins]
				[plugins.'io.containerd.cri.v1.images']
					snapshotter = 'soci'
					disable_snapshot_annotations = true
					discard_unpacked_layers = false
					max_concurrent_downloads = 3
					image_pull_progress_timeout = '5m0s'
					image_pull_with_sync_fs = false
					stats_collect_period = 10

					[plugins.'io.containerd.cri.v1.images'.pinned_images]
					sandbox = 'registry.k8s.io/pause:3.10.1'

					[plugins.'io.containerd.cri.v1.images'.registry]
					config_path = ''

					[plugins.'io.containerd.cri.v1.images'.image_decryption]
					key_model = 'node'

				[plugins.'io.containerd.gc.v1.scheduler']
					pause_threshold = 0.02
					deletion_threshold = 0
					mutation_threshold = 100
					schedule_delay = '0s'
					startup_delay = '100ms'

				[plugins.'io.containerd.image-verifier.v1.bindir']
					bin_dir = '/opt/containerd/image-verifier/bin'
					max_verifiers = 10
					per_verifier_timeout = '10s'

				[plugins.'io.containerd.internal.v1.opt']
					path = '/opt/containerd'

				[plugins.'io.containerd.internal.v1.tracing']

				[plugins.'io.containerd.metadata.v1.bolt']
					content_sharing_policy = 'shared'

				[plugins.'io.containerd.monitor.container.v1.restart']
					interval = '10s'

				[plugins.'io.containerd.monitor.task.v1.cgroups']
					no_prometheus = false

				[plugins.'io.containerd.nri.v1.nri']
					disable = false
					socket_path = '/var/run/nri/nri.sock'
					plugin_path = '/opt/nri/plugins'
					plugin_config_path = '/etc/nri/conf.d'
					plugin_registration_timeout = '5s'
					plugin_request_timeout = '2s'
					disable_connections = false

				[plugins.'io.containerd.runtime.v2.task']
					platforms = ['linux/arm64/v8']

				[plugins.'io.containerd.service.v1.diff-service']
					default = ['walking']
					sync_fs = false

				[plugins.'io.containerd.service.v1.tasks-service']
					blockio_config_file = ''
					rdt_config_file = ''

				[plugins.'io.containerd.shim.v1.manager']
					env = []

				[plugins.'io.containerd.snapshotter.v1.native']
					root_path = ''

				[plugins.'io.containerd.snapshotter.v1.overlayfs']
					root_path = ''
					upperdir_label = false
					sync_remove = false
					slow_chown = false
					mount_options = []

				[plugins.'io.containerd.transfer.v1.local']
					max_concurrent_downloads = 3
					max_concurrent_uploaded_layers = 3
					config_path = ''

			[cgroup]
				path = ''

			[timeouts]
				'io.containerd.timeout.bolt.open' = '0s'
				'io.containerd.timeout.cri.defercleanup' = '1m0s'
				'io.containerd.timeout.metrics.shimstats' = '2s'
				'io.containerd.timeout.shim.cleanup' = '5s'
				'io.containerd.timeout.shim.load' = '5s'
				'io.containerd.timeout.shim.shutdown' = '3s'
				'io.containerd.timeout.task.state' = '2s'

			[stream_processors]
				[stream_processors.'io.containerd.ocicrypt.decoder.v1.tar']
					accepts = ['application/vnd.oci.image.layer.v1.tar+encrypted']
					returns = 'application/vnd.oci.image.layer.v1.tar'
					path = 'ctd-decoder'
					args = ['--decryption-keys-path', '/etc/containerd/ocicrypt/keys']
					env = ['OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf']

				[stream_processors.'io.containerd.ocicrypt.decoder.v1.tar.gzip']
					accepts = ['application/vnd.oci.image.layer.v1.tar+gzip+encrypted']
					returns = 'application/vnd.oci.image.layer.v1.tar+gzip'
					path = 'ctd-decoder'
					args = ['--decryption-keys-path', '/etc/containerd/ocicrypt/keys']
					env = ['OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf']
			"""
	}

}
