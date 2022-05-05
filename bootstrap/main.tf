locals {
  argocd_chart = yamldecode(file("${path.module}/../charts/argocd/Chart.yaml")).dependencies.0
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = local.argocd_chart.repository
  chart      = local.argocd_chart.name
  version    = local.argocd_chart.version

  namespace         = "argocd"
  dependency_update = true
  create_namespace  = true
  timeout           = 10800
  values            = [for i in concat([local.helm_values.0.argo-cd], var.helm_values) : yamlencode(i)]
}

resource "time_static" "iat" {}

resource "random_uuid" "jti" {}

resource "random_password" "argocd_server_secretkey" {
  length  = 32
  special = false
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

data "utils_deep_merge_yaml" "values" {
  input = [for i in concat(local.helm_values, [{"argo-cd" = tomap(var.helm_values.0)}]) : yamlencode(i)]
}

resource "null_resource" "this" {
  depends_on = [
    resource.helm_release.argocd,
  ]
}
