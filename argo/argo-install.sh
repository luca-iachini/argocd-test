# Source: https://gist.github.com/48f44d3974db698d3127f52b6e7cd0d3

###########################################################
# Automation of Everything                                #
# How To Combine Argo Events, Workflows, CD, and Rollouts #
# https://youtu.be/XNXJtxkUKeY                            #
###########################################################

# Requirements:
# - k8s v1.19+ cluster with nginx Ingress

# Replace `[...]` with the GitHub organization or the username
export GH_ORG=luca-iachini

export REGISTRY_SERVER=https://index.docker.io/v1/

# Replace `[...]` with the GitHub token
export GH_TOKEN=

# Replace `[...]` with the GitHub email
export GH_EMAIL=luca.iachini@patchai.io


#install ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.3/deploy/static/provider/cloud/deploy.yaml


kustomize build  kustomize/argo-cd/base | kubectl apply --filename -

export PASS=$(kubectl --namespace argocd get secret argocd-initial-admin-secret --output jsonpath="{.data.password}" | base64 --decode)

argocd login --insecure --username admin --password $PASS --grpc-web  kubernetes.docker.internal

kubectl apply -f projects/project.yaml

kustomize build kustomize/apps/base | kubectl apply --filename -

## install argo-events (webhook test)
kubectl apply --filename applications/argo-events.yaml
# test events: curl -X POST -d '{"message": "Test"}' http://kubernetes.docker.internal/push


## install argo-workflows 
# these steps add also the argo server. Retrieve the token from the secret of workflow to log into the server
# It is possible to enable the sso with the argocd dex (https://argoproj.github.io/argo-workflows/argo-server-sso-argocd/).
kubectl apply --filename applications/argo-workflows.yaml
SECRET=$(kubectl -n argo get sa workflow -o=jsonpath='{.secrets[0].name}')
ARGO_TOKEN="Bearer $(kubectl -n argo get secret $SECRET -o=jsonpath='{.data.token}' | base64 --decode)"
echo $ARGO_TOKEN | pbcopy