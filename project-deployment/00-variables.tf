# Read variables for deployment as local variables
##################################################

# Configuration file paths
locals {
  project_configuration_path      = "${abspath(path.root)}/../configuration/configuration.yml"
  lxd_core_trust_password_path    = "${abspath(path.root)}/../../ryo-control-node/configuration/lxd_core_trust_password.yml"
}

# Basic project variables
locals {
  project_name = yamldecode(file(local.project_configuration_path))["project_name"]
}

# LXD variables
locals {
  lxd_remote_name               = yamldecode(file(local.project_configuration_path))["project_name"]
  lxd_host_private_ipv4_address = join(".", [ yamldecode(file(local.project_configuration_path))["wireguard_address_network_part"], "2" ])
  lxd_host_public_ipv4_address  = yamldecode(file(local.project_configuration_path))["host_public_ip"]
  lxd_core_trust_password       = yamldecode(file(local.lxd_core_trust_password_path))["lxd_core_trust_password"]
  lxd_dmz_network_part          = yamldecode(file(local.project_configuration_path))["lxd_dmz_network_part"]
  lxd_frontend_network_part     = yamldecode(file(local.project_configuration_path))["lxd_frontend_network_part"]
  lxd_backend_network_part      = yamldecode(file(local.project_configuration_path))["lxd_backend_network_part"]
}


# Input Variables
#################

variable "image_version" {
  description = "Version of the images to deploy - Leave blank for 'terraform destroy'"
  type        = string
}
