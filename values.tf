locals {
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
