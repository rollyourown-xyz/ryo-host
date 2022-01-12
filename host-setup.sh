#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

helpMessage()
{
   echo "host-setup.sh: Use ansible to configure a remote host for project deployment"
   echo ""
   echo "Help: host-setup.sh"
   echo "Usage: ./host-setup.sh -n hostname"
   echo "Flags:"
   echo -e "-n hostname \t\t(Mandatory) Name of the host to be configured"
   echo -e "-h \t\t\tPrint this help message"
   echo ""
   exit 1
}

errorMessage()
{
   echo "Invalid option or mandatory input variable is missing"
   echo "Use \"./host-setup.sh -h\" for help"
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

echo "Running host setup playbooks"
echo ""

# Generic host setup
echo "Executing generic host setup playbook for $hostname"
echo "Executing command: ansible-playbook -i "$SCRIPT_DIR"/configuration/inventory_"$hostname" host-setup/setup.yml --extra-vars \"host_id="$hostname"\""
echo ""
ansible-playbook -i "$SCRIPT_DIR"/configuration/inventory_"$hostname" "$SCRIPT_DIR"/host-setup/setup.yml --extra-vars "host_id="$hostname""
