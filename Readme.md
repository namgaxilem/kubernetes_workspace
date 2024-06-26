# Set alias for kubectl commands
```
Set-Alias -Name k -Value kubectl
```

```
function GetPods([string]$namespace=”default”)
{
 kubectl get pods -n $namespace
}
Set-Alias -Name kgp -Value GetPods

function GetPodsWide([string]$namespace=”default”)
{
 kubectl get pods -n $namespace -o wide
}
Set-Alias -Name kgpw -Value GetPodsWide

function GetAll([string]$namespace=”default”)
{
 kubectl get all -n $namespace
}
Set-Alias -Name kgall -Value GetAll

function GetNodes()
{
 kubectl get nodes -o wide
}
Set-Alias -Name kgn -Value GetNodes

function DescribePod([string]$container, [string]$namespace=”default”)
{
 kubectl describe po $container -n $namespace
}
Set-Alias -Name kdp -Value DescribePod

function GetLogs([string]$container, [string]$namespace=”default”)
{
 kubectl logs pod/$container -n $namespace
}
Set-Alias -Name klp -Value GetLogs

function ApplyYaml([string]$filenamer, [string]$namespace=”default”)
{
 kubectl apply -f $filename -n $namespace
}
Set-Alias -Name kaf -Value ApplyYaml

function ExecContainerShell([string]$container, [string]$namespace=”default”)
{
 kubectl exec -it $container -n $namespace — sh
}
Set-Alias -Name kexec -Value ExecContainerShell
```

# Create YAML from kubectl commands 
We can create complex YAML files from the command line using kubectl commands.

Most people would agree that working with YAML files is no fun, and Kubernetes YAML files can be very verbose and hard to create from scratch. It is much easier to create the YAML file from kubectl commands instead of from a blank page using an editor.

The following commands will create a YAML file with name yamlfile. Once you create the YAML file from these kubectl commands, you can modify it based on your requirements and use it instead of writing from scratch:

kubectl run busybox --image=busybox --dry-run=client -o yaml --restart=Never > yamlfile.yaml
kubectl create job my-job --dry-run=client -o yaml --image=busybox -- date  > yamlfile.yaml
kubectl get -o yaml deploy/nginx > 1.yaml (Ensure that you have a deployment named as nginx)
kubectl run busybox --image=busybox --dry-run=client -o yaml --restart=Never -- /bin/sh -c "while true; do echo hello; echo hello again;done" > yamlfile.yaml
kubectl run wordpress --image=wordpress –-expose –-port=8989 --restart=Never -o yaml
kubectl run test --image=busybox --restart=Never --dry-run=client -o yaml -- bin/sh -c 'echo test;sleep 100' > yamlfile.yaml