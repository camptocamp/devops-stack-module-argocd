resource "argocd_project" "this" {
  metadata {
    name      = "argocd"
    namespace = var.argocd.namespace
    annotations = {
      "devops-stack.io/argocd_namespace" = var.argocd.namespace
    }
  }

  spec {
    description  = "argocd application project"
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

resource "htpasswd_password" "argocd_server_admin" {
  password = var.argocd.server_admin_password
}

data "utils_deep_merge_yaml" "values" {
  input = local.all_yaml
}

resource "argocd_application" "this" {
  metadata {
    name      = "argocd"
    namespace = var.argocd.namespace
  }

  cascade = false

  spec {
    project = argocd_project.this.metadata.0.name

    source {
      repo_url        = "https://github.com/camptocamp/devops-stack-module-argocd.git"
      path            = "charts/argocd"
      target_revision = "main"
      helm {
        values = data.utils_deep_merge_yaml.values.output
      }
    }

    destination {
      name      = "in-cluster"
      namespace = var.namespace
    }

    sync_policy {
      automated = {
        allow_empty = false
        prune       = true
        self_heal   = true
      }

      sync_options = [
        "CreateNamespace=true"
      ]

      retry {
        backoff = {}
        limit   = "0"
      }
    }
  }
}
