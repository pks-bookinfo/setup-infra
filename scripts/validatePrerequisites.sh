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

echo "----------------------------------------------------"
echo Validation of pre-requisites complete.
echo "----------------------------------------------------"