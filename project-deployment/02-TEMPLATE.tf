## TEMPLATE TERRAFORM FILE FOR DEPLOYMENT OF A COMPONENT

# Deployment of <COMPONENT NAME>
################################

module "deploy-<COMPONENT NAME>" {
  source = "./modules/deploy-container-static-ip"

  lxd_remote                 = local.lxd_remote_name
  host_external_ipv4_address = local.lxd_host_public_ipv4_address
  container_image            = join("-", [ local.project_name, "COMPONENT NAME", var.image_version ])
  container_name             = "COMPONENT NAME"
  container_profiles         = ["default"]
  container_network          = "LXD NETWORK TO USE"
  container_ipv4_address     = join(".", [ local.LXD_NETWORK_TO_USE, "10" ])
  container_cloud-init       = file("cloud-init/cloud-TEMPLATE.yml")

  # OPTIONAL PROXIES - THE FOLLOWING AS EXAMPLE
  container_proxies = [
    {name = "proxy0", protocol = "tcp", listen = "80", connect = "80"},
    {name = "proxy1", protocol = "tcp", listen = "443", connect = "443"},
  ]

  # OPTIONAL CONTAINER MOUNTS - THE FOLLOWING AS EXAMPLE
  container_mounts = [
    {name = "<NAME>", host_path = "/var/containers/<PROJECT NAME>/<SUBDIRECTORY>", mount_path = "<PATH>", mount_readonly = true}
  ]
}
