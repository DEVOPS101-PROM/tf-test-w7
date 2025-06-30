apiVersion: v2
name: ${app_name}
description: A Helm chart for ${app_name} application
type: application
version: ${chart_version}
appVersion: "${image_tag}"
keywords:
  - ${app_name}
  - web
  - api
home: https://github.com/${github_owner}/${app_name}
sources:
  - https://github.com/${github_owner}/${app_name}
maintainers:
  - name: ${github_owner}
    email: ${github_owner}@example.com 