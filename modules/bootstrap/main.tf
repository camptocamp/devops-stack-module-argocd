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

  argocd_chart = yamldecode(file("${path.module}/../../charts/argocd/Chart.yaml")).dependencies.0

  argocd_server_secretkey = var.argocd_server_secretkey == null ? random_password.argocd_server_secretkey.result : var.argocd_server_secretkey

  argocd_values = [
    yamlencode(yamldecode(templatefile("${path.module}/../values.tmpl.yaml", {
      base_domain    = var.base_domain
      cluster_issuer = ""
      oidc = {
        client_id     = "deadbeef"
        client_secret = "deadbeef"
        issuer_url    = "http://deadbeef"
      }

      argocd                = local.argocd
      repositories          = {}
      server_admin_password = htpasswd_password.argocd_server_admin.bcrypt
    })).argo-cd)
  ]

  argocd = {
    namespace                = "argocd"
    domain                   = "argocd.apps.${var.cluster_name}.${var.base_domain}"
    accounts_pipeline_tokens = local.argocd_accounts_pipeline_tokens
    server_secretkey         = local.argocd_server_secretkey
    admin_enabled            = true
  }
}

resource "time_static" "iat" {}

resource "random_uuid" "jti" {}

resource "random_password" "argocd_server_secretkey" {
  length  = 32
  special = false
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = local.argocd_chart.repository
  chart      = "argo-cd"
  version    = local.argocd_chart.version

  namespace         = "argocd"
  dependency_update = true
  create_namespace  = true
  timeout           = 10800
  values            = local.argocd_values
}

resource "jwt_hashed_token" "argocd" {
  algorithm   = "HS256"
  secret      = local.argocd_server_secretkey
  claims_json = jsonencode(local.jwt_token_payload)
}

resource "random_password" "oauth2_cookie_secret" {
  length  = 16
  special = false
}

resource "random_password" "argocd_server_admin" {
  length  = 16
  special = false
}

resource "htpasswd_password" "argocd_server_admin" {
  password = random_password.argocd_server_admin.result
}
