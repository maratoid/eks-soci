module: "maratg.com/buildkit"
language: {
	version: "v0.16.1"
}
deps: {
	"cue.dev/x/crd/cert-manager.io@v0": {
		v:       "v0.3.0"
		default: true
	}
	"cue.dev/x/k8s.io@v0": {
		v:       "v0.6.0"
		default: true
	}
}
