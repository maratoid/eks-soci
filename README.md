# Building and running streamable containers in Kubernetes 

## Dependencies

* [Cuelang](https://cuelang.org/)
* [Multipass](https://canonical.com/multipass) 
* [OpenTofu](https://opentofu.org/)/Terraform

Run `brew bundle` to install all three with Homebrew

## CLI

Run `cue cmd help` to see available commands

```
Available Commands:
  apply         Deploys builder statefulset to kubernetes cluster
  builders      Creates local buildx builder configs
  certinstall   Deploys cert manager requirement to kubernetes cluster
  certuninstall Removes cert manager from kubernetes cluster
  create        Create local kubernetes cluster with multipass and k3s.
  delete        Removes builder statefulset from kubernetes cluster
  destroy       Destroy local multipass and k3s kubernetes cluster.
  dryrun        Dry-run create builder statefulset in kubernetes cluster
  dump          Dump all builder stateful set kubernetes manifests to stdout
  ls            List all builder statefulset kubernetes objects
  schema        Show builder statefulset values schema
  vals          Dump unified builder stateful set values to stdout
```

## Deploy

### 1 - Create multipass cluster.  

If using opentofu: `cue cmd create`  
If using terraform: `cue cmd create -t tfbin=terraform`

See `cue help cmd create` for terraform variable overrides.

### 2 - Deploy cert manager

Run `cue cmd certinstall`.  
See `cue help cmd certinstall` for command options.

### 3 - Deploy buildkit stateful set

Run `cue cmd apply` to deploy with defaults.  
To override default values, run `cue cmd vals > values.yaml`:

```
baseName: buildkit
namespace: buildkit
tlsSecret: buildkit-tls
replicas: 2
buildKitPort: 1234
qemuImage: tonistiigi/binfmt:qemu-v10.2.1-65
buildkitImage: ghcr.io/maratoid/containerd-soci-builder:0.19.0
scaleRetentionPolicy: Retain
deleteRetentionPolicy: Retain
storageSize: 10Gi
storageMode:
  - ReadWriteOnce
labels: {}
annotations: {}
sociLogLevel: info
containerdLogLevel: info
buildkitLogLevel: info
```

Edit the resulting `values.yaml` file as needed and run `cue cmd apply -t values=values.yaml`  
See `cue help cmd apply` for more options.

### Configure local buildx

If you deployed buildkit stateful set with `-t values=values.yaml`, run:

```
cue cmd builders -t values=values.yaml
```

Otherwise run:

```
cue cmd builders
```

### Verify

Running `docker buildx ls` should give you something similar to:

```
$ docker buildx ls
NAME/NODE           DRIVER/ENDPOINT                                   STATUS    BUILDKIT   PLATFORMS
buildkit-0          remote
 \_ buildkit-0      \_ kube-pod://buildkit-0?namespace=buildkit       running   v0.29.0    linux/amd64* (+2), linux/arm64, linux/arm (+2), linux/ppc64le, (6 more)
 buildkit-1         remote
 \_ buildkit-1      \_ kube-pod://buildkit-1?namespace=buildkit       running   v0.29.0    linux/amd64* (+2), linux/arm64, linux/arm (+2), linux/ppc64le, (6 more)
 ...
```

You should also be able to set an active builder:

```
$ docker buildx use buildkit-0
$ docker buildx ls
NAME/NODE           DRIVER/ENDPOINT                                   STATUS    BUILDKIT   PLATFORMS
buildkit-0*         remote
 \_ buildkit-0      \_ kube-pod://buildkit-0?namespace=buildkit       running   v0.29.0    linux/amd64* (+2), linux/arm64, linux/arm (+2), linux/ppc64le, (6 more)
 ...
```