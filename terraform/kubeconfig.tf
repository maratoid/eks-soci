resource "multipass_file_download" "kubeconfig" {
  instance    = multipass_instance.master_node.name
  source      = "/home/ubuntu/k3s.yaml"
  destination = abspath("${path.module}/../kubeconfig.multipass")

  provisioner "local-exec" {
    command = join(" ", [
      abspath("${path.module}/scripts/merge-kubeconfigs.sh"),
      abspath("${path.module}/../kubeconfig.multipass"),
      multipass_instance.master_node.ipv4[0],
      "${var.merge_kubeconfigs}",
      var.merged_cluster_name
    ])
  }
}