locals {
  argocd_chart = yamldecode(file("${path.module}/../charts/argocd/Chart.lock")).dependencies.0
}

# argocd secret key for token generation, it should be passed to next argocd generation
resource "random_password" "argocd_server_secretkey" {
  length  = 32
  special = false
}

# jwt token for `pipeline` account
resource "jwt_hashed_token" "argocd" {
  algorithm   = "HS256"
  secret      = random_password.argocd_server_secretkey.result
  claims_json = jsonencode(local.jwt_token_payload)
}

resource "time_static" "iat" {}

resource "random_uuid" "jti" {}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret_v1" "avp_config" {
  metadata {
    name      = "avp-config"
    namespace = var.namespace
  }

  data = var.avp_config

  depends_on = [
    kubernetes_namespace.namespace
  ]
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = local.argocd_chart.repository
  chart      = local.argocd_chart.name
  version    = local.argocd_chart.version

  namespace         = var.namespace
  dependency_update = true
  create_namespace  = false
  timeout           = 10800
  values            = [data.utils_deep_merge_yaml.values.output, sensitive(yamlencode(local.sensitive_values.0.argo-cd))]

  depends_on = [
    kubernetes_secret_v1.avp_config
  ]

  lifecycle {
    ignore_changes = all
  }
}

data "utils_deep_merge_yaml" "values" {
  input       = [for i in concat(local.helm_values, var.helm_values) : yamlencode(i.argo-cd)]
  append_list = true
}

resource "null_resource" "this" {
  depends_on = [
    resource.helm_release.argocd,
  ]
}
