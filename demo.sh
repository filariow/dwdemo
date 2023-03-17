#!/bin/env sh

# build kid
( cd kid && make build )

# create main cluster

cat <<EOF | kind create cluster --name=main --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF

## configure main cluster
./configure-vault-cluster.sh

b=$(docker container inspect main-control-plane --format {{.NetworkSettings.Networks.kind.IPAddress}})
u="https://$b:6443"

## on main cluster, configure vault kubernetes auth
kid/out/kid create identity vault-auth
cacrt=$(kid/out/kid get token vault-auth | jq -r '."ca.crt" | @base64d')
jwt=$(kid/out/kid get token vault-auth | jq -r '.token | @base64d')

kubectl exec vault-0 -- vault auth enable kubernetes
kubectl exec vault-0 -- vault write auth/kubernetes/config \
	token_reviewer_jwt="$jwt" \
	kubernetes_host="$u" \
	kubernetes_ca_cert="$cacrt"

cat << EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: role-tokenreview-binding
  namespace: default
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
  - kind: ServiceAccount
    name: vault-auth
    namespace: default
EOF

## on main cluster, create an identity for worker cluster
kid/out/kid create identity worker
wkfg=$(kid/out/kid get kubeconfig worker -s "$u")
jwt=$(kid/out/kid get token worker | jq -r '.token')

kubectl exec vault-0 -- vault write auth/kubernetes/role/demo \
	bound_service_account_names=worker \
	bound_service_account_namespaces=default \
	policies=default

kubectl cp policy.hcl vault-0:/tmp/policy.hcl
kubectl exec vault-0 -- vault policy write default /tmp/policy.hcl


# create worker cluster
kind create cluster --name worker

## create secret with kubeconfig to auth on main cluster
cat << EOF | kubectl apply -f -
kind: Secret
apiVersion: v1
metadata:
  name: worker-identity
  namespace: default
data:
  kubeconfig: $(echo "$wkfg" | base64 -w0)
  token: $(echo "$jwt")
EOF

(cd vault-cli && docker build -t dw/demo/vault-cli:latest . )
kind load docker-image dw/demo/vault-cli:latest --name worker

## deploy a bash pod to worker cluster with secret injected
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: demo
  name: demo
spec:
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  containers:
  - image: dw/demo/vault-cli:latest
    name: vault-cli
    imagePullPolicy: IfNotPresent
    command:
    - sleep
    - infinity
    volumeMounts:
    - mountPath: /secrets/
      name: vault-identity
      readOnly: true
    env:
      - name: KUBECONFIG
        value: /secrets/kubeconfig
      - name: VAULT_ADDR
        value: http://$b
  volumes:
  - name: vault-identity
    secret:
      defaultMode: 420
      secretName: worker-identity
EOF


cat << EOF
run the following commands

kubectl exec -it demo -- sh
./vault-cli
EOF
