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

  argocd_default = {
    namespace                = "argocd"
    domain                   = "argocd.apps.${var.cluster_name}.${var.base_domain}"
    accounts_pipeline_tokens = local.argocd_accounts_pipeline_tokens
    server_secretkey         = local.argocd_server_secretkey
    admin_enabled            = "false"
  }

  argocd = merge(local.argocd_default, var.argocd)
}
