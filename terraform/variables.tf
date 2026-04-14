variable "vm_count" {
  description = "Number of worker nodes to create."
  type        = number
  default     = 3
}

variable "worker_name_prefix" {
  description = "Name prefix for each VM. VMs are named <prefix>-0, <prefix>-1, etc."
  type        = string
  default     = "worker"
}

variable "image" {
  description = "Ubuntu image to use (e.g. 'lts', '24.04', 'jammy')."
  type        = string
  default     = "jammy"
}

variable "cpus" {
  description = "Number of vCPUs per VM."
  type        = number
  default     = 2
}

variable "memory" {
  description = "RAM per VM (e.g. '2G', '4G')."
  type        = string
  default     = "6G"
}

variable "disk" {
  description = "Disk size per VM (e.g. '10G', '20G')."
  type        = string
  default     = "15G"
}

variable "soci_version" {
  description = "SOCI snapshotter version"
  type        = string
  default     = "0.13.0"
}
