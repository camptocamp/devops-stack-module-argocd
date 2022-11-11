
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

  argocd_server_secretkey = var.argocd_server_secretkey == null ? random_password.argocd_server_secretkey.result : var.argocd_server_secretkey


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
