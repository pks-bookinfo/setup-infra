LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/importPipelines.log)
exec 2>&1

YLW='\033[1;33m'
NC='\033[0m'

if [ -z $1 ]
then
    echo "Please provide the target GitHub organization as parameter:"
    echo ""
    echo "  e.g.: ./importPipelines.sh myorganization"
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

export JENKINS_USER=$(cat creds.json | jq -r '.jenkinsUser')
export JENKINS_PASSWORD=$(cat creds.json | jq -r '.jenkinsPassword')
export JENKINS_URL=$(kubectl describe svc jenkins -n cicd | grep "LoadBalancer Ingress:" | sed 's~LoadBalancer Ingress:[ \t]*~~')
export JENKINS_URL_PORT=24711

# copy the job templates to gen folder
rm ../pipelines/gen/*.xml
rm ../pipelines/gen/*.bak
cp ../pipelines/*.xml ../pipelines/gen/

# loop through a list of jobs and create them.  if already exists, delete it first
echo 'Using GitHub Org : '$ORG
echo 'Jenkins Server   : 'http://$JENKINS_URL:$JENKINS_URL_PORT
for JOB_NAME in order-service catalog-service customer-service front-end deploy-staging deploy-production; do

  # update each copy of the job template file in gen folder with GIT org name
  # NOTE: Mac requires the name of backup file as an argument, Linux does not
  OSTYPE=$(uname -s)
  if [[ "$OSTYPE" -eq Darwin ]]; then
    sed -i .bak s/ORG_PLACEHOLDER/$ORG/g ../pipelines/gen/$JOB_NAME.xml
  else
    sed -i s/ORG_PLACEHOLDER/$ORG/g ../pipelines/gen/$JOB_NAME.xml
  fi

  # determine if need to delete job first
  status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://$JENKINS_URL:$JENKINS_URL_PORT/job/$JOB_NAME/config.xml -u $JENKINS_USER:$JENKINS_PASSWORD)
  if [[ "$status_code" -eq 200 ]] ; then
    echo Removing existing job $JOB_NAME ...
    curl -s -XPOST http://$JENKINS_URL:$JENKINS_URL_PORT/job/$JOB_NAME/doDelete -u $JENKINS_USER:$JENKINS_PASSWORD -H "Content-Type:text/xml"
  fi

  # add the job
  echo Creating job $JOB_NAME ...
  curl -s -XPOST http://$JENKINS_URL:$JENKINS_URL_PORT/createItem?name=$JOB_NAME --user $JENKINS_USER:$JENKINS_PASSWORD --data-binary @../pipelines/gen/$JOB_NAME.xml -H "Content-Type:text/xml"
done
