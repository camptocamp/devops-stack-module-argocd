
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
        enabled = false
      }
      repoServer = {
        metrics = {
          enabled = false
        }
      }
      server = merge({
        extraArgs = [
          "--insecure",
        ]
        config = {
          "admin.enabled"     = "false"
          "accounts.pipeline" = "apiKey"
        }
        ingress = {
          enabled = false
        }
        metrics = {
          enabled = false
        }
      })
    }
  }]
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