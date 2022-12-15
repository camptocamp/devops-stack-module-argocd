locals {
  default_values = {
    argo-cd = {
      configs = merge(length(var.repositories) > 0 ? {
        repositories = var.repositories
        } : null, {
        secret = {
          extra = {
            "accounts.pipeline.tokens" = "${replace(var.argocd["accounts_pipeline_tokens"], "\\\"", "\"")}"
            "server.secretkey"         = "${replace(var.argocd["server_secretkey"], "\\\"", "\"")}"
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
      }
      server = merge({
        extraArgs = [
          "--insecure",
        ]
        config = {
          url                       = "https://${var.argocd["domain"]}"
          "admin.enabled"           = "${var.argocd["admin_enabled"]}"
          "accounts.pipeline"       = "apiKey"
          "configManagementPlugins" = <<-EOT
            - name: kustomized-helm # prometheus requirement
              init:
                command: ["/bin/sh", "-c"]
                args: ["helm dependency build]
              generate:
                command: ["/bin/sh", "-c"]
                args: ["echo \"$HELM_VALUES\" | helm template . --name-template $ARGOCD_APP_NAME --namespace $ARGOCD_APP_NAMESPACE $HELM_ARGS -f - --include-crds > all.yaml && kustomize build"]
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
        rbacConfig = {
          "policy.default" = ""
          "policy.csv"     = <<-EOT
                            g, pipeline, role:admin
                            g, argocd-admin, role:admin
                            EOT
          scopes           = "[groups, cognito:groups, roles]"
        }
        }, var.cluster_issuer == "ca-issuer" ? {
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
  }
  helm_values = [merge(local.default_values, var.oidc == null ? null : {
    argo-cd = {
      configs = {
        secret = {
          extra = {
            "oidc.default.clientSecret" = "${replace(var.oidc.clientSecret, "\\\"", "\"")}"
          }
        }
      }
      server = {
        config = {
          "oidc.config" = <<-EOT
            ${yamlencode(merge(var.oidc, { clientSecret = "$oidc.default.clientSecret" }))}
          EOT
        }
      }
    }
  }, )]
}
