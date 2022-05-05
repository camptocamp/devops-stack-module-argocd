locals {
  helm_values = [{
    argo-cd = {
      configs = merge(length(var.repositories) > 0 ? {
        repositories = var.repositories
        } : null, {
        secret = {
          argocdServerAdminPassword      = "${htpasswd_password.argocd_server_admin.bcrypt}"
          argocdServerAdminPasswordMtime = "2020-07-23T11:31:23Z"
          extra = {
            "oidc.default.clientSecret" = "${replace(local.oidc.client_secret, "\\\"", "\"")}"
            "accounts.pipeline.tokens"  = "${replace(local.argocd.accounts_pipeline_tokens, "\\\"", "\"")}"
            "server.secretkey"          = "${replace(local.argocd.server_secretkey, "\\\"", "\"")}"
          }
        }
      })
      controller = {
        metrics = {
          enabled = true
        }
      }
      dex = {
        metrics = {
          enabled = true
        }
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
          "admin.enabled"           = "${local.argocd.admin_enabled}"
          "accounts.pipeline"       = "apiKey"
          "resource.customizations" = <<-EOT
            argoproj.io/Application:
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
            networking.k8s.io/Ingress:
              health.lua: |
                hs = {}
                hs.status = "Healthy"
                return hs
                EOT
          configManagementPlugins   = <<-EOT
                - name: kustomized-helm
                  init:
                    command: ["/bin/sh", "-c"]
                    args: ["helm dependency build || true"]
                  generate:
                    command: ["/bin/sh", "-c"]
                    args: ["echo \"$HELM_VALUES\" | helm template . --name-template $ARGOCD_APP_NAME --namespace $ARGOCD_APP_NAMESPACE $HELM_ARGS -f - --include-crds > all.yaml && kustomize build"]
                        EOT
          url                       = "https://${local.argocd.domain}"
          # TODO check and potentially change the following var references
          "oidc.config" = <<-EOT
                name: OIDC
                issuer: "${replace(local.oidc.issuer_url, "\"", "\\\"")}"
                clientID: "${replace(local.oidc.client_id, "\"", "\\\"")}"
                clientSecret: "${local.oidc.client_secret}"
                requestedIDTokenClaims:
                  groups:
                    essential: true
                requestedScopes:
                  - openid
                  - profile
                  - email
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
            "${local.argocd.domain}",
            "argocd.apps.${var.base_domain}",
          ]
          tls = [
            {
              secretName = "argocd-tls"
              hosts = [
                "${local.argocd.domain}",
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
  }]
}
