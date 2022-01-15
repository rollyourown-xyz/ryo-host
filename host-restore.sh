#!/bin/bash

# host-restore.sh
# This script restores a previous backup of the persistent storage for the modules and projects deployed on a host server
#
# ATTENTION!!!
# Before restoring, the process will **delete** the persistent storage on the host so that the current state of the deployment will 
# be overwritten by the backup and the system will be restored to a previous state
# THIS SHOULD NORMALLY ONLY BE DONE IN CASE A RESTORE IS NEEDED FOR DISASTER RECOVERY - e.g. AFTER A SYSTEM FAILURE


# Help and error messages
#########################

helpMessage()
{
  echo "host-restore.sh: Restore a previous backup of the persistent storage from the control node to the host"
  echo ""
  echo "Help: host-restore.sh"
  echo "Usage: ./host-restore.sh -n hostname"
  echo "Flags:"
  echo -e "-n hostname \t\t(Mandatory) Name of the host to which to restore the project container persistent storage"
  echo -e "-s stamp \t\t(Mandatory) A stamp (e.g. date, time, name) to identify the backup to restore to the host server"  
  echo -e "-h \t\t\tPrint this help message"
  echo ""
  exit 1
}

errorMessage()
{
  echo "Invalid option or input variables are missing"
  echo "Use \"./host-restore.sh -h\" for help"
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


# Warn the user and get confirmation
####################################

echo " "
echo "!!! CAUTION! "
echo "!!! "
echo "!!! A restore will overwrite the state of all project and "
echo "!!! module deployments on the "$hosname" host server with "
echo "!!! a previous state from the backup "
echo "!!! "
echo "!!! This is usually only needed to restore after a system failure "
echo " "
echo "Do you want to restore a backup? (y/n)"
echo "Default is 'n'."
echo -n "Restore backup? "
read -e -p "[y/n]:" RESTORE_BACKUP
RESTORE_BACKUP="${RESTORE_BACKUP:-"n"}"
RESTORE_BACKUP="${RESTORE_BACKUP,,}"

if [ ! "$RESTORE_BACKUP" == "y" ] && [ ! "$RESTORE_BACKUP" == "n" ]; then
  echo "Invalid option "${RESTORE_BACKUP}". Exiting"
  exit 1

elif [ "$RESTORE_BACKUP" == "n" ]; then
  echo "Exiting"
  exit 1

else
  echo ""
  echo "!!! ARE YOU SURE? "
  echo "!!! "
  echo "!!! If your system is currently working, you will lose "
  echo "!!! the current state and may not be able to recover it! "
  echo "!!! "
  echo "!!! If you proceed, you will restore data on "$hosname" "
  echo "!!! from backups stamped with "$stamp" "
  echo "!!! "
  echo "!!! Please confirm by typing 'yes' for the next question "
  echo "!!! Default is 'no'."
  echo ""
  echo -n "!!! Are you sure that you want to restore a backup? "
  read -e -p "[yes/no]:" RESTORE_BACKUP_SURE
  RESTORE_BACKUP_SURE="${RESTORE_BACKUP:-"no"}"
  RESTORE_BACKUP_SURE="${RESTORE_BACKUP,,}"
  
  if [ ! "$RESTORE_BACKUP_SURE" == "yes" ] && [ ! "$RESTORE_BACKUP_SURE" == "no" ]; then
    echo "Invalid option "${RESTORE_BACKUP_SURE}". Exiting"
    exit 1

  elif [ "$RESTORE_BACKUP_SURE" == "no" ]; then
    echo "Exiting"
    exit 1
  
  else
    echo ""
    echo "!!! Please confirm the stamp of the backup to restore "
    echo "!!! " 
    echo "!!! You will be restoring from backups with stamp: "$stamp" "
    echo "!!! "
    echo "!!! Please confirm by typing 'yes' for the next question "
    echo "!!! Default is 'no'."
    echo ""
    echo -n "!!! Are you sure that the backup stamp is correct? "
    read -e -p "[yes/no]:" RESTORE_BACKUP_STAMP_SURE
    RESTORE_BACKUP_STAMP_SURE="${RESTORE_BACKUP:-"no"}"
    RESTORE_BACKUP_STAMP_SURE="${RESTORE_BACKUP,,}"
    
    if [ ! "$RESTORE_BACKUP_STAMP_SURE" == "yes" ] && [ ! "$RESTORE_BACKUP_STAMP_SURE" == "no" ]; then
      echo "Invalid option "${RESTORE_BACKUP_STAMP_SURE}". Exiting"
      exit 1

    elif [ "$RESTORE_BACKUP_STAMP_SURE" == "no" ]; then
      echo "Exiting"
      exit 1

    fi
  fi
fi


# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


# Info - Starting
#################

echo ""
echo "Starting restore on "$hostname""


# Stop project containers
##########################

echo ""
echo "Stopping project containers on "$hostname""

for project in $( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-projects_"$hostname".yml ); do
  echo "DEBUG /bin/bash "$SCRIPT_DIR"/../"$project"/scripts-project/stop-project-containers.sh -n "$hostname""
  #/bin/bash "$SCRIPT_DIR"/../"$project"/scripts-project/stop-project-containers.sh -n "$hostname"
done


# Stop module containers
########################

echo ""
echo "Stopping module containers on "$hostname""

for module in $( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-modules_"$hostname".yml ); do
  echo "DEBUG /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/stop-module-containers.sh -n "$hostname""
  #/bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/stop-module-containers.sh -n "$hostname"
done


# Restore module container persistent storage
#############################################

echo ""
echo "Restoring module container persistent storage on "$hostname" with stamp "$stamp""

for module in $( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-modules_"$hostname".yml ); do
  echo "Restoring "$module" container persistent storage on "$hostname" with stamp "$stamp"" 
  echo "DEBUG ansible-playbook -i "$SCRIPT_DIR"/configuration/inventory_"$hostname" "$SCRIPT_DIR"/backup-restore/restore-module-or-project.yml --extra-vars "id="$module" host_id="$hostname" backup_stamp="$stamp"""
  #ansible-playbook -i "$SCRIPT_DIR"/configuration/inventory_"$hostname" "$SCRIPT_DIR"/backup-restore/restore-module-or-project.yml --extra-vars "id="$module" host_id="$hostname" backup_stamp="$stamp""
done


# Restore project container persistent storage
##############################################

echo ""
echo "Restoring project container persistent storage on "$hostname" with stamp "$stamp""

for project in $( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-projects_"$hostname".yml ); do
  echo "Restoring "$project" container persistent storage on "$hostname" with stamp "$stamp""
  echo "DEBUG ansible-playbook -i "$SCRIPT_DIR"/configuration/inventory_"$hostname" "$SCRIPT_DIR"/backup-restore/restore-module-or-project.yml --extra-vars "id="$project" host_id="$hostname" backup_stamp="$stamp"""
  #ansible-playbook -i "$SCRIPT_DIR"/configuration/inventory_"$hostname" "$SCRIPT_DIR"/backup-restore/restore-module-or-project.yml --extra-vars "id="$project" host_id="$hostname" backup_stamp="$stamp""
done


# Start module containers
#########################

echo ""
echo "Starting module containers on "$hostname""

for module in $( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-modules_"$hostname".yml ); do
  echo "DEBUG /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/start-module-containers.sh -n "$hostname""
  #/bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/start-module-containers.sh -n "$hostname"
done


# Start project containers
##########################

echo ""
echo "Starting project containers on "$hostname""

for project in $( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-projects_"$hostname".yml ); do
  echo "DEBUG /bin/bash "$SCRIPT_DIR"/../"$project"/scripts-project/start-project-containers.sh -n "$hostname""
  #/bin/bash "$SCRIPT_DIR"/../"$project"/scripts-project/start-project-containers.sh -n "$hostname"
done


# Info - Completed
##################

echo ""
echo "Restore completed"

