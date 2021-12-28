#!/bin/bash

#Migrates parameter context from one environment to another
# set -e #Exit if any command fails
output_file="$1"# Read agruments
src_env="$2"
tgt_env="$3"
#Set Global Defaults
[ -z "$FLOW_NAME" ] && FLOW_NAME="ConvertCSV2JSON"
case "$src_env" in
dev)
    SRC_PROPS="./env/nifi-dev.properties";;
*)
    echo "Usage: $(basename "$0")    "; exit 1;;
esac
case "$tgt_env" in
prod)
    TGT_PROPS="./env/nifi-prod.properties";;
*)
    echo "Usage: $(basename "$0")    "; exit 1;;
esac
echo "Migrating parameter context from '${FLOW_NAME}' to ${tgt_env}...."
echo "==============================================================="
echo -n "Listing parameter contexts from environment "$src_env"....."
param_context_id=$(./nifi-toolkit-1.15.0/bin/cli.sh nifi list-param-contexts -ot json -p "$SRC_PROPS" | jq '.parameterContexts[0].id')
echo "[\033[0;32mOK\033[0m]"
echo -n "Exporting parameter context from environemnt ${src_env}......"
./nifi-toolkit-1.15.0/bin/cli.sh nifi export-param-context -pcid ${param_context_id} -o ${output_file} -p "$SRC_PROPS" > /dev/null
echo "[\033[0;32mOK\033[0m]"
echo -n "Importing parameter context to environment ${tgt_env}........"
./nifi-toolkit-1.15.0/bin/cli.sh nifi import-param-context -i ${output_file} -p "$TGT_PROPS" > /dev/null
echo "[\033[0;32mOK\033[0m]"
echo "Migration of parameter context from ${src_env} to ${tgt_env} successfully finished!"
exit 0