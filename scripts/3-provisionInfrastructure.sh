#!/bin/bash

clear

echo "===================================================="
echo About to provision AWS Resources
echo ""
echo Terraform will evalate the plan then prompt for confirmation
echo at the prompt, enter 'yes'
echo The provisioning will take several minutes
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n====================================================' -n1 key

export START_TIME=$(date)

cd ../terraform
terraform init
terraform apply

echo "===================================================="
echo "Finished provisioning AWS  "
echo "===================================================="
echo "Script start time : "$START_TIME
echo "Script end time   : "$(date)

echo ""
echo "===================================================="
echo "Copying generated terraform file into kubectl config"

cp kubeconfig-*-cluster.yaml ~/.kube/config

# validate that have kubectl configured first
cd ../scripts
./validateKubectl.sh
if [ $? -ne 0 ]
then
  exit 1
fi