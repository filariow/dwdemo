#!/bin/env sh

install_vault() {
    set -e

    helm repo add hashicorp https://helm.releases.hashicorp.com
    helm repo update
    helm install vault hashicorp/vault \
        --set "injector.enabled=false" \
        --set "server.dev.enabled=true"
}

configure_vault() {
    set -e

    until [ "$(kubectl get pods vault-0 --output=jsonpath='{.status.phase}')" = "Running" ]; do echo "waiting for pod vault-0 to have status 'Running'"; sleep 5; done

    kubectl exec vault-0 -- vault secrets enable -path=internal kv-v2
    kubectl exec vault-0 -- vault kv put -mount=secret foo bar=baz

    kubectl apply -f vault_ingress.yaml
}

install_ingress() {
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    until kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s; do echo "waiting for nginx ingress"; sleep 5; done
}

main() {
    set -e

    install_vault
    install_ingress
    configure_vault
}

main
