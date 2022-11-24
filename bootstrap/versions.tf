terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    utils = {
      source = "cloudposse/utils"
    }
    htpasswd = {
      source = "loafoe/htpasswd"
    }
    jwt = {
      source = "camptocamp/jwt"
    }
  }
  required_version = ">= 0.13"
}
