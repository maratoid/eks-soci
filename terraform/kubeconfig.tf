resource "multipass_file_download" "kubeconfig" {
  instance    = multipass_instance.master_node.name
  source      = "/etc/rancher/k3s/k3s.yaml"
  destination = abspath("${path.module}/../kubeconfig.multipass")

  lifecycle {
    action_trigger {
      events  = [after_create]
      actions = [action.local_command.merge_kubeconfigs]
    }
  }
}

action "local_command" "merge_kubeconfigs" {
  config {
    command = "sh"
    arguments = [
      "${path.module}/scripts/merge-kubeconfigs.sh",
      abspath("${path.module}/../kubeconfig.multipass"),
      multipass_instance.master_node.ipv4,
      "${var.merge_kubeconfigs}",
      var.merged_cluster_name
    ]
  }
}
