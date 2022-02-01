#######################
## Standard variables
#######################

variable "cluster_info" {
  type = object({
    cluster_name     = string
    base_domain      = string
    argocd_namespace = string
  })
}

variable "oidc" {
  type    = any
  default = {}
}

variable "cluster_issuer" {
  type    = string
  default = "ca-issuer"
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "extra_yaml" {
  type    = list(string)
  default = []
}

#######################
## Module variables
#######################

variable "argocd" {
  type = object({
    server_secretkey         = string
    accounts_pipeline_tokens = string
    server_admin_password    = string
    domain                   = string
    admin_enabled            = bool
  })
}

variable "repositories" {
  description = "A list of repositories to add to ArgoCD."
  type        = map(map(string))
  default     = {}
}
