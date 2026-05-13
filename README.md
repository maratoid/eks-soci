# Building and running streamable containers in Kubernetes 

## Setup - macOS

### Requirements

* [Homebrew](https://brew.sh/)
* [Multipass](https://canonical.com/multipass)
* [mise](https://mise.jdx.dev/)
* Bash 5.x (default macOS bash is too old at 3.x)

### Setup requirements

Run `brew bundle` to install modern bash, [Multipass](https://canonical.com/multipass) and [mise](https://mise.jdx.dev/)  

You can install each of the requirements separately with `brew`, e.g. `brew install bash`, `brew install --cask multipass` and `brew install mise`

### Mise setup

Setup mise activation per [instructions](https://mise.jdx.dev/getting-started.html#activate-mise), or just run `eval "$(mise activate zsh)` or `eval "$(mise activate bash)`, depending on your shell.

Then run `mise install` 


## Setup - other

### Requirements

* [Multipass](https://canonical.com/multipass)
* [mise](https://mise.jdx.dev/)
* Bash 5.x 

### Setup requirements

Install [Multipass](https://canonical.com/multipass) and [mise](https://mise.jdx.dev/) 


### Mise setup

Setup mise activation per [instructions](https://mise.jdx.dev/getting-started.html#activate-mise), reload your shell session.

Then run `mise install` 

## CLI

Run `just` to see available commands

```
$ just
Available recipes:
    help *command # command help
    build ...
    builders ...
    cluster ...
    code ...
    deploy ...
```

run `just help <recipe>` and `just help <recipe> <command>` for further help:

```
$ just help cluster

Use:

just help cluster create
just help cluster destroy

$ just help cluster create
```

## Deploy

### 1 - Create multipass cluster.  

Run `just cluster create`

### 2 - Deploy buildkit and cert manager

Run `just deploy all`

### Configure local buildx

Run `just builders setup`

### Verify

Running `just builders info` should give you something similar to:

```
$ just builders info
NAME/NODE           DRIVER/ENDPOINT                                   STATUS    BUILDKIT   PLATFORMS
buildkit-0*         remote
 \_ buildkit-0       \_ kube-pod://buildkit-ss-0?namespace=buildkit   running   v0.29.0    linux/amd64 (+2), linux/arm64, linux/arm (+2), linux/ppc64le, (6 more)
buildkit-1          remote
 \_ buildkit-1       \_ kube-pod://buildkit-ss-1?namespace=buildkit   running   v0.29.0    linux/amd64 (+2), linux/arm64, linux/arm (+2), linux/ppc64le, (6 more)
...
```

## Build

Run:

```
just build soci \
  <path to build context> -f <path to docker file> \
  -t <full image tag> \
  --platform <platform list> --push
```

for example:

```
just build soci \
  . \
  -f build/Dockerfile \
  -t ghcr.io/maratoid/containerd-soci-builder:0.24.0 \
  --platform linux/amd64,linux/arm64 --push
```