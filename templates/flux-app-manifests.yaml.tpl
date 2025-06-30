---
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: ${app_name}
  namespace: flux-system
spec:
  interval: 1m0s
  ref:
    branch: main
  url: https://github.com/${github_owner}/${app_name}
  secretRef:
    name: flux-system
---
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: ${app_name}
  namespace: default
spec:
  interval: 5m0s
  chart:
    spec:
      chart: ${chart_name}
      version: ${chart_version}
      sourceRef:
        kind: GitRepository
        name: ${app_name}
        namespace: flux-system
      interval: 1m0s
  values:
    replicaCount: 2
    image:
      repository: ${image_repository}/${app_name}
      tag: ${image_tag}
    ingress:
      enabled: true
      className: "envoy"
      hosts:
        - host: ${app_name}.local
          paths:
            - path: /
              pathType: Prefix
    resources:
      limits:
        cpu: 500m
        memory: 512Mi
      requests:
        cpu: 250m
        memory: 256Mi
    autoscaling:
      enabled: true
      minReplicas: 2
      maxReplicas: 10 