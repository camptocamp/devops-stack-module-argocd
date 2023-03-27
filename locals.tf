
locals {
  argocd_version                  = "v2.6.6"
  argocd_hostname_withclustername = format("argocd.apps.%s.%s", var.cluster_name, var.base_domain)
  argocd_hostname                 = format("argocd.apps.%s", var.base_domain)
  helm_values = [{
    argo-cd = {
      configs = merge(length(var.repositories) > 0 ? {
        repositories = var.repositories
        } : null, {
        rbac = {
          scopes           = "[groups, cognito:groups, roles]"
          "policy.default" = ""
          "policy.csv"     = <<-EOT
                              g, pipeline, role:admin
                              g, argocd-admin, role:admin
                              g, devops-stack-admins, role:admin
                            EOT
        }
        secret = {
          extra = {
            "accounts.pipeline.tokens"  = "${replace(var.accounts_pipeline_tokens, "\\\"", "\"")}"
            "server.secretkey"          = "${replace(var.server_secretkey, "\\\"", "\"")}"
            "oidc.default.clientSecret" = "${replace(var.oidc.clientSecret, "\\\"", "\"")}"
          }
        }
      })
      controller = {
        metrics = {
          enabled = true
        }
      }
      dex = {
        enabled = false
      }
      repoServer = {
        metrics = {
          enabled = true
        }
        volumes = [
          {
            configMap = {
              name = "kustomized-helm-cm"
            }
            name = "kustomized-helm-volume"
          }
        ]
        extraContainers = [
          {
            name    = "kustomized-helm-cmp"
            command = ["/var/run/argocd/argocd-cmp-server"]
            # Note: Argo CD official image ships Helm and Kustomize. No need to build a custom image to use "kustomized-helm" plugin.
            image = "quay.io/argoproj/argocd:${local.argocd_version}"
            securityContext = {
              runAsNonRoot = true
              runAsUser    = 999
            }
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
                name      = "kustomized-helm-volume"
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
            name = "kustomized-helm-cm"
          }
          data = {
            "plugin.yaml" = <<-EOT
              apiVersion: argoproj.io/v1alpha1
              kind: ConfigManagementPlugin
              metadata:
                name: kustomized-helm
              spec:
                init:
                  command: ["/bin/sh", "-c"]
                  args: ["helm dependency build || true"]
                generate:
                  command: ["/bin/sh", "-c"]
                  args: ["echo \"$ARGOCD_ENV_HELM_VALUES\" | helm template . --name-template $ARGOCD_APP_NAME --namespace $ARGOCD_APP_NAMESPACE $ARGOCD_ENV_HELM_ARGS -f - --include-crds > all.yaml && kustomize build"]
            EOT
          }
        }
      ]
      server = merge(
        {
          extraArgs = [
            "--insecure",
          ]
          config = {
            "url"                     = "https://${local.argocd_hostname_withclustername}"
            "admin.enabled"           = tostring(var.admin_enabled)
            "accounts.pipeline"       = "apiKey"
            "oidc.config"             = <<-EOT
              ${yamlencode(merge(var.oidc, { clientSecret = "$oidc.default.clientSecret" }))}
              EOT
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
          ingress = {
            enabled = true
            annotations = {
              "cert-manager.io/cluster-issuer"                   = "${var.cluster_issuer}"
              "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
              "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-withclustername@kubernetescrd"
              "traefik.ingress.kubernetes.io/router.tls"         = "true"
              "ingress.kubernetes.io/ssl-redirect"               = "true"
              "kubernetes.io/ingress.allow-http"                 = "false"
            }
            hosts = [
              local.argocd_hostname_withclustername,
              local.argocd_hostname
            ]
            tls = [
              {
                secretName = "argocd-tls"
                hosts = [
                  local.argocd_hostname_withclustername,
                  local.argocd_hostname
                ]
              },
            ]
          }
          metrics = {
            enabled = true
          }
        },
        var.cluster_issuer == "ca-issuer" ? {
          volumeMounts = [
            {
              name      = "certificate"
              mountPath = "/etc/ssl/certs/ca.crt"
              subPath   = "ca.crt"
            },
          ]
          volumes = [
            {
              name = "certificate"
              secret = {
                secretName = "argocd-tls"
              }
            }
          ]
      } : null)
    }
  }]
}
