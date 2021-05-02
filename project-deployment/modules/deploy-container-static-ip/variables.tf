# Input variable definitions

variable "lxd_remote" {
  description = "Name of the remote lxd host to provision the container to."
  type = string
}

variable "host_external_ipv4_address" {
  description = "External IPv4 address for the lxd (remote) host."
  type = string
}

variable "container_privileged" {
  description = "Whether to launch a privileged container."
  type = string
  default = "false"
}

variable "container_image" {
  description = "Name of the image to use to launch the container. Must be either public, downloadable image or must exist on the remote host."
  type = string
  default = "ubuntu-minimal:focal"
}

variable "container_name" {
  description = "Name of the container. Must be unique."
  type = string
}

variable "container_profiles" {
  description = "LXD profiles for launching the container. Must be provisioned on the host."
  type = list(string)
  default = ["default"]
}

variable "container_network" {
  description = "Network to launch the container into. Must be provisioned on the host."
  type = string
  default = "lxdbr0"
}

variable "container_cloud-init" {
  description = "cloud-init file to pass to the container on launch."
  type = string
  sensitive = true
}

variable "container_ipv4_address" {
  description = "IPv4 address for the container. Must be unique in the deployment and consistent with the network the container is launched in."
  type = string
}

variable "container_proxies" {
  description = "List of proxy devices to configure. Each list member must be a map of proxy port properties to configure."
  type = list(object({
    name = string
    protocol = string
    listen = string
    connect = string
  }))
  default = []
}

variable "container_mounts" {
  description = "List of mount points to configure as disk devices. Each list member must be a map of disk properties to configure."
  type = list(object({
    name = string
    host_path = string
    mount_path = string
    mount_readonly = bool
  }))
  default = []
}
