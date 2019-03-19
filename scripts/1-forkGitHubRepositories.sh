#!/bin/bash

SOURCE_GIT_ORG=pks-bookinginfo
LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/forkGitHubRepositories.log)
exec 2>&1

YLW='\033[1;33m'
NC='\033[0m'

type hub &> /dev/null

if [ $? -ne 0 ]
then
    echo "Please install the 'hub' command: https://hub.github.com/"
    exit 1
fi

if [ -z $1 ]
then
    echo "Please provide the target GitHub organization as parameter:"
    echo ""
    echo "  e.g.: ./forkGitHubRepositories.sh myorganization"
    echo ""
    exit 1
else
    ORG=$1
fi

HTTP_RESPONSE=`curl -s -o /dev/null -I -w "%{http_code}" https://github.com/$ORG`

if [ $HTTP_RESPONSE -ne 200 ]
then
    echo "GitHub organization doesn't exist - https://github.com/$ORG - HTTP status code $HTTP_RESPONSE"
    exit 1
fi

echo "===================================================="
echo About to fork github repositories with these parameters:
echo ""
echo "Source : https://github.com/$SOURCE_GIT_ORG"
echo "Target : https://github.com/$ORG"
echo ""
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n====================================================' -n1 key

declare -a repositories=("bookinfo-ratings" "bookinfo-details" "bookinfo-reviews" "bookinfo-productpage" "deploy-staging" "deploy-production")

rm -rf ~/workspace/$ORG/repositories
mkdir ~/workspace/$ORG/repositories
cd ~/workspace/$ORG/repositories

for repo in "${repositories[@]}"
do
    echo -e "${YLW}Cloning https://github.com/$SOURCE_GIT_ORG/$repo ${NC}"
    git clone -q "https://github.com/$SOURCE_GIT_ORG/$repo"
    cd $repo
    echo -e "${YLW}Forking $repo to $ORG ${NC}"
    hub fork --org=$ORG
    cd ..
    echo -e "${YLW}Done. ${NC}"
done

cd ~/workspace/$ORG/
rm -rf repositories
mkdir repositories
cd repositories

for repo in "${repositories[@]}"
do
    TARGET_REPO="http://github.com/$ORG/$repo"
    echo -e "${YLW}Cloning $TARGET_REPO ${NC}"
    git clone -q $TARGET_REPO
    echo -e "${YLW}Done. ${NC}"
done
