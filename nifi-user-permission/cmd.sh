kubectl create configmap user-permission --from-file=user-permission.yaml=user-permission.yaml
kubectl create secret generic nifi-toolkit --from-literal=keystore.p12=asd --from-literal=truststore.p12=asd
kubectl create secret generic keystore-password --from-literal=password=asd
docker run --rm -e TEST=ttest --entrypoint /bin/bash -v D:/Kubernetes_world/nifi-user-permission:/cc nifi-user-permission:latest -c '/cc/cc.sh'