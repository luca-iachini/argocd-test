export GH_ORG=luca-iachini
export GH_TOKEN=secret
export GH_EMAIL=luca.iachini@patchai.io


#install ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.3/deploy/static/provider/cloud/deploy.yaml


kustomize build  kustomize/argo-cd/base | kubectl apply --filename -

export PASS=$(kubectl --namespace argocd get secret argocd-initial-admin-secret --output jsonpath="{.data.password}" | base64 --decode)

argocd login --insecure --username admin --password $PASS --grpc-web  kubernetes.docker.internal

kubectl apply -f projects/project.yaml

## install argo-events (webhook test)
kubectl apply --filename applications/argo-events.yaml


## install argo-workflows
# these steps add also the argo server. Retrieve the token from the secret of workflow to log into the server
# It is possible to enable the sso with the argocd dex (https://argoproj.github.io/argo-workflows/argo-server-sso-argocd/).
kubectl apply --filename applications/argo-workflows.yaml
SECRET=$(kubectl -n argo get sa workflow -o=jsonpath='{.secrets[0].name}')
ARGO_TOKEN="Bearer $(kubectl -n argo get secret $SECRET -o=jsonpath='{.data.token}' | base64 --decode)"
echo $ARGO_TOKEN | pbcopy


# test events: curl -X POST -d '{"message": "Test"}' http://kubernetes.docker.internal/push


echo "apiVersion: v1
kind: Secret
metadata:
  name: github-access
  namespace: argo
type: Opaque
data:
  token: $(echo -n $GH_TOKEN | base64)
  user: $(echo -n $GH_ORG | base64)
  email: $(echo -n $GH_EMAIL | base64)" \
  | kubectl apply -f -

# install application
kubectl apply -f applications/apps.yaml