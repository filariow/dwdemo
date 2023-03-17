# My Devtools Week

* Tried ArgoCD and looked at its internal focusing on the following topics
    * Namespaced scope: [two installation methods](https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/#non-high-availability)
    * Validation: they do not perform complex validation on CRD
    * Authentication on linked clusters: [based on Service Accounts](https://github.com/argoproj/argo-cd/blob/master/util/clusterauth/clusterauth.go)
* Looked at [cobra](https://github.com/spf13/cobra)
* Developed [KId](https://github.com/filariow/kid)
* [Hashicorp Vault](https://developer.hashicorp.com/vault/docs/what-is-vault) on [Kubernetes with Service Account authorization](https://developer.hashicorp.com/vault/docs/auth/kubernetes)


## KId

A simple CLI for managing Identity based on Kubernetes' Service Accounts. It enables easy kubeconfig export and keys rotation.

### Demo

* Create an identity
* Get the token
* Get the kubeconfig
* Rotate the token
* Get the new kubeconfig

## Hashicorp Vault

* Install Hashicorp Vault on kubernetes
* Enable Service Account authentication
* Create a Secret
* Authorize a Service Account
* Get the Secret as the Service Account from remote cluster

