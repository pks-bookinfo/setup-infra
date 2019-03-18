# Overview - Demo Setup

This repo has various scripts to make the Dynatrace Kubernetes demo application cloud hosted Kubernetes, Docker registry, Jenkins, Istio, and demo CI/CD pipelines.

Footnotes:
* Currently, these setup scripts support only AWS.  The plan is to support Azure, RedHat, and Cloud Foundry PaaS platforms.
* Demo application is based on Eberhard Wolff’s sample Kubernetes application: https://github.com/ewolff/microservice-kubernetes
* Terraform scripts are based from the full example in from https://github.com/cloudposse/terraform-aws-eks-cluster
* The docker image is from: https://hub.docker.com/r/keptn/jenkins

# Laptop - Pre-requisites

All the install scripts are written in bash and use linux utilities.  
* If you are using a Mac laptop, you just use your mac terminal.
* If you are using Windows, you will need to install windows subsystem for Linux.  https://docs.microsoft.com/en-us/windows/wsl/install-win10
* You may also provision a EC2 Linux instance and ssh into that

# Dynatrace - Pre-requisites

Assumes you will use a trial SaaS dynatrace tenant from https://www.dynatrace.com/trial 

You will need for the installation the following configuration:
* Dynatrace environment/tenant ID (deploy dynatrace --> setup PaaS Integration)
* Dynatrace PaaS token (settings --> integration --> Dynatrace API)
* Dynatrace API token had to have minimum permissions to:
  * Access problem event feed, metrics and topology
  * read configuration
  * write configuration

# AWS Setup - Pre-requisites

* AWS account used to provison PaaS resources.  Highly recommend, just signing up for free trial as to have full admin rights and to not cause any issues with your enterprise account.  https://aws.amazon.com/free/

# PC Setup - Pre-requisites

The following programs/utilities are in place on your PC
* terraform - used to provision PaaS resources
* AWS cli - for local testing and queries.  
* kubectl - cli to manage kubernetes
* jq - used in script to parse JSON script output
* hub - used to clone and fork repos
* an IDE such as Visual Studio Code is also recommended (https://code.visualstudio.com/)

## 1) install AWS cli and initialize credentials file

https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html

### Mac, Linux or Unix
1. in ~ run these commands
```
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
```
2. get your credentials https://console.aws.amazon.com/iam/home?#/security_credentials
3. run ``` aws --version``` to verify then ```aws configure``` to input default credentials
4. review credentials file ```cat ~/.aws/credentials```.  You should see something like:
```
[default]
aws_access_key_id = ABCD
aws_secret_access_key = abc123
```

## 2) install Terraform
See:  https://learn.hashicorp.com/terraform/getting-started/install.html#installing-terraform

### Mac
1. download package - https://www.terraform.io/downloads.html
2. extract and copy to ~
3. add to ~/.profile ```export PATH="$PATH:~"``` 
4. run ```source ~/.profile```
5. test by running ```terraform``` and you should see cli help output 

### Linux
1. download package - https://www.terraform.io/downloads.html
2. extract and copy terraform ~/bin
3. add to ~/.bash_profile ```export PATH="$PATH:~/bin"``` 
4. run ```source ~/.bash_profile```
5. test by running ```terraform``` and you should see cli help output

## 3) Install aws-iam-authenticator

Amazon EKS uses IAM to provide authentication to your Kubernetes cluster through the AWS IAM Authenticator for Kubernetes. See install instructions here: https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html

### Mac
run these commands to install and verify
```
cd ~
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/darwin/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator
echo 'export PATH=$HOME/bin:$PATH' >> ~/.profile
source ~/.profile
aws-iam-authenticator
```
### Linux
run these commands to install and verify
```
cd ~
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bash_profile
source ~/.bash_profile
aws-iam-authenticator
```

## 4) Install jq
https://stedolan.github.io/jq/

### Mac
1. run ```brew install jq```
2. test by running ```jq``` and you should see cli help output 

### Linux 
#### rhel, centos
1. run ```sudo yum install jq```
2. test by running ```jq``` and you should see cli help output
#### ubuntu, debian
1. run ```sudo apt-get install jq```
2. test by running ```jq``` and you should see cli help output

## 5) Install hub
https://hub.github.com/

### Mac
1. run ```brew install hub```
2. test by running ```hub``` and you should see cli help output 

### Linux
#### rhel, centos
1. run ```sudo yum install hub```
2. test by running ```hub``` and you should see cli help output
#### ubuntu, debian
1. run ```sudo apt-get install hub```
2. test by running ```hub``` and you should see cli help output

## 6) Install kubectl
https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl

### Mac
1. run ```brew install kubernetes-cli```
### Linux
#### rhel, centos
1. run ```sudo yum install kubectl```
#### ubuntu, debian
1. run ```sudo apt-get install kubectl```

Test by running ```kubectl version``` and you should see cli help output.
Once we setup the cluster, you will configure and test using the kubectl cli.

# AWS Setup - Provision the Environment 

## 1) Clone this demo github repositories locally

Run these commands in your shell.  NOTE: This example puts it in home dev folder, but that is just a suggested location.
```
cd ~
mkdir dev
cd dev
git clone https://github.com/dt-kube-demo/demo-infrastructure.git
cd demo-infrastructure
```

## 2) From the command shell, run terraform to provision your AWS EKS cluster

1. within the ```demo-infrastructure``` folder, run ```cd terraform``` to get into the terraform sub-folder
1. run ```terraform init``` to initialize terraform. It will download dependant files
2. run ```terraform show``` to confirms what terraform will provision
3. run ```terraform apply``` to make the AWS resources. Takes about 10-15 minutes

To verify the creation, login to AWS and review the following within 'N. Virginia (us-east-1)' region.
* EC2 - 2 instances called 'acm-demo-app-workers'
* VPC - 1 cluster called 'acm-demo-app'
* EKS - 1 cluster called 'acm-demo-app-cluster'
* IAM - 1 user called 'acm-demo-app-cicd-user'

To verify the Dynatrace monitoring, login and view the 'hosts" page. You should see both cluster nodes. 

**** This extra step is required but will be automated soon ****

You need to make a access key for the 'acm-demo-app-cicd-user' that was made and add this to your AWS cli config.  To do this:
1. in AWS console, goto IAM and find the 'acm-demo-app-cicd-user' user. 
1. in the 'security credentials' tab, click on 'create access key' button.  Save the access key and secret key
1. edit your ```./aws/credentials``` file add this section with your key values.  Keep the default section which is your personal ID secret.
```
[default]
aws_access_key_id = ABC
aws_secret_access_key = abc123

[acm-demo-app-cicd-user]
aws_access_key_id = DEF
aws_secret_access_key = def456
```

## 3) Connect to the EKS Cluster

Terraform makes a file called 'kubeconfig-acm-demo-app-cluster.yaml' in the terraform subdirectory.
The YAML file will be unique for your environment.
Run these commands to make it the file used by kubectl
```
cp ~/.kube/config ~/.kube/config.bak
cp kubeconfig-acm-demo-app-cluster.yaml ~/.kube/config
```

Run kubectl and the generated file run.  The YAML file will be unique for your environment
1. to see nodes ```kubectl get nodes```  You should see 2.
2. to see pods ```kubectl get pods --all-namespaces```  You should see pods in kube-system namespace

## 4) Clone the demo app github repositories

1. make a github org
1. within the ```demo-infrastructure``` folder, run ```cd scripts``` to get into the scripts sub-folder
1. run ```./1-forkGitHubRepositories.sh <GIT ORG NAME>``` this will fork the demo app repos into you GitHub Org
1. verify by looking your github org in a browser 
1. verify local files by running this command in shell ```ls -l demo-infrastructure/repositories```

## 5) Run the script that will save your unique credentials

1. within the ```demo-infrastructure``` folder, run ```cd scripts``` to get into the scripts sub-folder
2. run ```./2-defineCredentials.sh``` this will prompt you for values that the setup script expects
3. verify the output of the values you entered

## 6) Run the script that will setup the demo environment

1. within the ```demo-infrastructure``` folder, run ```cd scripts``` to get into the scripts sub-folder
2. run ```./3-setupInfrastructure.sh``` this first verify you have pre-requisites and output the install.  It will take about 5-8 minutes to complete

To verify that it created
* Jenkins -- use the URL and credentials in the script log output.  You should see several jobs listed one you login.
* ECS -- view pods. ```kubectl get pods --all-namespaces``` jenkins-deployment pod should be in 'Running' status within the cicd namespace. Pods in istio-system namespace they should be in 'Running' or 'Completed' status.
* ECS -- view services. ```kubectl get svc --all-namespaces``` There should be an external IP for jenkins and istio-ingressgateway.

# ******  NOTICE: This will be addressed soon ******

The current Jenkins setup uses ECR docker login credentials that only last 12 hours.  So you will have to get a new password and update the credentials if this happens.  Here are the steps

1. at PC run ```aws ecr get-login --profile acm-demo-app-cicd-user --region us-east-1``` copy the LONG password field
1. in Jenkins, 
  * click on 'credentials' 
  * click on the '(global)' hyperlink on one of the rows
  * click the edit icon on the far right side of 'Token used by Jenkins to push to the container registry' row
  * update the 'password' field and click save 

# Cleanup

1. within the ```demo-infrastructure``` folder, run ```cd terraform``` to get into the scripts sub-folder
1. run ```terraform destroy``` to remove the AWS resources. It takes 10+ minutes.  You may need to run it twice.
1. Ensure that cluster, VPC, and EC2 and S3 resources are removed


# Reference
https://learn.hashicorp.com/terraform/getting-started 
https://www.terraform.io/docs/providers/aws/index.html
https://learn.hashicorp.com/terraform/aws/eks-intro
https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/

