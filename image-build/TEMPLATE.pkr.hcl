#---------------------------------------------------------------------------
# Packer template for building LXD container image for <A PROJECT COMPONENT>
# Ubuntu minimal images are used as base images
#---------------------------------------------------------------------------

## Input variables
##

# Specify the version number of the image to be built
variable "version" {
  description = "Mandatory: The version identifier to be added to the output image name."
  type        = string
}

## Local configuration variables
##

# Name for the container for which the image is to be built
locals {
  project_name = yamldecode(file("${abspath(path.root)}/../configuration/configuration.yml"))["project_name"]
  service_name = "<PROJECT COMPONENT NAME>"
}

# Variables from configuration files
locals {
  remote_lxd_host = yamldecode(file("${abspath(path.root)}/../configuration/configuration.yml"))["project_name"]
}

## Parameters for the build process
##

locals {
  build_image_os      = "ubuntu-minimal"
  build_image_release = "focal"
  
  build_container_name = "packer-lxd-build"

  build_inventory_file = "${abspath(path.root)}/playbooks/inventory.yml"
  build_playbook_file  = "${abspath(path.root)}/playbooks/provision-TEMPLATE.yml"
  build_extra_vars     = ""
}

## Computed local variables
##

# Computed parameters for the output image
locals {
  output_image_name        = "${ join("-", [ local.project_name, local.service_name, var.version ]) }"
  output_image_description = "${ join(" ", [ 
      join(":", [ local.build_image_os , local.build_image_release ]),
      "image for",
      local.project_name,
      local.service_name,
      "- v",
      var.version
    ]
  )}"
}

## Build template
##

source "lxd" "container" {
  image          = join(":", [ local.build_image_os , local.build_image_release ])
  container_name = local.build_container_name
  output_image   = local.output_image_name

  publish_properties = {
    description = local.output_image_description
    os          = local.build_image_os
    release     = local.build_image_release
  }
}

build {
  sources = ["source.lxd.container"]

  provisioner "ansible" {
    inventory_file  = local.build_inventory_file
    playbook_file   = local.build_playbook_file
    extra_arguments = [ "--extra-vars", local.build_extra_vars ]
  }
  
  post-processors {

    # Copy image to remote LXD host
    post-processor "shell-local" {
      inline = [
        "echo \"Copying image ${local.output_image_name} to remote host ${local.remote_lxd_host}\"", 
        "echo \"This may take some time\"",
        "lxc image copy ${local.output_image_name} ${local.remote_lxd_host}: --copy-aliases",
        "echo \"Image copying completed\"",
      ]
      keep_input_artifact = true
    }

    # Post processor for removing image from local machine after copying to remote host
    post-processor "shell-local" {
      inline = [
        "echo \"Deleting local image ${local.output_image_name}\"",
        "lxc image delete ${local.output_image_name}",
        "echo \"Image deletion completed\"",
      ]
      keep_input_artifact = false
    }
  }
}
