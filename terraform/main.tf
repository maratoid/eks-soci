
resource "multipass_instance" "master_node" {
  name   = "master-node"
  cpus   = var.cpus
  memory = var.memory
  disk   = var.disk
  image  = var.image

  cloud_init = local.master_cloud_init
}

resource "multipass_instance" "worker_node" {
  count = var.vm_count

  name   = "${var.worker_name_prefix}-${count.index}"
  image  = var.image
  cpus   = var.cpus
  memory = var.memory
  disk   = var.disk

  cloud_init = local.worker_cloud_init

  depends_on = [multipass_instance.master_node]
}

resource "multipass_alias" "kubectl" {
  name     = "k"
  instance = multipass_instance.master_node.name
  command  = "/usr/local/bin/k"
}
