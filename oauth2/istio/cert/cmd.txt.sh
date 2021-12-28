openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=example Inc./CN=example.com' -keyout example.com.key -out example.com.crt

openssl req -out myapp.cluster.example.com.csr -newkey rsa:2048 -nodes -keyout myapp.cluster.example.com.key -subj "/CN=myapp.cluster.example.com/O=myapp organization"
openssl x509 -req -days 365 -CA example.com.crt -CAkey example.com.key -set_serial 0 -in myapp.cluster.example.com.csr -out myapp.cluster.example.com.crt

kubectl create -n istio-system secret tls httpbin-credential --key=myapp.cluster.example.com.key --cert=myapp.cluster.example.com.crt
