# eks-soci-builder

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.18.1](https://img.shields.io/badge/AppVersion-0.18.1-informational?style=flat-square)

Deploy containerd and soci snapshotter worker buildkit builders.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Marat G | <maratoid@gmail.com> | <https://maratg.com> |

## Source Code

* <https://github.com/maratoid/eks-soci>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| annotations | object | `{}` | annotations applied to all resources |
| builderSet.additionalMounts | list | `[]` | additional volume mounts for buildkit container |
| builderSet.affinity | object | `{}` | pod affinity see: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity |
| builderSet.annotations | object | `{}` | annotations for statefulset and pod containers |
| builderSet.image | object | | container image information |
| builderSet.image.tag | string | `""` | if empty, tag will be set to .Chart.appVersion |
| builderSet.labels | object | `{}` | labels for statefulset and pod containers |
| builderSet.livenessProbe | object |  | pod liveness probe |
| builderSet.nodeSelector | object | `{}` | pod nodeselector see: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector |
| builderSet.podAnnotations | object | `{}` | annotations for pod containers |
| builderSet.podLabels | object | `{}` | labels for pod containers |
| builderSet.qemu.additionalMounts | list | `[]` | additional volume mounts for qemu container |
| builderSet.qemu.install | bool | `true` | enable cross-platform container building |
| builderSet.qemu.resources | object | `{}` | qemu container resources  requests:    memory: "128Mi"    cpu: "500m"  limits:    memory: "128Mi" |
| builderSet.readinessProbe | object |  | pod readiness probe |
| builderSet.replicas | int | `2` | number of statefulset replicas |
| builderSet.resources | object | `{}` | buildkit container resources  requests:    memory: "31G"    cpu: "2"  limits:    memory: "31G" |
| builderSet.updateStrategy | object | `{}` | statefulset update strategy |
| config.annotations | object | `{}` | annotations applied to config map |
| config.buildkit.additionalConfig | string | `""` | any additional TOML tables to prepend to buildkit config |
| config.buildkit.gc | object | | buildkit garbage collection settings see: https://docs.docker.com/build/cache/garbage-collection/  and https://docs.docker.com/build/buildkit/toml-configuration/ |
| config.buildkit.gc.keepStorage | string | `10%` | storage limit for default garbage collection profile |
| config.buildkit.gc.policies | list | | garbage collection policies |
| config.buildkit.log | object |  | buildkit log verbosity and format |
| config.buildkit.namespace | string | `buildkit` | buildkit containerd namespace  |
| config.containerd.additionalConfig | string | `""` |  |
| config.containerd.disabledPlugins | list | [io.containerd.grpc.v1.cri, io.containerd.snapshotter.v1.blockfile,<br> io.containerd.snapshotter.v1.btrfs, io.containerd.snapshotter.v1.devmapper, io.containerd.snapshotter.v1.zfs<br>io.containerd.tracing.processor.v1.otlp] | disabled plugins. io.containerd.grpc.v1.cri should be disabled for containerd worker as we are only using containerd for building, and leaving cri enabled seems to mess with garbage collection |
| config.labels | object | `{}` | labels applied to config map  |
| config.soci.additionalConfig | string | `""` | any additional TOML tables to prepend to SOCI config |
| config.soci.log.level | string | `info` | log level |
| fullnameOverride | string | `""` | chart resource name override |
| labels | object | `{}` | labels applied to all resources |
| nameOverride | string | `""` | 'app.kubernetes.io/name' selector name override |
| service.address | string | `none` | service IP |
| service.annotations | object | `{}` | service annotations |
| service.labels | object | `{}` | service labels |
| service.name | string | `""` | service name override |
| service.ports | list |  | service ports array |
| service.type | string | `ClusterIP` | service type |
| serviceAccount.annotations | object | `{}` | service account annotations |
| serviceAccount.create | bool | `true` | create service account |
| serviceAccount.labels | object | `{}` | service account labels |
| serviceAccount.name | string | `""` | service account name override |
| storage.accessModes | list | `["ReadWriteOnce"]` | storage access modes |
| storage.additionalVolumeClaimTemplates | list | `[]` | any additional volume claim templates for buildkit statefulset |
| storage.rootMount | string | `"/builder"` | mount location for shared buildkit/containerd/soci storage |
| storage.storage | string | `"10Gi"` | storage size |
| storage.storageClassName | string | `gp3` | storage class |
| tls.secretName | string | `graft-builder-tls` | if useCertManager=true, name of certmanager-created secret if useCertManager=false, name of pre-existing tls secret with ca.crt, tls.crt, tls.key keys |
| tls.useCertManager | bool | `true` | use CertManager to generate required certificates |


