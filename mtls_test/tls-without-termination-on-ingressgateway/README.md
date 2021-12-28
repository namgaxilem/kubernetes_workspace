## Procedure:
**Step 1:** Install Istio and namespace nginx
```bash
istioctl install
kubectl create namespace nginx
kubectl label namespace nginx istio-injection=enabled
```
**Step 2:** Create a secret for the ingress gateway
```bash
cd tmanet.com
kubectl create secret tls ingressgateway-tls-secret --cert=app.tmanet.com.crt --key=app.tmanet.com.key -n istio-system
```
**Step 3:** Create a secret and config map for nginx pod, and Create nginx deployment, service, gateway and virtualService
```bash
cd example.com
kubectl create configmap nginx-configmap --from-file=nginx.conf=./nginx.conf -n nginx
kubectl create secret tls nginx-server-certs --key nginx.example.com.key --cert nginx.example.com.crt -n nginx
kubectl create secret tls nginx-client-cacert --cert example.com.crt --key example.com.key -n nginx
cd ..
kubectl apply -f apps.yaml
```
**Step 4:** Create secret for sidecar client cerificate and DestinationRule
```bash
cd example.com
kubectl create secret generic ingressgateway-client-certs --from-file=key=ingressgateway.example.com.key --from-file=cert=ingressgateway.example.com.crt --from-file=cacert=example.com.crt -n istio-system
cd ..
kubectl apply -f destinationrule.yaml
```
**Step 6:** Verify  
Update your `/etc/hosts` file to add DNS record to resolve `app.tmanet.com` to ingress gateway external IP
```bash
kubectl get services/istio-ingressgateway -n istio-system
```
Access https://app.tmanet.com


**Additional step: Mount cert to ingressgateway po:**
kubectl create -n istio-system secret tls istio-ingressgateway-certs --key ingressgateway.example.com.key --cert ingressgateway.example.com.crt
