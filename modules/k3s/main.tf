module "argocd" {
  source = "../"

  cluster_name = var.cluster_name
  base_domain  = var.base_domain
  oidc         = var.oidc
  argocd       = var.argocd

  cluster_issuer = var.cluster_issuer
  namespace      = var.namespace
  profiles       = var.profiles

  repositories   = var.repositories

  extra_yaml = [ templatefile("${path.module}/values.yaml", {}) ]
}
