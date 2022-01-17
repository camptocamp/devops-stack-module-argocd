terraform {
  required_providers {
    argocd = {
      source = "oboukili/argocd"
    }
    utils = {
      source = "cloudposse/utils"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "~> 0.9"
    }
  }
}
