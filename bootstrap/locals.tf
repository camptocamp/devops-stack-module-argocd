#############################################################
# # [bootstrap] ArgoCD:
#
# * user should be able to login as admin for debugging purposes
# * admin should be disabled on final argocd install
# * user should have credential to configure `pipeline` account
#   for argocd provider
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

  # TODO drop this local and use absolute resource ref instead ?
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
          "admin.enabled"           = "true" # autogenerates password, see `argocd-initial-admin-secret`
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
          # scopes         = "[groups]" # TODO test me! https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml#L241
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

# argocd secret key for token generation, to be passed to next argocd generation
resource "random_password" "argocd_server_secretkey" {
  length  = 32
  special = false
}

# jwt token for `pipeline` account (e.g for provider config)
resource "jwt_hashed_token" "argocd" {
  algorithm   = "HS256"
  secret      = local.argocd_server_secretkey
  claims_json = jsonencode(local.jwt_token_payload)
}

resource "time_static" "iat" {}

resource "random_uuid" "jti" {}
