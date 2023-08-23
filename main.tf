resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

resource "jwt_hashed_token" "tokens" {
  for_each = toset(var.extra_accounts)

  algorithm   = "HS256"
  secret      = var.server_secretkey
  claims_json = jsonencode(local.jwt_tokens[each.value])
}

resource "time_static" "iat" {
  for_each = toset(var.extra_accounts)
}

resource "random_uuid" "jti" {
  for_each = toset(var.extra_accounts)
}

resource "vault_generic_secret" "argocd_secrets" {
  path = "secret/devops-stack/submodules/argocd"
  data_json = jsonencode({
    argocd-accounts-pipeline-tokens  = var.accounts_pipeline_tokens
    argocd-server-secretkey          = var.server_secretkey
    argocd-oidc-default-clientSecret = var.oidc.clientSecret
  })
}

resource "argocd_project" "this" {
  metadata {
    name      = "argocd"
    namespace = var.argocd_namespace
    annotations = {
      "devops-stack.io/argocd_namespace" = var.argocd_namespace
    }
  }

  spec {
    description  = "Argo CD application project"
    source_repos = ["https://github.com/camptocamp/devops-stack-module-argocd.git"]

    destination {
      name      = "in-cluster"
      namespace = var.namespace
    }

    orphaned_resources {
      warn = true
    }

    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }
  }
}

data "utils_deep_merge_yaml" "values" {
  input       = [for i in concat(local.helm_values, var.helm_values) : yamlencode(i)]
  append_list = true
}

resource "argocd_application" "this" {
  metadata {
    name      = "argocd"
    namespace = var.argocd_namespace
  }

  wait    = var.app_autosync == { "allow_empty" = tobool(null), "prune" = tobool(null), "self_heal" = tobool(null) } ? false : true
  cascade = false

  spec {
    project = argocd_project.this.metadata.0.name

    source {
      path            = "charts/argocd"
      repo_url        = "https://github.com/camptocamp/devops-stack-module-argocd.git"
      target_revision = var.target_revision
      plugin {
        name = "avp-helm"
        env {
          name  = "HELM_VALUES"
          value = data.utils_deep_merge_yaml.values.output
        }
      }
    }

    destination {
      name      = "in-cluster"
      namespace = var.namespace
    }

    sync_policy {
      automated = var.app_autosync

      retry {
        backoff = {
          duration     = ""
          max_duration = ""
        }
        limit = "0"
      }

      sync_options = [
        "CreateNamespace=true"
      ]
    }
  }

  depends_on = [
    resource.null_resource.dependencies,
  ]
}

resource "null_resource" "this" {
  depends_on = [
    resource.argocd_application.this,
  ]
}

