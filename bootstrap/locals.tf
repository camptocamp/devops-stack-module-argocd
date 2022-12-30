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

  helm_values = [{
    argo-cd = {
      dex = {
        enabled = false
      }
      server = {
        extraArgs = [
          "--insecure",
        ]
        config = {
          "admin.enabled"           = "true" # autogenerates password, see `argocd-initial-admin-secret`
          "accounts.pipeline"       = "apiKey"
          "configManagementPlugins" = <<-EOT
            - name: kustomized-helm # prometheus requirement
              init:
                command: ["/bin/sh", "-c"]
                args: ["helm dependency build || true"]
              generate:
                command: ["/bin/sh", "-c"]
                args: ["echo \"$ARGOCD_ENV_HELM_VALUES\" | helm template . --name-template $ARGOCD_APP_NAME --namespace $ARGOCD_APP_NAMESPACE $ARGOCD_ENV_HELM_ARGS -f - --include-crds > all.yaml && kustomize build"]
          EOT
          "resource.customizations" = <<-EOT
            argoproj.io/Application: # https://argo-cd.readthedocs.io/en/stable/operator-manual/health/#argocd-app
              health.lua: |
                hs = {}
                hs.status = "Progressing"
                hs.message = ""
                if obj.status ~= nil then
                  if obj.status.health ~= nil then
                    hs.status = obj.status.health.status
                    if obj.status.health.message ~= nil then
                      hs.message = obj.status.health.message
                    end
                  end
                end
                return hs
            networking.k8s.io/Ingress: # https://argo-cd.readthedocs.io/en/stable/faq/#why-is-my-application-stuck-in-progressing-state
              health.lua: |
                hs = {}
                hs.status = "Healthy"
                return hs
          EOT
        }
      }
      configs = {
        rbac = {
          scopes           = "[groups, cognito:groups, roles]"
          "policy.default" = ""
          "policy.csv"     = <<-EOT
                              g, pipeline, role:admin
                              g, argocd-admin, role:admin
                              EOT
        }
        secret = {
          extra = {
            "accounts.pipeline.tokens" = "${replace(local.argocd_accounts_pipeline_tokens, "\\\"", "\"")}"
            "server.secretkey"         = "${replace(random_password.argocd_server_secretkey.result, "\\\"", "\"")}"
          }
        }
      }
    }
  }]
}
