locals {
  jwt_token_payload = {
    jti = random_uuid.jti.result
    iat = time_static.iat.unix
    iss = "argocd"
    nbf = time_static.iat.unix
    sub = "pipeline"
  }

  argocd_accounts_pipeline_tokens = jsonencode(
    [
      {
        id  = random_uuid.jti.result
        iat = time_static.iat.unix
      }
    ]
  )

  sensitive_values = [{
    argo-cd = {
      configs = {
        secret = {
          extra = {
            "accounts.pipeline.tokens" = "${replace(local.argocd_accounts_pipeline_tokens, "\\\"", "\"")}"
            "server.secretkey"         = "${replace(random_password.argocd_server_secretkey.result, "\\\"", "\"")}"
          }
        }
      }
    }
  }]

  # TODO fix later: use app version read from Chart.yaml
  # argocd_version = yamldecode(file("${path.module}/../charts/argocd/charts/argo-cd/Chart.yaml")).appVersion
  argocd_version = "v2.6.6"

  helm_values = [
    {
      argo-cd = {
        dex = {
          enabled = false
        }
        repoServer = {
          volumes = [
            {
              configMap = {
                name = "avp-kustomized-helm-cm"
              }
              name = "avp-kustomized-helm-volume"
            },
            {
              configMap = {
                name = "avp-helm-cm"
              }
              name = "avp-helm-volume"
            },
            {
              name     = "custom-tools"
              emptyDir = {}
            }
          ]
          initContainers = [
            {
              name  = "download-copy-avp"
              image = "registry.access.redhat.com/ubi8" # TODO change image.
              env = [
                {
                  name  = "AVP_VERSION"
                  value = "1.14.0"
                }
              ]
              command = ["sh", "-c"]
              args = [
                "curl -L https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v$(AVP_VERSION)/argocd-vault-plugin_$(AVP_VERSION)_linux_amd64 -o argocd-vault-plugin && chmod +x argocd-vault-plugin && mv argocd-vault-plugin /custom-tools/"
              ]
              volumeMounts = [
                {
                  mountPath = "/custom-tools"
                  name      = "custom-tools"
                }
              ]
            }
          ]
          extraContainers = [
            {
              name    = "avp-kustomized-helm-cmp"
              command = ["/var/run/argocd/argocd-cmp-server"]
              # Note: Argo CD official image ships Helm and Kustomize. No need to build a custom image to use "kustomized-helm" plugin.
              image = "quay.io/argoproj/argocd:${local.argocd_version}"
              securityContext = {
                runAsNonRoot = true
                runAsUser    = 999
              }
              env = [
                for key in keys(var.avp_config) : {
                  name = key
                  valueFrom = {
                    secretKeyRef = {
                      name = "avp-config"
                      key  = key
                    }
                  }
                }
              ]
              volumeMounts = [
                {
                  mountPath = "/var/run/argocd"
                  name      = "var-files"
                },
                {
                  mountPath = "/home/argocd/cmp-server/plugins"
                  name      = "plugins"
                },
                {
                  mountPath = "/home/argocd/cmp-server/config/plugin.yaml"
                  subPath   = "plugin.yaml"
                  name      = "avp-kustomized-helm-volume"
                },
                {
                  mountPath = "/usr/local/bin/argocd-vault-plugin"
                  subPath   = "argocd-vault-plugin"
                  name      = "custom-tools"
                }
              ]
            },
            {
              name    = "avp-helm-cmp"
              command = ["/var/run/argocd/argocd-cmp-server"]
              image   = "quay.io/argoproj/argocd:${local.argocd_version}"
              securityContext = {
                runAsNonRoot = true
                runAsUser    = 999
              }
              env = [
                for key in keys(var.avp_config) : {
                  name = key
                  valueFrom = {
                    secretKeyRef = {
                      name = "avp-config"
                      key  = key
                    }
                  }
                }
              ]
              volumeMounts = [
                {
                  mountPath = "/var/run/argocd"
                  name      = "var-files"
                },
                {
                  mountPath = "/home/argocd/cmp-server/plugins"
                  name      = "plugins"
                },
                {
                  mountPath = "/home/argocd/cmp-server/config/plugin.yaml"
                  subPath   = "plugin.yaml"
                  name      = "avp-helm-volume"
                },
                {
                  mountPath = "/usr/local/bin/argocd-vault-plugin"
                  subPath   = "argocd-vault-plugin"
                  name      = "custom-tools"
                }
              ]
            }
          ]
        }
        extraObjects = [
          {
            apiVersion = "v1"
            kind       = "ConfigMap"
            metadata = {
              name = "avp-kustomized-helm-cm"
            }
            data = {
              "plugin.yaml" = <<-EOT
                apiVersion: argoproj.io/v1alpha1
                kind: ConfigManagementPlugin
                metadata:
                  name: avp-kustomized-helm
                spec:
                  init:
                    command: ["/bin/sh", "-c"]
                    args: ["helm dependency build || true"]
                  generate:
                    command: ["/bin/sh", "-c"]
                    args: ["echo \"$ARGOCD_ENV_HELM_VALUES\" | helm template . --name-template $ARGOCD_APP_NAME --namespace $ARGOCD_APP_NAMESPACE $ARGOCD_ENV_HELM_ARGS -f - --include-crds > all.yaml && kustomize build | argocd-vault-plugin generate -"]
              EOT
            }
          },
          {
            apiVersion = "v1"
            kind       = "ConfigMap"
            metadata = {
              name = "avp-helm-cm"
            }
            data = {
              "plugin.yaml" = <<-EOT
                apiVersion: argoproj.io/v1alpha1
                kind: ConfigManagementPlugin
                metadata:
                  name: avp-helm
                spec:
                  generate:
                    command: ["/bin/sh", "-c"]
                    args: ["echo \"$ARGOCD_ENV_HELM_VALUES\" | helm template . --name-template $ARGOCD_APP_NAME --namespace $ARGOCD_APP_NAMESPACE $ARGOCD_ENV_HELM_ARGS -f - --include-crds | argocd-vault-plugin generate -"]
              EOT
            }
          }
        ]
        server = {
          extraArgs = [
            "--insecure",
          ]
          config = {
            "admin.enabled"           = "true" # autogenerates password, see `argocd-initial-admin-secret`
            "accounts.pipeline"       = "apiKey"
            "resource.customizations" = <<-EOT
              argoproj.io/Application: # https://argo-cd.readthedocs.io/en/stable/operator-manual/health/#argocd-app
                health.lua: |
                  hs = {}
                  hs.status = "Progressing"
                  hs.message = ""
                  if obj.status ~= nil then
                    if obj.status.health ~= nil then
                      hs.status = obj.status.health.status
                      if obj.status.health.message ~= nil then
                        hs.message = obj.status.health.message
                      end
                    end
                  end
                  return hs
              networking.k8s.io/Ingress: # https://argo-cd.readthedocs.io/en/stable/faq/#why-is-my-application-stuck-in-progressing-state
                health.lua: |
                  hs = {}
                  hs.status = "Healthy"
                  return hs
            EOT
          }
        }
        configs = {
          rbac = {
            scopes           = "[groups, cognito:groups, roles]"
            "policy.default" = ""
            "policy.csv"     = <<-EOT
                                g, pipeline, role:admin
                                g, argocd-admin, role:admin
                                g, devops-stack-admins, role:admin
                                EOT
          }
        }
      }
    }
  ]
}
