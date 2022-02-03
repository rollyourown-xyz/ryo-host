#!/bin/bash

# host-restore.sh
# This script restores a previous backup of the persistent storage for the modules and projects deployed on a host server
# and should only be used to restore to a newly set up host server.
#
# ATTENTION!!!
# Before restoring ALL projects, the process will **delete** the state of the projects and/or modules on the control machine 
# so that the current state of the deployment will be overwritten. This will lead to a working host server no longer
# being manageable from the control node.
# THIS SHOULD NORMALLY ONLY BE DONE IN CASE A RESTORE IS NEEDED FOR DISASTER RECOVERY - e.g. AFTER A SYSTEM FAILURE


# Help and error messages
#########################

helpMessage()
{
  echo "host-restore.sh: Restore a previous backup of the persistent storage from the control node to the host"
  echo ""
  echo "Help: host-restore.sh"
  echo "Usage: ./host-restore.sh -n hostname -s stamp"
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


# Variables: Script directory, list of projects, list of modules
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECTS="$( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-projects_"$hostname".yml )"
MODULES="$( yq eval '.[]' "$SCRIPT_DIR"/backup-restore/deployed-modules_"$hostname".yml )"


# Warn the user and get confirmation
####################################

echo " "
echo "!!! CAUTION! "
echo "!!! "
echo "!!! A restore of **ALL** projects and module should normally only be carried out on a "
echo "!!! newly-configured host and will redeploy **ALL** project and module components on the host server, "
echo "!!! with a previous state of the projects and modules from a backup "
echo "!!! "
echo "!!! This is usually only needed to restore after a system failure or to move "
echo "!!! projects and modules to a new host server. "
echo " "
echo " "
echo "!!! A restore of **ALL** projects and modules should not be carried out for a host server with functioning "
echo "!!! projects! "
echo ""
echo "Do you want to restore **ALL** projects and modules from a backup on "$hostname"? (y/n)"
echo "Default is 'n'."
echo ""
echo -n "Restore backup for **ALL** projects and modules on "$hostname"? "
read -e -p "[y/n]: " RESTORE_ALL
RESTORE_ALL="${RESTORE_ALL:-"n"}"
RESTORE_ALL="${RESTORE_ALL,,}"

# Check input
while [ ! "$RESTORE_ALL" == "y" ] && [ ! "$RESTORE_ALL" == "n" ]
do
  echo "Invalid option "${RESTORE_ALL}". Please try again."
  echo -n "Restore backup for **ALL** projects and modules on "$hostname"? "
  read -e -p "[y/n]: " RESTORE_ALL
  RESTORE_ALL="${RESTORE_ALL:-"n"}"
  RESTORE_ALL="${RESTORE_ALL,,}"
done

if [ "$RESTORE_ALL" == "y" ]; do
  echo ""
  echo "!!! ARE YOU SURE? "
  echo "!!! "
  echo "!!! If your system is currently working, you will lose "
  echo "!!! the current state and may not be able to recover it! "
  echo "!!! "
  echo "!!! If you proceed, you will restore **ALL** projects and modules "
  echo "!!! on "$hostname" from backups stamped with "$stamp" "
  echo "!!! "
  echo "!!! Please confirm by typing 'yes' for the next question "
  echo "!!! Default is 'no'."
  echo ""
  echo -n "Are you sure that you want to restore a backup for ALL projects and modules on "$hostname"? "
  read -e -p "[yes/no]: " RESTORE_ALL_SURE
  RESTORE_ALL_SURE="${RESTORE_ALL_SURE:-"no"}"
  RESTORE_ALL_SURE="${RESTORE_ALL_SURE,,}"

  # Check input
  while [ ! "$RESTORE_ALL_SURE" == "y" ] && [ ! "$RESTORE_ALL_SURE" == "n" ]
  do
    echo "Invalid option "${RESTORE_ALL_SURE}". Please try again."
    echo -n "Are you sure that you want to restore a backup for ALL projects and modules on "$hostname"? "
    read -e -p "[y/n]: " RESTORE_ALL_SURE
    RESTORE_ALL_SURE="${RESTORE_ALL_SURE:-"no"}"
    RESTORE_ALL_SURE="${RESTORE_ALL_SURE,,}"
  done

  if [ "$RESTORE_ALL_SURE" == "yes" ]; do
    echo ""
    echo "!!! Please confirm the stamp of the backup to restore "
    echo "!!! " 
    echo "!!! You will be restoring ALL projects and modules on "$hostname" from backups with stamp: "$stamp" "
    echo "!!! "
    echo "!!! Please confirm by typing 'yes' for the next question "
    echo "!!! Default is 'no'."
    echo ""
    echo -n "Are you sure that the backup stamp is correct? "
    read -e -p "[yes/no]: " RESTORE_ALL_STAMP_SURE
    RESTORE_ALL_STAMP_SURE="${RESTORE_ALL_STAMP_SURE:-"no"}"
    RESTORE_ALL_STAMP_SURE="${RESTORE_ALL_STAMP_SURE,,}"

    # Check input
    while [ ! "$RESTORE_ALL_STAMP_SURE" == "y" ] && [ ! "$RESTORE_ALL_STAMP_SURE" == "n" ]
    do
      echo "Invalid option "${RESTORE_ALL_STAMP_SURE}". Please try again."
      echo -n "Are you sure that you want to restore a backup for ALL projects and modules on "$hostname"? "
      read -e -p "[y/n]: " RESTORE_ALL_STAMP_SURE
      RESTORE_ALL_STAMP_SURE="${RESTORE_ALL_STAMP_SURE:-"no"}"
      RESTORE_ALL_STAMP_SURE="${RESTORE_ALL_STAMP_SURE,,}"
    done

    if [ "$RESTORE_ALL_STAMP_SURE" == "yes" ]; do

      echo ""
      echo "Starting restore of ALL projects and modules on "$hostname""

      echo ""
      echo -n "Please enter a new version stamp for the new images to deploy, e.g. 20210101-1: "
      read -e -p "" VERSION_STAMP

      # Delete terraform state for all projects on "$hostname" on the host
      for project in $PROJECTS; do
        echo ""
        echo "Deleting terraform state for project "$project" on "$hostname""
        /bin/bash "$SCRIPT_DIR"/../"$project"/scripts-project/delete-terraform-state.sh -n "$hostname"
      done

      # Delete terraform state for all modules on the host
      for module in $MODULES; do
        echo ""
        echo "Deleting terraform state for module "$module" on "$hostname""
        /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/delete-terraform-state.sh -n "$hostname"
      done

      # Deploy all modules listed in deployed-modules file (using -r flag)
      for module in $MODULES; do
        echo ""
        echo "Deploying module "$module" on "$hostname""
        /bin/bash "$SCRIPT_DIR"/../"$module"/deploy.sh -n "$hostname" -v "$VERSION_STAMP" -r
      done

      # Deploy all projects listed in deployed-projects file (using -r and -s flags)
      for project in $PROJECTS; do
        echo ""
        echo "Deploying project "$project" on "$hostname""
        /bin/bash "$SCRIPT_DIR"/../"$project"/deploy.sh -n "$hostname" -v "$VERSION_STAMP" -r -s
      done

      # Stop project containers
      for project in $PROJECTS; do
        echo ""
        echo "Stopping project containers for "$project" on "$hostname""
        /bin/bash "$SCRIPT_DIR"/../"$project"/scripts-project/stop-project-containers.sh -n "$hostname"
      done

      # Stop module containers
      for module in $MODULES; do
        echo ""
        echo "Stopping module containers for "$module" on "$hostname""
        /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/stop-module-containers.sh -n "$hostname"
      done

      # Restore module container persistent storage
      for module in $MODULES; do
        echo ""
        echo "Restoring "$module" container persistent storage on "$hostname" with stamp "$stamp"" 
        /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/restore-module.sh -n "$hostname" -s "$stamp"
      done

      # Restore project container persistent storage
      for project in $PROJECTS; do
        echo ""
        echo "Restoring "$project" container persistent storage on "$hostname" with stamp "$stamp""
        /bin/bash "$SCRIPT_DIR"/../"$project"/scripts-module/restore-project.sh -n "$hostname" -s "$stamp"
      done

      # Start module containers
      for module in $MODULES; do
        echo ""
        echo "Starting module containers for "$module" on "$hostname""
        /bin/bash "$SCRIPT_DIR"/../"$module"/scripts-module/start-module-containers.sh -n "$hostname"
      done

      # Start project containers
      for project in $PROJECTS; do
        echo ""
        echo "Starting project containers for "$project" on "$hostname""
        /bin/bash "$SCRIPT_DIR"/../"$project"/scripts-project/start-project-containers.sh -n "$hostname"
      done

    else
      echo ""
      echo "Skipping restore of ALL projects and modules on "$hostname""
    fi

  else
    echo ""
    echo "Skipping restore of ALL projects and modules on "$hostname""
  fi

else
  echo ""
  echo "Checking whether to restore each project individually."

  for project in $PROJECTS; do

    # Get user input for whether to do individual project restore (default no)
    echo ""
    echo "Checking whether to restore "$project" project."
    echo "Default is 'n'."
    echo -n "Restore "$project" project on "$hostname"? "
    read -e -p "[y/n]: " RESTORE_PROJECT
    RESTORE_PROJECT="${RESTORE_PROJECT:-"n"}"
    RESTORE_PROJECT="${RESTORE_PROJECT,,}"
    
    # Check input
    while [ ! "$RESTORE_PROJECT" == "y" ] && [ ! "$RESTORE_PROJECT" == "n" ]
    do
      echo "Invalid option "${RESTORE_PROJECT}". Please try again."
      echo -n "Restore "$project" project on "$hostname"? "
      read -e -p "[y/n]: " RESTORE_PROJECT
      RESTORE_PROJECT="${RESTORE_PROJECT:-"n"}"
      RESTORE_PROJECT="${RESTORE_PROJECT,,}"
    done

    if [ "$RESTORE_PROJECT" == "y" ]; then

      # Check the project stamp
      echo ""
      echo "You will be restoring the project "$project" from a backup with stamp "$stamp"."
      echo "Please check the stamp "$stamp" carefully!"
      echo -n "Is the stamp "$stamp" correct for the project "$project"? (default is 'y') "
      read -e -p "[y/n]: " STAMP_CORRECT
      STAMP_CORRECT="${STAMP_CORRECT:-"y"}"
      STAMP_CORRECT="${STAMP_CORRECT,,}"

      # Check input
      while [ ! "$STAMP_CORRECT" == "y" ] && [ ! "$STAMP_CORRECT" == "n" ]
      do
        echo "Invalid option "${STAMP_CORRECT}". Please try again."
        echo -n "Is the stamp "$stamp" correct for the project "$project"? (default is 'y') "
        read -e -p "[y/n]: " STAMP_CORRECT
        STAMP_CORRECT="${STAMP_CORRECT:-"y"}"
        STAMP_CORRECT="${STAMP_CORRECT,,}"
      done

      if [ "$STAMP_CORRECT" == "y" ]; then
        /bin/bash "$SCRIPT_DIR"/../"$project"/restore.sh -n "$hostname" -s "$stamp"

      else
        # Request different backup stamp
        echo ""
        echo "Please enter the stamp for the backup of project "$project" to restore."
        echo "Please double-check you are entering the correct stamp."
        echo ""
        echo -n "What is the stamp for the backup of project "$project" to restore? "
        read -e -p "" DIFFERENT_STAMP
        echo ""
        echo "Restoring the project "$project" to "$hostname" from a backup with stamp "$DIFFERENT_STAMP""
        /bin/bash "$SCRIPT_DIR"/../"$project"/restore.sh -n "$hostname" -s "$DIFFERENT_STAMP"
      fi

    else
      echo ""
      echo "Skipping "$project" project restore."
    fi
  done
fi

# Info - Completed
##################

echo ""
echo "Restore completed"
