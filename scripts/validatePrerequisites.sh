#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/validatePrerequisites.log)
exec 2>&1

echo "----------------------------------------------------"
echo Validating pre-requisites
echo "----------------------------------------------------"

echo -n "Validating jq utility ... "
type jq &> /dev/null
if [ $? -ne 0 ]
then
    echo "Error"
    echo ">>> Missing 'jq' json query utility"
    echo ""
    exit 1
fi
echo "ok"

echo -n "Validating hub utility ... "
type hub &> /dev/null
if [ $? -ne 0 ]
then
    echo "Error"
    echo ">>> Missing git 'hub' utility"
    echo ""
    exit 1
fi
echo "ok"

echo -n "Validating kubectl ... "
type kubectl &> /dev/null
if [ $? -ne 0 ]
then
    echo "Error"
    echo ">>> Missing 'kubectl'"
    echo ""
    exit 1
fi
echo "ok"

echo -n "Validating AWS cli ... "
type aws &> /dev/null
if [ $? -ne 0 ]
then
    echo "Error"
    echo ">>> Missing 'aws CLI'"
    echo ""
    exit 1
fi
echo "ok"

echo -n "Validating terraform ... "
type aws &> /dev/null
if [ $? -ne 0 ]
then
    echo "Error"
    echo ">>> Missing 'terraform'"
    echo ""
    exit 1
fi
echo "ok"

echo -n "Validating aws-iam-authenticator utility ... "
type aws-iam-authenticator &> /dev/null
if [ $? -ne 0 ]
then
    echo "Error"
    echo ">>> Missing 'aws-iam-authenticator'"
    echo ""
    exit 1
fi
echo "ok"

echo -n "Validating AWS cli is configured ... "
export AWS_STS_USER=$(aws sts get-caller-identity | jq -r '.UserId')
if [ -z $AWS_STS_USER ]
then
    echo ">>> Unable to locate credentials. You can configure credentials by running \"aws configure\"."
    echo ""
    exit 1
fi
echo "...ok - AWS cli is configured with UserId: $AWS_STS_USER"

echo "----------------------------------------------------"
echo Validation of pre-requisites complete.
echo "----------------------------------------------------"