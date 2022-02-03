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


# Variables: Script directory, list of projects, list of modules
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECTS="$( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-projects_"$hostname".yml )"
MODULES="$( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-modules_"$hostname".yml )"


# Ask whether to backup all projects and modules
echo ""
echo "Back up all projects and modules on "$hostname"?"
echo "Projects deployed on the host are: "$PROJECTS""
echo "Modules deployed on the host are: "$MODULES""
echo ""
echo "To back up all projects and modules on the host "$hostname", then answer 'y' (the default)."
echo "If you choose 'n', you will be able to select whether to back up each project individually (with its modules)."
echo ""
echo -n "Back up all projects and modules on "$hostname"? "
read -e -p "[y/n]: " BACKUP_ALL
BACKUP_ALL="${BACKUP_ALL:-"y"}"
BACKUP_ALL="${BACKUP_ALL,,}"

# Check input
while [ ! "$BACKUP_ALL" == "y" ] && [ ! "$BACKUP_ALL" == "n" ]
do
  echo "Invalid option "${BACKUP_ALL}". Please try again."
  echo -n "Back up all projects and modules on "$hostname"? "
  read -e -p "[y/n]: " BACKUP_ALL
  BACKUP_ALL="${BACKUP_ALL:-"y"}"
  BACKUP_ALL="${BACKUP_ALL,,}"
done

if [ "$BACKUP_ALL" == "y" ]; then
  echo ""
  echo "Backing up all projects and modules."

  echo ""
  echo "Stopping project containers on "$hostname""
  for project in $PROJECTS; do
    /bin/bash "$SCRIPT_DIR"/../"$project"/scripts-project/stop-project-containers.sh -n "$hostname"
  done

  echo ""
  echo "Stopping module containers on "$hostname""
  for module in $MODULES; do
    /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/stop-module-containers.sh -n "$hostname"
  done

  echo ""
  echo "Backing up all project container persistent storage on "$hostname" with stamp "$stamp""
  for project in $PROJECTS; do
    /bin/bash "$SCRIPT_DIR"/../"$project"/scripts-module/backup-project.sh -n "$hostname" -s "$stamp"
  done

  echo ""
  echo "Backing up all module container persistent storage on "$hostname" with stamp "$stamp""
  for module in $MODULES; do
    /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/backup-module.sh -n "$hostname" -s "$stamp"
  done

  echo ""
  echo "Starting module containers on "$hostname""
  for module in $MODULES; do
    /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/start-module-containers.sh -n "$hostname"
  done
  
  echo ""
  echo "Starting project containers on "$hostname""
  for project in $PROJECTS; do
    /bin/bash "$SCRIPT_DIR"/../"$project"/scripts-project/start-project-containers.sh -n "$hostname"
  done

else
  echo ""
  echo "Checking for each project."

  for project in $PROJECTS; do

    # Get user input for whether to do individual project backup (default no)
    echo ""
    echo "Checking whether to back up "$project" project."
    echo "Default is 'n'."
    echo -n "Back up "$project" project? "
    read -e -p "[y/n]: " BACKUP_PROJECT
    BACKUP_PROJECT="${BACKUP_PROJECT:-"n"}"
    BACKUP_PROJECT="${BACKUP_PROJECT,,}"
    
    # Check input
    while [ ! "$BACKUP_PROJECT" == "y" ] && [ ! "$BACKUP_PROJECT" == "n" ]
    do
      echo "Invalid option "${BACKUP_PROJECT}". Please try again."
      echo -n "Back up "$project" project (default is 'n')? "
      read -e -p "[y/n]: " BACKUP_PROJECT
      BACKUP_PROJECT="${BACKUP_PROJECT:-"n"}"
      BACKUP_PROJECT="${BACKUP_PROJECT,,}"
    done

    if [ "$BACKUP_PROJECT" == "y" ]; then
      /bin/bash "$SCRIPT_DIR"/../"$project"/scripts-project/backup-project.sh -n "$hostname" -s "$stamp"
    else
      echo ""
      echo "Skipping "$project" project backup."
    fi
  done
  
  echo ""
  echo "Checking for each module."
  
  for module in $MODULES; do

    # Get user input for whether to do individual module backup (default no)
    echo ""
    echo "Checking whether to back up "$module" module."
    echo "Default is 'n'."
    echo -n "Back up "$module" module? "
    read -e -p "[y/n]: " BACKUP_MODULE
    BACKUP_MODULE="${BACKUP_MODULE:-"n"}"
    BACKUP_MODULE="${BACKUP_MODULE,,}"
    
    # Check input
    while [ ! "$BACKUP_MODULE" == "y" ] && [ ! "$BACKUP_MODULE" == "n" ]
    do
      echo "Invalid option "${BACKUP_MODULE}". Please try again."
      echo -n "Back up "$module" module (default is 'n')? "
      read -e -p "[y/n]: " BACKUP_MODULE
      BACKUP_MODULE="${BACKUP_MODULE:-"n"}"
      BACKUP_MODULE="${BACKUP_MODULE,,}"
    done

    if [ "$BACKUP_MODULE" == "y" ]; then
      /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/backup-module.sh -n "$hostname" -s "$stamp"
    else
      echo ""
      echo "Skipping "$module" module backup."
    fi
  done
fi

# Info - Completed
##################

echo ""
echo "Backup completed"
