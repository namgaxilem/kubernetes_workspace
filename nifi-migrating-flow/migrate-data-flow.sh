# chsh -s /bin/bash root

#Exit if any command fails
set -e

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
echo "JAVA_HOME $JAVA_HOME"

source_env="dev"
target_env="sit"
source_bucket_name="dev-bucket"
source_flow_name="test-databrick"
source_flow_version="2"
target_bucket_name="sit-bucket"
target_flow_name="sit_databricks_flow"

#Set up for source environment
/opt/nifi-toolkit/nifi-toolkit-1.15.1/bin/cli.sh session set nifi.props /home/nam/migrate-data-flow-between-environment/dev/nifi.properties
/opt/nifi-toolkit/nifi-toolkit-1.15.1/bin/cli.sh session set nifi.reg.props /home/nam/migrate-data-flow-between-environment/dev/nifi-registry.properties

echo -e "Getting $source_env Nifi registry bucket id..."
source_bucket_id=$(/opt/nifi-toolkit/nifi-toolkit-1.15.1/bin/cli.sh registry list-buckets -ot json | jq --arg e $source_bucket_name '.[] | select(.name==$e)' | jq -r .identifier)
echo "OK: $source_bucket_id"

echo "Getting $source_env Nifi registry flow id..."
source_flow_id=$(/opt/nifi-toolkit/nifi-toolkit-1.15.1/bin/cli.sh registry list-flows -b $source_bucket_id -ot json | jq --arg e $source_flow_name '.[] | select(.name==$e)' | jq -r .identifier)
echo "OK: $source_flow_id"

echo "Exporting $source_env flow version $source_flow_version..."
/opt/nifi-toolkit/nifi-toolkit-1.15.1/bin/cli.sh registry export-flow-version -f $source_flow_id -fv $source_flow_version -o /home/nam/migrate-data-flow-between-environment/source-flow-exported.json -ot json
echo "OK"

#Set up for target environment
/opt/nifi-toolkit/nifi-toolkit-1.15.1/bin/cli.sh session set nifi.props /home/nam/migrate-data-flow-between-environment/sit/nifi.properties
/opt/nifi-toolkit/nifi-toolkit-1.15.1/bin/cli.sh session set nifi.reg.props /home/nam/migrate-data-flow-between-environment/sit/nifi-registry.properties

echo "Getting $target_env Nifi registry bucket id..."
target_bucket_id=$(/opt/nifi-toolkit/nifi-toolkit-1.15.1/bin/cli.sh registry list-buckets -ot json | jq --arg e $target_bucket_name '.[] | select(.name==$e)' | jq -r .identifier)
echo "OK: $target_bucket_id"

echo "Getting $target_env Nifi registry flow id..."
target_flow_id=$(/opt/nifi-toolkit/nifi-toolkit-1.15.1/bin/cli.sh registry list-flows -b $target_bucket_id -ot json | jq --arg e $target_flow_name '.[] | select(.name==$e)' | jq -r .identifier)

if [ -z "$target_flow_id" ]
then
    echo "Flow id is null, creating it..."
    target_flow_id=$(/opt/nifi-toolkit/nifi-toolkit-1.15.1/bin/cli.sh registry create-flow -b $target_bucket_id -fn $target_flow_name)
    echo "Created flow id: $target_flow_id"
else
    echo "OK: $target_flow_id"
fi

echo "Importing $source_env flow version $source_flow_version to $target_env environment..."
target_flow_version=$(/opt/nifi-toolkit/nifi-toolkit-1.15.1/bin/cli.sh registry import-flow-version -i /home/nam/migrate-data-flow-between-environment/source-flow-exported.json -f $target_flow_id)
echo "OK: $target_flow_version"

echo "Importing process group to $target_env environment..."
/opt/nifi-toolkit/nifi-toolkit-1.15.1/bin/cli.sh nifi pg-import -b $target_bucket_id -f $target_flow_id -fv $target_flow_version -verbose
echo "OK"