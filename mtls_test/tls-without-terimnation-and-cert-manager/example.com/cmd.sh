# Create a root certificate and private key to sign the certificates for your services:
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' -keyout example.com.key -out example.com.crt

# Create a certificate and a private key for nginx:
openssl req -out nginx.example.com.csr -newkey rsa:2048 -nodes -keyout nginx.example.com.key -subj "/CN=nginx.nginx.svc.cluster.local/O=nginx organization"
openssl x509 -req -days 365 -CA example.com.crt -CAkey example.com.key -set_serial 0 -in nginx.example.com.csr -out nginx.example.com.crt

# Create a certificate and a private key for ingressgateway:
openssl req -out ingressgateway.example.com.csr -newkey rsa:2048 -nodes -keyout ingressgateway.example.com.key -subj "/CN=istio-ingressgateway.istio-system.svc.cluster.local/O=istio organization"
openssl x509 -req -days 365 -CA example.com.crt -CAkey example.com.key -set_serial 0 -in ingressgateway.example.com.csr -out ingressgateway.example.com.crt
