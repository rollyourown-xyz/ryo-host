# Deploy a container with dynamic IP address with optional mounts

This module provisions a container with dynamic IP and optional mounts. Various properties of the container are specified by input variables:

* lxd_remote (string): The name of the remote lxd host to provision the container to. Must be configured as a remote for the local machine via lxc remote add

* container_privileged (string): Whether to launch a privileged container. Default is false, so only need to specify if a privileged container is required

* container_image (string): The name of the image to use to launch the container. This must exist on the remote host

* container_name (string): The name of the container. Must be unique

* container_profiles (string): The LXD profile to use for launching the container. This must be provisioned on the host

* container_network (string): The network to launch the container into. This must be provisioned on the host

* container_cloud-init (string): The cloud-init file to pass to the container on launch

* container_mounts (list): List of mount points to configure as disk devices. Each list member must be a map of disk properties to configure. Each map item must specify a name for the mount, the source path on the host, the path to mount in the container and whether the mount should be read-only. The form for a map is:

        {name = string, host_path = string, mount_path = string, mount_readonly = bool}
