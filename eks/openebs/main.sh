echo "# get current config context "
KUBE_CTX=$(kubectl config current-context)
echo "$KUBE_CTX"

echo "assign openebs namespace to the current context:"
kubectl config set-context "$KUBE_CTX" --namespace=openebs

echo "create OpenEBS namespace"
kubectl create ns openebs

echo "install helm chart"
helm repo add openebs https://openebs.github.io/charts
helm repo update
helm install openebs openebs/openebs

echo "check helm chart"
helm ls

echo "Openebs setup done"

