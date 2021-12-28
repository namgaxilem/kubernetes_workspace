#!/bin/bash

#Deploys development flow to target environment
#Exit if any command fails
set -e
# Read agruments
version="$1"
target_env="$2"
target_pgid="$3"
#Set Global Defaults
[ -z "$FLOW_NAME" ] && FLOW_NAME="ConvertCSV2JSON"
case "$target_env" in
dev)
    DEV_PROPS="./env/nifi-dev.properties";;
prod)
    PROD_PROPS="./env/nifi-prod.properties";;
*)
    echo "Usage: $(basename "$0")    "; exit 1;;
esac
echo "Deploying version ${version} of '${FLOW_NAME}' to ${target_env}"
echo "==============================================================="
echo -n "Checking current version..."
current_version=$(./nifi-toolkit-1.13.2/bin/cli.sh nifi pg-get-version -pgid "$target_pgid" -ot json -p "$PROD_PROPS" | jq '.versionControlInformation.version')
echo "[\033[0;32mOK\033[0m]"
echo "Flow ${FLOW_NAME} in ${target_env} is currently at version: ${current_version}"
echo -n "Deploying flow........."
./nifi-toolkit-1.13.2/bin/cli.sh nifi pg-change-version -pgid "$target_pgid" -fv $version -p "$PROD_PROPS" > /dev/null
echo "[\033[0;32mOK\033[0m]"
echo -n "Enabling services......"
./nifi-toolkit-1.13.2/bin/cli.sh nifi pg-enable-services -pgid "$target_pgid" -p "$PROD_PROPS" > /dev/null
echo "[\033[0;32mOK\033[0m]"
echo  -n "Starting process group...."
./nifi-toolkit-1.13.2/bin/cli.sh nifi pg-start -pgid "$target_pgid" -p "$PROD_PROPS" > /dev/null
echo "[\033[0;32mOK\033[0m]"
echo "Flow deployment successfully finished, ${target_env} is now at version ${version}!"
exit 0