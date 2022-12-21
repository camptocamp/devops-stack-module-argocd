#############################################################
# ArgoCD bootstrap config:
#
# - admin enabled for debugging while creating cluster
# - admin credentials can be found in k8s secret
# - admin credentials to be disabled on second argocd install
# - pipeline account used for argocd provider config
#

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

  argocd_server_secretkey = random_password.argocd_server_secretkey.result

  helm_values = [{
    argo-cd = {
      controller = {
        metrics = {
          enabled = false
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
          enabled = false
        }
      }
      server = {
        extraArgs = [
          "--insecure",
        ]
        certificate = {
          enabled = false
        }
        ingress = {
          enabled = false
        }
        metrics = {
          enabled = false
        }
        config = {
          "admin.enabled"           = "true" # autogen password
          "accounts.pipeline"       = "apiKey"
          "configManagementPlugins" = <<-EOT
            - name: kustomized-helm # prometheus requirement
              init:
                command: ["/bin/sh", "-c"]
                args: ["helm dependency build"]
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
      }
      configs = {
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
            "accounts.pipeline.tokens" = "${replace(local.argocd_accounts_pipeline_tokens, "\\\"", "\"")}"
            "server.secretkey"         = "${replace(local.argocd_server_secretkey, "\\\"", "\"")}"
          }
        }
      }
    }
  }]
}

# bootstrap secret key
resource "random_password" "argocd_server_secretkey" {
  length  = 32
  special = false
}

# jwt for argocd auth token (used e.g for argocd's provider config)
resource "jwt_hashed_token" "argocd" {
  algorithm   = "HS256"
  secret      = local.argocd_server_secretkey
  claims_json = jsonencode(local.jwt_token_payload)
}

resource "time_static" "iat" {}

resource "random_uuid" "jti" {}