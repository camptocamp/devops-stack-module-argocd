terraform {
  required_providers {
    argocd = {
      source  = "oboukili/argocd"
      version = "~> 4.2"
    }
    utils = {
      source  = "cloudposse/utils"
      version = "~> 1.6"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "~> 0.9"
    }
    jwt = {
      source  = "camptocamp/jwt"
      version = "~> 1.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.2"
}
