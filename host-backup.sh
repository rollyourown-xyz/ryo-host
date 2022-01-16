#!/bin/bash

# host-backup.sh
# This script backs up the persistent storage for the modules and projects deployed on a host server

# Help and error messages
#########################

helpMessage()
{
  echo "host-backup.sh: Back up the persistent storage for the modules and projects deployed on a host server to the control node"
  echo ""
  echo "Help: host-backup.sh"
  echo "Usage: ./host-backup.sh -n hostname"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host from which to back up project and module container persistent storage"  
  echo -e "-s stamp \t\t(Mandatory) A stamp (e.g. date, time, name) to identify the backup"  
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or input variables are missing"
  echo "Use \"./host-backup.sh -h\" for help"
  exit 1
}


# Command-line input handling
#############################

while getopts n:s:h flag
do
  case "${flag}" in
    n) hostname=${OPTARG};;
    s) stamp=${OPTARG};;
    h) helpMessage ;;
    ?) errorMessage ;;
  esac
done

if [ -z "$hostname" ] || [ -z "$stamp" ]
then
  errorMessage
fi


# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


# Info - Starting
#################

echo ""
echo "Starting backup for "$hostname""


# Stop project containers
##########################

echo ""
echo "Stopping project containers on "$hostname""

for project in $( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-projects_"$hostname".yml ); do
  echo ""
  echo "...stopping project containers for "$project""
  /bin/bash "$SCRIPT_DIR"/../"$project"/scripts-project/stop-project-containers.sh -n "$hostname"
done


# Stop module containers
########################

echo ""
echo "Stopping module containers on "$hostname""

for module in $( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-modules_"$hostname".yml ); do
  echo ""
  echo "...stopping module containers for "$module""
  /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/stop-module-containers.sh -n "$hostname"
done


# Back up project container persistent storage
##############################################

echo ""
echo "Backing up project container persistent storage on "$hostname" with stamp "$stamp""

for project in $( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-projects_"$hostname".yml ); do
  echo ""
  echo "Backing up "$project" container persistent storage on "$hostname" with stamp "$stamp""
  ansible-playbook -i "$SCRIPT_DIR"/configuration/inventory_"$hostname" "$SCRIPT_DIR"/backup-restore/backup-project.yml --extra-vars "id="$project" host_id="$hostname" backup_stamp="$stamp""
done


# Back up module container persistent storage
#############################################

echo ""
echo "Backing up module container persistent storage on "$hostname" with stamp "$stamp""

for module in $( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-modules_"$hostname".yml ); do
  echo ""
  echo "Backing up "$module" container persistent storage on "$hostname" with stamp "$stamp""
  ansible-playbook -i "$SCRIPT_DIR"/configuration/inventory_"$hostname" "$SCRIPT_DIR"/backup-restore/backup-module.yml --extra-vars "id="$module" host_id="$hostname" backup_stamp="$stamp""
done


# Start module containers
#########################

echo ""
echo "Starting module containers on "$hostname""

for module in $( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-modules_"$hostname".yml ); do
  echo ""
  echo "...starting module containers for "$module""
  /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/start-module-containers.sh -n "$hostname"
done


# Start project containers
##########################

echo ""
echo "Starting project containers on "$hostname""

for project in $( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-projects_"$hostname".yml ); do
  echo ""
  echo "...starting project containers for "$project""
  /bin/bash "$SCRIPT_DIR"/../"$project"/scripts-project/start-project-containers.sh -n "$hostname"
done


# Info - Completed
##################

echo ""
echo "Backup completed"
