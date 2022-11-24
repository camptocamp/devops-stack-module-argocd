
locals {
  argocd_server_secretkey = var.argocd_server_secretkey == null ? random_password.argocd_server_secretkey.result : var.argocd_server_secretkey

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
        config = {
          "admin.enabled"     = "true"
          "accounts.pipeline" = "apiKey"
          configManagementPlugins   = <<-EOT
                - name: kustomized-helm
                  init:
                    command: ["/bin/sh", "-c"]
                    args: ["helm dependency build || true"]
                  generate:
                    command: ["/bin/sh", "-c"]
                    args: ["echo \"$HELM_VALUES\" | helm template . --name-template $ARGOCD_APP_NAME --namespace $ARGOCD_APP_NAMESPACE $HELM_ARGS -f - --include-crds > all.yaml && kustomize build"]
                EOT
        }
        ingress = {
          enabled = false
        }
        metrics = {
          enabled = false
        }
      }
      configs = {
        secret = {
          extra = {
            "accounts.pipeline.tokens" = "${replace(local.argocd_accounts_pipeline_tokens, "\\\"", "\"")}"
            "server.secretkey"         = "${replace(local.argocd_server_secretkey, "\\\"", "\"")}"
          }
        }
      }
      rbacConfig = {
        scopes           = "[groups, cognito:groups, roles]"
        "policy.default" = ""
        "policy.csv"     = <<-EOT
                          g, pipeline, role:admin
                          g, argocd-admin, role:admin
                          EOT
        }
      }
  }]
}

resource "htpasswd_password" "argocd_server_admin" {
  password = random_password.argocd_server_admin.result
}

resource "random_password" "argocd_server_admin" {
  length  = 16
  special = false
}

resource "random_password" "argocd_server_secretkey" {
  length  = 32
  special = false
}

resource "jwt_hashed_token" "argocd" {
  algorithm   = "HS256"
  secret      = local.argocd_server_secretkey
  claims_json = jsonencode(local.jwt_token_payload)
}

resource "time_static" "iat" {}

resource "random_uuid" "jti" {}