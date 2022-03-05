#!/bin/bash

# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
   echo "host-upgrade.sh: Use ansible to upgrade a remote host for project deployment"
   echo "Prerequisite is that the host-setup.sh script has been run previously"
   echo ""
   echo "Help: host-upgrade.sh"
   echo "Usage: ./host-upgrade.sh -n hostname"
   echo "Flags:"
   echo -e "-n hostname \t\t(Mandatory) Name of the host to be upgraded"
   echo -e "-h \t\t\tPrint this help message"
   echo ""
   exit 1
}

errorMessage()
{
   echo "Invalid option or mandatory input variable is missing"
   echo "Use \"./host-upgrade.sh -h\" for help"
   exit 1
}

while getopts n:h flag
do
    case "${flag}" in
        n) hostname=${OPTARG};;
        h) helpMessage ;;
        ?) errorMessage ;;
    esac
done

if [ -z "$hostname" ]
then
   errorMessage
fi

echo "Running host upgrade playbooks"
echo ""

# Generic host upgrade
echo "Executing generic host upgrade playbook for $hostname"
echo "Executing command: ansible-playbook -i "$SCRIPT_DIR"/configuration/inventory_"$hostname" host-setup/upgrade.yml --extra-vars \"host_id="$hostname"\""
echo ""
ansible-playbook -i "$SCRIPT_DIR"/configuration/inventory_"$hostname" "$SCRIPT_DIR"/host-setup/upgrade.yml --extra-vars "host_id="$hostname""
