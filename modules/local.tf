locals {
  argocd_default = {
    namespace                = "argocd"
    admin_enabled            = false
  }

  argocd = merge(
    local.argocd_default,
    var.argocd,
  )
}
