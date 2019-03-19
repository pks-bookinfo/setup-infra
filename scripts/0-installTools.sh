#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/installTools.log)
exec 2>&1

# save current directory for later in script
CURRENT_DIR=$(pwd)

# change to users home directory
cd ~

clear
echo "===================================================="
echo About to install required tools into:
pwd
echo ""
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n====================================================' -n1 key

# executable file will be copied here
mkdir -p $HOME/bin

echo "----------------------------------------------------"
echo "Downloading git 'hub' utility ..."
rm -rf hub-linux-amd64-2.10.0*
wget https://github.com/github/hub/releases/download/v2.10.0/hub-linux-amd64-2.10.0.tgz
tar -zxvf hub-linux-amd64-2.10.0.tgz
echo "Installing git 'hub' utility ..."
sudo ./hub-linux-amd64-2.10.0/install

echo "----------------------------------------------------"
echo "Installing git 'jq' utility ..."
sudo yum -y install jq

echo "----------------------------------------------------"
echo "Downloading 'kubectl' ..."
# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html#install-kubectl-linux
rm kubectl
curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/kubectl 
echo "Installing 'kubectl' ..."
chmod +x ./kubectl
cp ./kubectl $HOME/bin/kubectl

echo "----------------------------------------------------"
echo "Downloading 'aws-iam-authenticator' ..."
# https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
rm aws-iam-authenticator
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator
echo "Installing 'aws-iam-authenticator' ..."
chmod +x ./aws-iam-authenticator
cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator 

echo "----------------------------------------------------"
echo "Downloading 'terraform' ..."
rm -rf terraform_0.11.13_linux_amd64*
rm -rf terraform
wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
echo "Installing 'terraform' ..."
unzip terraform_0.11.13_linux_amd64.zip
sudo cp terraform $HOME/bin/terraform

# final setup
export PATH=$HOME/bin:$PATH
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

# run a final validation
cd $CURRENT_DIR
./validatePrerequisites.sh
