# Hands on for kubectl in powershell

## 1. Get current ps1 file location
echo $profile

## 2. Store below code in that ps1 file
example: C:\Users\NAM\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

## 3. Set alias for kubectl commands
```
Set-Alias -Name k -Value kubectl

## pods
function GetPods([string]$namespace = "default") {
    kubectl get pods -n $namespace
}
Set-Alias -Name kgp -Value GetPods

function GetPodsWide([string]$namespace = "default") {
    kubectl get pods -n $namespace -o wide
}
Set-Alias -Name kgpw -Value GetPodsWide

function GetAll([string]$namespace = "default") {
    kubectl get all -n $namespace
}
Set-Alias -Name kgall -Value GetAll

function DescribePod([string]$podname, [string]$namespace = "default") {
    kubectl describe po $podname -n $namespace
}
Set-Alias -Name kdp -Value DescribePod

function LogsPod([string]$podname, [string]$namespace = "default") {
    kubectl logs pod/$podname -n $namespace
}
Set-Alias -Name klp -Value LogsPod

function ExecContainerShell([string]$podname, [string]$namespace = "default") {
    kubectl exec -it po/$podname -n $namespace -- sh
}
Set-Alias -Name kexec -Value ExecContainerShell

## namespaces
function GetNamespaces() {
    kubectl get namespaces
}
Set-Alias -Name kgns -Value GetNamespaces

function SwitchDefaultNamespace([string]$namespace) {
    kubectl config set-context --current --namespace=$namespace
}
Set-Alias -Name kswichns -Value SwitchDefaultNamespace

## nodes
function GetNodes() {
    kubectl get nodes -o wide
}
Set-Alias -Name kgnodes -Value GetNodes

## Context
function GetContext() {
    kubectl config get-contexts
}
Set-Alias -Name kl -Value GetContext

function SwitchContext([string]$context_name) {
    kubectl config use-context $context_name
}
Set-Alias -Name kswitch -Value SwitchContext

## Others
function ApplyYaml([string]$filename, [string]$namespace = "default") {
    kubectl apply -f $filename -n $namespace
}
Set-Alias -Name kaf -Value ApplyYaml
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