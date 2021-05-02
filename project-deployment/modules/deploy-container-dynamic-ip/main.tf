terraform {
  required_version = ">= 0.14"
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "~> 1.5.0"
    }
  }
}

resource "lxd_container" "container" {
  remote     = var.lxd_remote
  name       = var.container_name
  image      = var.container_image
  profiles   = var.container_profiles
  
  config = { 
    "security.privileged": var.container_privileged
    "user.user-data" = var.container_cloud-init
  }
  
    device {
    name    = "eth0"
    type    = "nic"

    properties = {
      name           = "eth0"
      network        = var.container_network
    }
  }

  dynamic "device" {

    for_each = var.container_mounts
    content {
      name   = device.value["name"]
      type   = "disk"

      properties = {
        source   = device.value["host_path"]
        path     = device.value["mount_path"]
        readonly = device.value["mount_readonly"]
        shift    = "true"
      }
    }
  }
}
