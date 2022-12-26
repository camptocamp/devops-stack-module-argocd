#############################################################
# # [final] ArgoCD:
#
# * admin credentials should be disabled or regenereted by user on final ArgoCD install
# * pipeline account used for argocd provider config
#
#

locals {
  helm_values = [{
    argo-cd = {
      crds = {
        install = false # already done during bootstrap
      }
      configs = merge(length(var.repositories) > 0 ? {
        repositories = var.repositories
        } : null, {
        rbac = {
          scopes           = "[groups, cognito:groups, roles]"
          "policy.default" = ""
          "policy.csv"     = <<-EOT
                              g, pipeline, role:admin
                              g, argocd-admin, role:admin
                            EOT
        }
        secret = {
          extra = {
            "accounts.pipeline.tokens"  = "${replace(var.argocd["accounts_pipeline_tokens"], "\\\"", "\"")}"
            "server.secretkey"          = "${replace(var.argocd["server_secretkey"], "\\\"", "\"")}"
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
      redis = {
        enabled = true
      }
      repoServer = {
        metrics = {
          enabled = true
        }
      }
      server = merge(
        {
          extraArgs = [
            "--insecure",
          ]
          config = {
            url                       = "https://${var.argocd["domain"]}"
            "admin.enabled"           = "${var.argocd["admin_enabled"]}"
            "accounts.pipeline"       = "apiKey"
            "oidc.config"             = <<-EOT
              ${yamlencode(merge(var.oidc, { clientSecret = "$oidc.default.clientSecret" }))}
              EOT
            "configManagementPlugins" = <<-EOT
              - name: kustomized-helm # prometheus requirement
                init:
                  command: ["/bin/sh", "-c"]
                  args: ["helm dependency build || true"]
                generate:
                  command: ["/bin/sh", "-c"]
                  args: ["echo \"$ARGOCD_ENV_HELM_VALUES\" | helm template . --name-template $ARGOCD_APP_NAME --namespace $ARGOCD_APP_NAMESPACE $HELM_ARGS -f - --include-crds > all.yaml && kustomize build"]
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
              "${var.argocd["domain"]}",
              "argocd.apps.${var.base_domain}",
            ]
            tls = [
              {
                secretName = "argocd-tls"
                hosts = [
                  "${var.argocd["domain"]}",
                  "argocd.apps.${var.base_domain}",
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
