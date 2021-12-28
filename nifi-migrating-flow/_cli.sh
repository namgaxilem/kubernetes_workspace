# dev
./cli.sh registry list-buckets -ot json > D:\\Kubernetes_world\\nifi-migrating-flow\\env\\buckets.json
./cli.sh registry export-flow-version -f db575536-82c4-4b29-99e7-bac9e22cb921 -fv 1 -ot json -o D:\\Kubernetes_world\\nifi-migrating-flow\\env\\flow-version-dev.json

# prod
./cli.sh registry create-bucket -bn 'prod-bucket' -bd 'Prod Bucket Description' -p D:\\Kubernetes_world\\nifi-migrating-flow\\env\\nifi-registry-prod.properties
./cli.sh registry create-flow -fn 'prod-flow' -fd 'Prod Flow Description' -b 6bd571d3-4f05-45ed-8693-507841e0a77a -p D:\\Kubernetes_world\\nifi-migrating-flow\\env\\nifi-registry-prod.properties
./cli.sh registry import-flow-version -f 9e1bfc8b-cad0-4437-8e6a-0fdf15acc210 -i D:\\Kubernetes_world\\nifi-migrating-flow\\env\\flow-version-dev.json -p D:\\Kubernetes_world\\nifi-migrating-flow\\env\\nifi-registry-prod.properties
./cli.sh nifi pg-import -b 6bd571d3-4f05-45ed-8693-507841e0a77a -f9e1bfc8b-cad0-4437-8e6a-0fdf15acc210 -fv 1 -p D:\\Kubernetes_world\\nifi-migrating-flow\\env\\nifi-prod.properties