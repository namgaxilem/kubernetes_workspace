## Procedure:
**Step 1:** Install necessary tools and namespaces
```bash
kubectl create namespace vault
kubectl create namespace cert-manager
kubectl create namespace nginx
kubectl label namespace vault istio-injection=enabled
kubectl label namespace cert-manager istio-injection=enabled
kubectl label namespace nginx istio-injection=enabled

istioctl install
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.yaml
helm install vault hashicorp/vault --set "injector.enabled=false" -n vault
```
**Step 2:** Create a secret for the ingress gateway
```bash
cd tmanet.com
kubectl create secret tls ingressgateway-tls-secret --cert=app.tmanet.com.crt --key=app.tmanet.com.key -n istio-system

cd example.com
kubectl create configmap nginx-configmap --from-file=nginx.conf=./nginx.conf -n nginx
```
**Step 3:** Config Vault and Cert Manager (secrets need: nginx-server-certs, ca-key-pair-issuer, ingressgateway-client-certs)
```bash
# exec into vault po
kubectl exec vault-0 -n vault -it -- sh
$ vault operator init
$ vault operator unseal
$ vault login $VAULT_ROOT_TOKEN
# Configure PKI secrets engine
$ vault secrets enable pki
$ vault secrets tune -max-lease-ttl=8760h pki
$ vault write pki/root/generate/internal \
    common_name=example.com \
    ttl=8760h
$ vault write pki/config/urls \
    issuing_certificates="http://vault.vault:8200/v1/pki/ca" \
    crl_distribution_points="http://vault.vault:8200/v1/pki/crl"
$ vault write pki/roles/example-dot-com \
    allowed_domains=example.com \
    allow_subdomains=true \
    max_ttl=72h
$ vault policy write pki - <<EOF
path "pki*"                        { capabilities = ["read", "list"] }
path "pki/roles/example-dot-com"   { capabilities = ["create", "update"] }
path "pki/sign/example-dot-com"    { capabilities = ["create", "update"] }
path "pki/issue/example-dot-com"   { capabilities = ["create"] }
EOF
# Configure Kubernetes authentication
$ vault auth enable kubernetes
$ vault write auth/kubernetes/config \
    kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
    token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
    kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
    issuer="https://kubernetes.default.svc.cluster.local" \
    disable_iss_validation=true
$ vault write auth/kubernetes/role/issuer \
    bound_service_account_names=issuer \
    bound_service_account_namespaces=cert-manager \
    policies=pki \
    ttl=20m
# Create Service Account then get its secret and paste to ClusterIssuer manifest
kubectl create serviceaccount issuer -n cert-manager
kubectl get secret -n cert-manager
kubectl apply -f cert-manager-vault.yaml
# Copy paste the cert created above to ca-vault.crt file and create a secret to hold cert
kubectl create secret generic ca-key-pair-issuer --from-file=tls.crt=ca-vault.crt -n nginx
```
**Step 4:** Create a secret and config map for nginx pod, and Create nginx deployment, service, gateway and virtualService
```bash
kubectl apply -f apps.yaml
kubectl apply -f destinationrule.yaml
```
**Step 6:** Verify  
Update your `/etc/hosts` file to add DNS record to resolve `app.tmanet.com` to ingress gateway external IP
```bash
kubectl get services/istio-ingressgateway -n istio-system
```
Access https://app.tmanet.com




kubectl rollout restart deployment nginx -n nginx
kubectl port-forward -n vault vault-0 8200:8200