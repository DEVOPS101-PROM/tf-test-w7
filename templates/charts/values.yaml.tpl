# Default values for ${app_name}
replicaCount: 2

image:
  repository: ${image_repository}/${app_name}
  tag: ${image_tag}
  pullPolicy: IfNotPresent

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations: {}

podSecurityContext: {}

securityContext: {}

service:
  type: ClusterIP
  port: 80
  targetPort: 8080

ingress:
  enabled: true
  className: "envoy"
  annotations:
    envoyproxy.io/rewrite-host: "true"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: ${app_name}.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

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
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80

nodeSelector: {}

tolerations: []

affinity: {}

# Application specific configuration
app:
  name: ${app_name}
  version: ${image_tag}
  environment: "development"
  
# Monitoring configuration
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: "30s"
  
# Logging configuration
logging:
  level: "info"
  format: "json"

# Environment variables
env:
  - name: LOG_LEVEL
    value: "info"
  - name: PORT
    value: "8080" 