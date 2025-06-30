apiVersion: v1
kind: Namespace
metadata:
  name: flux-system
---
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: flux-system
  namespace: flux-system
spec:
  interval: 1m0s
  ref:
    branch: main
  url: https://github.com/${github_owner}/${github_repo}
  secretRef:
    name: flux-system
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: flux-system
  namespace: flux-system
spec:
  interval: 10m0s
  path: ./clusters/${cluster_name}
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  targetNamespace: flux-system
---
apiVersion: v1
kind: Secret
metadata:
  name: flux-system
  namespace: flux-system
type: Opaque
data:
  username: ${base64encode(github_owner)}
  password: ${base64encode(github_token)}
---
# TLS Secret for Flux
apiVersion: v1
kind: Secret
metadata:
  name: flux-tls-keys
  namespace: flux-system
type: Opaque
data:
  identity.pem: ${base64encode(private_key_pem)}
  identity.pub: ${base64encode(public_key_pem)} 