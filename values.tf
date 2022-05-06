locals {
  helm_values = [{
    argo-cd = {
      configs = {
        secret = {
          extra = {
            "oidc.default.clientSecret" = "${replace(local.oidc.client_secret, "\\\"", "\"")}"
          }
        }
      }
      server = {
        config = {
          # TODO check and potentially change the following var references
          "oidc.config" = <<-EOT
                name: OIDC
                issuer: "${replace(local.oidc.issuer_url, "\"", "\\\"")}"
                clientID: "${replace(local.oidc.client_id, "\"", "\\\"")}"
                clientSecret: "${local.oidc.client_secret}"
                requestedIDTokenClaims:
                  groups:
                    essential: true
                EOT
        }
      }
    }
  }]
}
