# Global provider definitions for deployment
############################################

terraform {
  required_version = ">= 0.14"
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "~> 1.5.0"
    }
  }
}

provider "lxd" {
  # Remote configuration needed with LXD snap, even if remotes have been defined out of band via 'lxc remote add'
  generate_client_certificates = true
  accept_remote_certificate    = true

  lxd_remote {
    name     = local.lxd_remote_name
    scheme   = "https"
    address  = local.lxd_host_private_ipv4_address
    port     = 8443
    password = local.lxd_core_trust_password
    default  = true
  }
}
