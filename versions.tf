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
    jwt = {
      source  = "camptocamp/jwt"
      version = ">= 0.0.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.6"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
