output "cluster_nodes" {
  value = {
    master  = multipass_instance.master_node.ipv4
    workers = multipass_instance.worker_node[*].ipv4
  }
}