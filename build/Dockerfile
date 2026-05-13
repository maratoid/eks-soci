FROM --platform=$BUILDPLATFORM golang:alpine AS consistenthash

ARG TARGETOS
ARG TARGETARCH

RUN mkdir -p /build
WORKDIR /build
COPY ./build/consistenthash/ .
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o consistenthash .

FROM ubuntu:22.04

ARG CONTAINERD_VERSION=2.2.3
ARG NERDCTL_VERSION=2.2.2
ARG SOCI_VERSION=0.13.0
ARG PLUGINS_VERSION=1.9.1
ARG CRITOOLS_VERSION=1.35.0
ARG BUILDKIT_VERSION=0.29.0
ARG RUNC_VERSION=1.4.2
ARG DOCKER_CREDENTIAL_ENV_VERSION=1.6.1
ARG TARGETARCH

USER root

ENV DEBIAN_FRONTEND=noninteractive

# tools
RUN --mount=type=cache,sharing=locked,id=apt-cache,target=/var/cache/apt apt-get update -y \
  && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    fuse3 \
    fuse-overlayfs \
    git \
    gnupg \
    iproute2 \
    iptables \
    kmod \
    net-tools \
    socat \
    jq \
    strace \
    unzip \
    supervisor \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

# containerd
RUN mkdir /tmp/containerd \
  && cd /tmp/containerd \
  && curl -sL https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-${TARGETARCH}.tar.gz -o "containerd-${CONTAINERD_VERSION}-linux-${TARGETARCH}.tar.gz" \
  && tar xvf containerd-${CONTAINERD_VERSION}-linux-${TARGETARCH}.tar.gz \
  && mv bin/containerd-shim-runc-v2 /usr/bin/containerd-shim-runc-v2 \
  && mv bin/containerd /usr/bin/containerd \
  && mv bin/containerd-stress /usr/bin/containerd-stress \
  && mv bin/ctr /usr/bin/ctr \
  && cd / \
  && rm -rf /tmp/containerd \
  && mkdir -p /etc/containerd

# containerd plugins
RUN mkdir -p /opt/cni/bin /opt/containerd \
  && cd /opt/cni/bin \
  && ln -s /opt/cni/bin /opt/containerd/bin \
  && cd /opt/cni/bin \
  && curl -sL "https://github.com/containernetworking/plugins/releases/download/v${PLUGINS_VERSION}/cni-plugins-linux-${TARGETARCH}-v${PLUGINS_VERSION}.tgz" -o "cni-plugins-linux-${TARGETARCH}-${PLUGINS_VERSION}.tgz" \
  && tar xvf "cni-plugins-linux-${TARGETARCH}-${PLUGINS_VERSION}.tgz" \
  && rm -rf "cni-plugins-linux-${TARGETARCH}-${PLUGINS_VERSION}.tgz"

# critools
RUN mkdir /tmp/critools \
  && cd /tmp/critools \
  && curl -sL "https://github.com/kubernetes-sigs/cri-tools/releases/download/v${CRITOOLS_VERSION}/crictl-v${CRITOOLS_VERSION}-linux-${TARGETARCH}.tar.gz" -o "crictl-v${CRITOOLS_VERSION}-linux-${TARGETARCH}.tar.gz" \
  && tar xvf "crictl-v${CRITOOLS_VERSION}-linux-${TARGETARCH}.tar.gz" \
  && mv crictl /usr/local/bin \
  && cd / \
  && rm -rf /tmp/critools

# runc
RUN mkdir /tmp/runc \
  && cd /tmp/runc \
  && curl -sL "https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.${TARGETARCH}" -o "runc.${TARGETARCH}" \
  && mv runc.${TARGETARCH} /usr/local/bin/runc \
  && chmod +x /usr/local/bin/runc \
  && cd / \
  && rm -rf /tmp/runc

# buildkit
RUN mkdir /tmp/buildkit \
  && cd /tmp/buildkit \
  && curl -sL "https://github.com/moby/buildkit/releases/download/v${BUILDKIT_VERSION}/buildkit-v${BUILDKIT_VERSION}.linux-${TARGETARCH}.tar.gz" -o "buildkit-v${BUILDKIT_VERSION}.linux-${TARGETARCH}.tar.gz" \
  && tar xvf "buildkit-v${BUILDKIT_VERSION}.linux-${TARGETARCH}.tar.gz" \
  && mv bin/* /usr/bin \
  && cd / \
  && rm -rf /tmp/buildkit \
  && mkdir -p /etc/buildkit

# nerdctl
RUN mkdir /tmp/nerdctl \
  && cd /tmp/nerdctl \
  && curl -sL "https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-${TARGETARCH}.tar.gz" -o "nerdctl-${NERDCTL_VERSION}-linux-${TARGETARCH}.tar.gz" \
  && tar xvf "nerdctl-${NERDCTL_VERSION}-linux-${TARGETARCH}.tar.gz" \
  && mv nerdctl /usr/local/bin \
  && cd / \
  && rm -rf /tmp/nerdctl

# docker-credential-env
RUN mkdir /tmp/docker-credential-env \
  && cd /tmp/docker-credential-env \
  && curl -sL "https://github.com/isometry/docker-credential-env/releases/download/v${DOCKER_CREDENTIAL_ENV_VERSION}/docker-credential-env_${DOCKER_CREDENTIAL_ENV_VERSION}_linux_${TARGETARCH}.zip" -o "docker-credential-env_${DOCKER_CREDENTIAL_ENV_VERSION}_linux_${TARGETARCH}.zip" \
  && unzip  "docker-credential-env_${DOCKER_CREDENTIAL_ENV_VERSION}_linux_${TARGETARCH}.zip" \
  && mv docker-credential-env /usr/local/bin \
  && cd / \
  && rm -rf /tmp/docker-credential-env

# soci
RUN mkdir /tmp/soci \
  && cd /tmp/soci \
  && curl -sL "https://github.com/awslabs/soci-snapshotter/releases/download/v${SOCI_VERSION}/soci-snapshotter-${SOCI_VERSION}-linux-${TARGETARCH}.tar.gz" -o "soci-snapshotter-${SOCI_VERSION}-linux-${TARGETARCH}.tar.gz" \
  && tar -zxvf "soci-snapshotter-${SOCI_VERSION}-linux-${TARGETARCH}.tar.gz" \
  && mv soci /usr/local/bin \
  && mv soci-snapshotter-grpc /usr/local/bin \
  && cd \
  && rm -rf /tmp/soci

# create a helper script for building SOCI indexes using nerdctl
COPY <<'EOF' /soci.sh
#!/usr/bin/env bash
# build and push image SOCI index with nerdctl, pulling the image first if needed.
# soci.sh <image:tag> <containerd namespace> 
if ! nerdctl --namespace ${2} image inspect --all-platforms ${1} > /dev/null 2>&1; then
  nerdctl --namespace ${2} pull --all-platforms ${1}
fi


nerdctl --namespace ${2} image convert --soci --all-platforms ${1} ${1}-soci
nerdctl --namespace ${2} push --all-platforms ${1}-soci
EOF
RUN chmod +x /soci.sh 

# configure all Docker authentication to use the docker-credential-env credential helper
RUN mkdir /root/.docker
COPY <<'EOF' /root/.docker/config.json
{
  "credsStore": "env"
}
EOF

COPY --link --from=consistenthash /build/consistenthash /usr/local/bin/consistenthash

WORKDIR /

ENV CONTAINERD_VERSION=${CONTAINERD_VERSION}
ENV NERDCTL_VERSION=${NERDCTL_VERSION}
ENV SOCI_VERSION=${SOCI_VERSION}
ENV PLUGINS_VERSION=${PLUGINS_VERSION}
ENV CRITOOLS_VERSION=${CRITOOLS_VERSION}
ENV BUILDKIT_VERSION=${BUILDKIT_VERSION}
ENV RUNC_VERSION=${RUNC_VERSION}

ENTRYPOINT ["/usr/bin/supervisord"]
