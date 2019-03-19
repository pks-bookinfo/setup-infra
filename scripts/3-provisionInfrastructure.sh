#!/bin/bash

clear

echo "===================================================="
echo About to provision AWS Resources
echo ""
echo Terraform will evalate the plan then prompt for confirmation
echo at the prompt, enter 'yes'
echo The provisioning will take several minutes
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n"===================================================="' -n1 key

export START_TIME=$(date)

cd ../terraform
terraform apply

echo "===================================================="
echo "Finished provisioning AWS  "
echo "===================================================="
echo "Script start time : "$START_TIME
echo "Script end time   : "$(date)