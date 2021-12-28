#!/bin/bash

#Merges parameter context from one environment with another
#Adds missing parameters from one environment that are missing
#in another environment

#Exit if any command fails
set -e
# Read agruments
output_file="$1"
src_env="$2"
tgt_env="$3"
pc_id="$4"
#Set Global Defaults
[ -z "$FLOW_NAME" ] && FLOW_NAME="ConvertCSV2JSON"
case "$src_env" in
dev)
    SRC_PROPS="./env/nifi-dev.properties";;
*)
    echo "Usage: $(basename "$0")     "; exit 1;;
esac
case "$tgt_env" in
prod)
    TGT_PROPS="./env/nifi-prod.properties";;
*)
    echo "Usage: $(basename "$0")    "; exit 1;;
esac
echo "Merging parameter context from '${FLOW_NAME}' to ${tgt_env}...."
echo "==============================================================="
echo -n "Listing parameter contexts from environment "$src_env"....."
param_context_id=$(./nifi-toolkit-1.13.2/bin/cli.sh nifi list-param-contexts -ot json -p "$SRC_PROPS" | jq '.parameterContexts[0].id')
echo "[\033[0;32mOK\033[0m]"
echo -n "Exporting parameter context from environment "${src_env}"......"
./nifi-toolkit-1.13.2/bin/cli.sh nifi export-param-context -pcid ${param_context_id} -o ${output_file} -p "$SRC_PROPS" > /dev/null
echo "[\033[0;32mOK\033[0m]"
echo -n "Merging parameter context to environment "${tgt_env}"........"
./nifi-toolkit-1.13.2/bin/cli.sh nifi merge-param-context -pcid ${pc_id} -i ${output_file} -p "$TGT_PROPS" > /dev/null
echo "[\033[0;32mOK\033[0m]"
echo "Merging parameter context from "${src_env}" with "${tgt_env}" successfully finished!"
exit 0