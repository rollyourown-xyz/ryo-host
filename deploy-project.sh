#!/bin/bash

helpMessage()
{
   echo "deploy-project.sh: Use terraform to deploy project"
   echo ""
   echo "Help: deploy-project.sh"
   echo "Usage: ./deploy-project.sh -v version"
   echo "Flags:"
   echo -e "-v version \t\tVersion stamp for images to deploy, e.g. 20210101-1"
   echo -e "-h \t\t\tPrint this help message"
   echo ""
   exit 1
}

errorMessage()
{
   echo "Invalid option or input variables are missing"
   echo "Use \"./deploy-project.sh -h\" for help"
   exit 1
}

while getopts v:h flag
do
    case "${flag}" in
        v) version=${OPTARG};;
        h) helpMessage ;;
        ?) errorMessage ;;
    esac
done

if [ -z "$version" ]
then
   errorMessage
fi

echo "Deploying project using images with version=$version"
echo ""
echo "Executing command: terraform -chdir=project-deployment init"
echo ""
terraform -chdir=project-deployment init
echo ""
echo "Executing command: terraform -chdir=project-deployment apply. Check the plan before confirming apply"
echo ""
terraform -chdir=project-deployment apply -var="image_version=$version"
echo ""
echo "Completed"
