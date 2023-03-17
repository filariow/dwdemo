# My Devtools Week

* Tried ArgoCD and looked at its internal wrt
    * Validation: they do not perform complex validation on CRD
    * Authentication on linked clusters: based on Service Accounts
* Looked at [cobra](https://github.com/spf13/cobra)
* Developed [KId](https://github.com/filariow/kid)
* Hashicorp Vault on Kubernetes with Service Account authorization


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

