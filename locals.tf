locals {
  
  argocd_default = {
    namespace                = "argocd"
    domain                   = "argocd.apps.${var.cluster_name}.${var.base_domain}"
    accounts_pipeline_tokens = ""
    server_secretkey         = var.argocd_server_secretkey
    admin_enabled            = "false"
  }

  argocd = merge(local.argocd_default, var.argocd)

  helm_values = [merge({}, var.oidc == null ? null : {
    argo-cd = {
      configs = {
        secret = {
          extra = {
            "oidc.default.clientSecret" = "${replace(var.oidc.clientSecret, "\\\"", "\"")}"
          }
        }
      }
      server = {
        config = {
          "oidc.config" = <<-EOT
            ${yamlencode(merge(var.oidc, { clientSecret = "$oidc.default.clientSecret" }))}
          EOT
        }
      }
    }
  })]
}

