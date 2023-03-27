# using helm :
# if use this command, you have to manually edit strings <BUILD_BY_KUSTOMIZE> in values.yaml

#helm repo add argo https://argoproj.github.io/argo-helm
#helm install -n argocd argocd argo/argo-cd -f values.yaml

# using kustomize :
kustomize build . --enable-helm | kubectl apply -f -
