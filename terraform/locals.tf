locals {
  k3s_token = "kimberly3sprang2cake4erm4DEBRIS"
  
  soci_setup = <<-EOT
    #!/bin/bash
    ARCH=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
    VERSION=${var.soci_version}
    ARCHIVE=soci-snapshotter-$${VERSION}-linux-$${ARCH}.tar.gz

    curl -fLo $${ARCHIVE} https://github.com/awslabs/soci-snapshotter/releases/download/v$${VERSION}/$${ARCHIVE}
    curl -fLo $${ARCHIVE}.sha256sum https://github.com/awslabs/soci-snapshotter/releases/download/v$${VERSION}/$${ARCHIVE}.sha256sum
    sha256sum ./$ARCHIVE.sha256sum
    tar xzvf $${ARCHIVE} -C /usr/local/bin soci-snapshotter-grpc
    rm -rf $${ARCHIVE}
    rm -rf $${ARCHIVE}.sha256sum

    mkdir -p /etc/soci-snapshotter-grpc
    cat <<EOF_SNAPSHOTTER_CONFIG >/etc/soci-snapshotter-grpc/config.toml
    [cri_keychain]
    enable_keychain = true
    image_service_path = "/run/k3s/containerd/containerd.sock"
    EOF_SNAPSHOTTER_CONFIG

    curl -fLo /etc/systemd/system/soci-snapshotter.service https://raw.githubusercontent.com/awslabs/soci-snapshotter/v$${VERSION}/soci-snapshotter.service
    systemctl daemon-reload
    systemctl enable --now soci-snapshotter
  EOT

  kubelet_config = <<-EOT
    apiVersion: kubelet.config.k8s.io/v1beta1
    kind: KubeletConfiguration
    imageServiceEndpoint: unix:///run/soci-snapshotter-grpc/soci-snapshotter-grpc.sock
  EOT

  containerd_config = <<-EOT
    version = 2
    [proxy_plugins.soci]
      type = "snapshot"
      address = "/run/soci-snapshotter-grpc/soci-snapshotter-grpc.sock"
      [proxy_plugins.soci.exports]
        root = "/var/lib/soci-snapshotter-grpc"
    [plugins."io.containerd.grpc.v1.cri".containerd]
      snapshotter = "soci"
      # This line is required for containerd to send information about how to lazily load the image to the snapshotter
      disable_snapshot_annotations = false
  EOT

  # Cloud-init script for the master node
  # Installs K3s server, creates a wrapper script for kubectl, and sets the token
  master_cloud_init = <<-EOT
    #cloud-config
    package_update: true
    package_upgrade: true
    write_files:
      - path: /usr/local/bin/k3sw
        permissions: '0755'
        content: |
          #!/bin/sh
          sudo k3s kubectl "$@"
      - path: /usr/local/bin/soci-setup.sh
        permissions: '0755'
        content: |
          ${local.soci_setup}
      - path: /var/lib/rancher/k3s/agent/etc/kubelet.conf.d/99-soci-snapshotter.conf
        permissions: '0644'
        content: |
          ${local.kubelet_config}
      - path: /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl
        permissions: '0644'
        content: |
          ${local.containerd_config}
    runcmd:
      - /usr/local/bin/soci-setup.sh
      - curl -sfL https://get.k3s.io | K3S_TOKEN=${local.k3s_token} sh -s - server --cluster-init --node-label "role=master"
  EOT

  worker_cloud_init = <<-EOT
    #cloud-config
    package_update: true
    write_files:
      - path: /usr/local/bin/soci-setup.sh
        permissions: '0755'
        content: |
          ${local.soci_setup}
      - path: /var/lib/rancher/k3s/agent/etc/kubelet.conf.d/99-soci-snapshotter.conf
        permissions: '0644'
        content: |
          ${local.kubelet_config}
      - path: /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl
        permissions: '0644'
        content: |
          ${local.containerd_config}
    runcmd:
      - /usr/local/bin/soci-setup.sh
      - curl -sfL https://get.k3s.io | K3S_URL=https://${multipass_instance.k3s_master.ipv4[0]}:6443 K3S_TOKEN=${local.k3s_token} sh - --node-label "role=worker"
  EOT
}
