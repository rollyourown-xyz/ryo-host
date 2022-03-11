<!--
SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Roll Your Own Host Server

This repository contains automation code to set up a [rollyourown.xyz](https://rollyourown.xyz) [host server](https://rollyourown.xyz/rollyourown/how_to_use/host_server/).

## Summary

This project uses [Ansible](https://www.ansible.com/) to deploy the software and configuration needed for a [rollyourown.xyz host server](https://rollyourown.xyz/rollyourown/how_to_use/host_server/).

## How to Use

A detailed description of how to use a rollyourown.xyz project to deploy and maintain an open source solution can be found [on the rollyourown.xyz website](https://rollyourown.xyz/rollyourown/how_to_use/).

Before deploying a host server, a [rollyourown.xyz control node](https://rollyourown.xyz/rollyourown/how_to_use/control_node/) must be set up first. A host server is controlled by a control node via a secure [wireguard](https://www.wireguard.com/) tunnel.

In summary, after setting up a control node then deploy a host server as follows:

1. Log in to the **control node** as the non-root user, enter the `ryo-projects` directory and clone the host server repository to your control node from [Codeberg](https://codeberg.org) or [GitHub](https://github.com):

        git clone https://codeberg.org/rollyourown-xyz/ryo-host

    or

        git clone https://github.com/rollyourown-xyz/ryo-host

2. Choose a name (e.g. "host-1") for the host server, enter the `ryo-host` directory and copy the file `configuration/configuration_TEMPLATE.yml` to a new file `configuration/configuration_<HOST_NAME>.yml`, replacing <HOST_NAME> with the name chosen:

        cd ryo-host
        cp configuration/configuration_TEMPLATE.yml configuration/configuration_<HOST_NAME>.yml

3. Edit the new file `configuration_<HOST_NAME>.yml` and add the host server's public (and if applicable private) IP address, and the root username and password. Also choose a non-root username and password for the host server. If you aren’t familiar with a different Linux editor, use nano to edit the file with:

        nano configuration/configuration_<HOST_NAME>.yml

4. Copy the file `configuration/inventory_TEMPLATE` to a new file `configuration/inventory_<HOST_NAME>`, replacing <HOST_NAME> with the name chosen above:

       cp configuration/inventory_TEMPLATE configuration/inventory_<HOST_NAME>

5. Edit the new file `inventory_<HOST_NAME>` and add the host server's public IP address:

        nano configuration/inventory_<HOST_NAME>

6. If this is **not** the first host server configured to be managed from the control node, check additional settings in `configuration_<HOST_NAME>.yml` and `inventory_<HOST_NAME>` and change as described in the comments in those files

7. Run the host server setup automation script `host-setup.sh`, passing the name of the host chosen above via the flag `-n`:

        ./host-setup.sh -n <HOST_NAME>

After setting up the host server, you are now ready to [deploy a rollyourown.xyz project](/rollyourown/projects/how_to_deploy) on the server.

## How to Collaborate

We would be delighted if you would like to contribute to [rollyourown.xyz](https://rollyourown.xyz) and there are a number of ways you can collaborate on this project:

- [Raising security-related issues](https://rollyourown.xyz/collaborate/security_vulnerabilities/)
- [Contributing bug reports, feature requests and ideas](https://rollyourown.xyz/collaborate/bug_reports_feature_requests_ideas/)
- [Improving the project](https://rollyourown.xyz/collaborate/existing_projects_and_modules/) - e.g. to provide fixes or enhancements

You may also like to contribute to the wider [rollyourown.xyz](https://rollyourown.xyz/) project by, for example:

- [Contributing a new project or module](https://rollyourown.xyz/collaborate/new_projects_and_modules/)
- [Contributing to the rollyourown.xyz website content](https://rollyourown.xyz/collaborate/website_content/) or [design](https://rollyourown.xyz/collaborate/website_design/)
- [Maintaining a rollyourown.xyz repository](https://rollyourown.xyz/collaborate/working_with_git/what_is_git/#project-maintainer)

Issues for this project can be submitted on [Codeberg](https://codeberg.org/) (_preferred_) or [GitHub](https://github.com/):

- Issues on Codeberg: [here](https://codeberg.org/rollyourown-xyz/ryo-host>/issues)
- Issues on GitHub: [here](https://github.com/rollyourown-xyz/ryo-host/issues)

## Security Vulnerabilities

If you have found a security vulnerability in any [rollyourown.xyz](https://rollyourown.xyz/) service or any of the [rollyourown.xyz](https://rollyourown.xyz/) projects, modules or other repositories, please read our [security disclosure policy](https://rollyourown.xyz/collaborate/security_vulnerabilities/) and report this via our [security vulnerability report form](https://forms.rollyourown.xyz/security-vulnerability).

## Repository Links

For public contributions, we maintain mirror repositories of this project on [Codeberg](https://codeberg.org) and [GitHub](https://github.com):

- [https://codeberg.org/rollyourown-xyz/ryo-host](https://codeberg.org/rollyourown-xyz/ryo-host)
- [https://github.com/rollyourown-xyz/ryo-host](https://github.com/rollyourown-xyz/ryo-host)

Our preferred collaboration space is Codeberg:

<a href="https://codeberg.org/rollyourown-xyz/ryo-host"><img alt="Get it on Codeberg" src="https://get-it-on.codeberg.org/get-it-on-blue-on-white.png" height="60"></a>

The primary repository for this project is hosted on our own Git repository server at:

- [https://git.rollyourown.xyz/ryo-projects/ryo-host](https://git.rollyourown.xyz/ryo-projects/ryo-host)

**Repositories on our own Git server are accessible only to members of our organisation**.

## Copyright, Licences and Trademarks

For information on copyright, licences and trademarks, see [https://rollyourown.xyz/about/copyright_licenses_trademarks/](https://rollyourown.xyz/about/copyright_licenses_trademarks/).
