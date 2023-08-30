# Problem with AKS and LoadBalancer Service (here nginx-ingress)

The LoadBalancer service is not working as expected. An external IP is assigned after a while, but this IP is not reachable from outside. (Works as expected from inside the cluster though.)

## Steps to Reproduce


```bash
# Create infrastructure
terraform init
terraform apply

# Extract Kubeconfig
terraform output -raw kube_config > .kubeconfig
export KUBECONFIG="$PWD/.kubeconfig"

# Check K8s is up and running
kubectl get nodes

# Setup nginx-ingress
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace

# List service to get IP
kubectl get svc -n ingress-nginx

# Access service from outside the cluster
curl https://$ip -k
```

This creates a `LoadBalancer` service with an external IP. This IP is not reachable from outside the cluster. The `externalClusterPolicy` is set to `Cluster` by default. Changing this to `Local` makes
the service actually available from the outside. The question is: Why is this not working with the `Cluster` policy?

## Note

Even removing the `vnet` resource and the IP CIDRs from the AKS resources (and letting azure completely manage the network) does not change anything. The `LoadBalancer` service is still not reachable from outside the cluster.
