export GH_ORG=luca-iachini
export GH_TOKEN=secret
export GH_EMAIL=luca.iachini@patchai.io


#install ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.3/deploy/static/provider/cloud/deploy.yaml


kustomize build  kustomize/argo-cd/base | kubectl apply --filename -

export PASS=$(kubectl --namespace argocd get secret argocd-initial-admin-secret --output jsonpath="{.data.password}" | base64 --decode)

argocd login --insecure --username admin --password $PASS --grpc-web  kubernetes.docker.internal --grpc-web-root-path /argocd

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


### https://argocd-image-updater.readthedocs.io/en/stable/install/start/
# image updater
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
IMAGE_UPDATER_TOKEN=$(argocd account generate-token --account image-updater --id image-updater)

kubectl create secret generic argocd-image-updater-secret \
--from-literal argocd.token=$IMAGE_UPDATER_TOKEN --dry-run=client -o yaml \
| kubectl -n argocd apply -f -

kubectl -n argocd rollout restart deployment argocd-image-updater


## install Minio artifacts repository

helm repo add minio https://helm.min.io/

helm update

helm install argo-artifacts minio/minio --set fullnameOverride=argo-artifacts --set resources.requests.memory=200Mi --namespace argo

kubectl port-forward  -n argo svc/argo-artifacts 9000:9000

kubectl get secret argo-artifacts -o jsonpath='{.data.accesskey}' -n argo | base64 --decode | pbcopy

kubectl get secret argo-artifacts -o jsonpath='{.data.secretkey}' -n argo | base64 --decode | pbcopy
