# build soci help page

# NAME

build soci `[docker build args...]`

# DESCRIPTION

Builds container image using a buildkit remote builder, based on `[docker build args...]`, converts built image to [SOCI manifest V2](https://github.com/awslabs/soci-snapshotter/blob/main/docs/soci-index-manifest-v2.md) and pushes the converted image.
Builder to be used is selected by consistent-hashing of image tag from `[docker build args...]` to a remote builder index.  
Converted images is pushed with `-soci` suffix applied.

Index conversion and pushing is done on the remote builder pod, that has [docker-credential-env](https://github.com/isometry/docker-credential-env) credential helper setup for authenticating with remote registries.

# EXAMPLE

```bash
just build soci . -f build/Dockerfile -t ghcr.io/maratoid/containerd-soci-builder:0.21.0 --platform linux/amd64,linux/arm64 --push
```

# PARAMETERS

## docker build args

`docker build` command options and flags

# FILES

Uses `consitenthash` utility from `build/consistenthash`

# Environment variables

## JUST_PASS_GH_TOKEN

`yes` by default. If `yes`, output of `gh auth token` is passed to `docker-credential-env` on the builder pod.

## docker-credential-env variables.

See https://github.com/isometry/docker-credential-env#environment-variables  

All environment variables matching `^DOCKER_.*_USR=.+$` and `^DOCKER_.*_PSW=.+$` will be passed to `docker-credential-env` on the builder pod.

## JUST_BUILDER_BASE_NAME

Base name for buildx builders, `buildkit`

## JUST_BUILDER_NAMESPACE

Namespace for buildkit manifests, `buildkit`

# AUTHOR

[Marat Garafutdinov](mailto:maratoid@gmail.com)