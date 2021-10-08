# Source: https://gist.github.com/48f44d3974db698d3127f52b6e7cd0d3

###########################################################
# Automation of Everything                                #
# How To Combine Argo Events, Workflows, CD, and Rollouts #
# https://youtu.be/XNXJtxkUKeY                            #
###########################################################

# Requirements:
# - k8s v1.19+ cluster with nginx Ingress

# Replace `[...]` with the GitHub organization or the username
export GH_ORG=[...]

# Replace `[...]` with the base host accessible through NGINX Ingress
export BASE_HOST=[...] # e.g., $INGRESS_HOST.nip.io

export REGISTRY_SERVER=https://index.docker.io/v1/

# Replace `[...]` with the registry username
export REGISTRY_USER=[...]

# Replace `[...]` with the registry password
export REGISTRY_PASS=[...]

# Replace `[...]` with the registry email
export REGISTRY_EMAIL=[...]

# Replace `[...]` with the GitHub token
export GH_TOKEN=[...]

# Replace `[...]` with the GitHub email
export GH_EMAIL=[...]


#install ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.3/deploy/static/provider/cloud/deploy.yaml

kustomize build  kustomize/argo-cd/base | kubectl apply --filename -

export PASS=$(kubectl --namespace argocd get secret argocd-initial-admin-secret --output jsonpath="{.data.password}" | base64 --decode)

argocd login --insecure --username admin --password $PASS --grpc-web  kubernetes.docker.internal

kustomize build kustomize/apps/base | kubectl apply --filename -

## install argo-events (webhook test)
kubectl apply --filename applications/argo-events.yaml


## install argo-workflows
kubectl apply --filename applications/argo-workflows.yaml