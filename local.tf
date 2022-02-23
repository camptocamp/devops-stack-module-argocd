locals {
  argocd_default = {
    namespace     = "argocd"
    admin_enabled = false
  }

  argocd = merge(
    local.argocd_default,
    var.argocd,
  )

  default_yaml = [templatefile("${path.module}/values.tmpl.yaml", {
    base_domain    = var.base_domain,
    cluster_issuer = var.cluster_issuer
    oidc           = var.oidc

    argocd                = local.argocd
    repositories          = var.repositories
    server_admin_password = htpasswd_password.argocd_server_admin.bcrypt
  })]
  all_yaml = concat(local.default_yaml, var.extra_yaml)
}
