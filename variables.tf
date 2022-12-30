variable "cluster_name" {
  description = "The name of the cluster to create."
  type        = string
  default     = ""
}

variable "base_domain" {
  description = "The base domain used for Ingresses."
  type        = string
  default     = ""
}

variable "cluster_issuer" {
  description = "Cluster Issuer"
  type        = string
  default     = ""
}

variable "oidc" {
  description = "OIDC Settings"
  type        = any
  default     = null
}

variable "argocd" {
  description = "ArgoCD settings"
  type        = any
  default     = {}
}

variable "repositories" {
  description = "A list of repositories to add to ArgoCD."
  type        = map(map(string))
  default     = {}
}

variable "helm_values" {
  description = "Helm values, passed as a list of HCL structures."
  type        = any
  default = [{
    argo-cd = {}
  }]
}

variable "argocd_server_secretkey" {
  description = "ArgoCD Server Secert Key to avoid regenerate token on redeploy."
  type        = string
  default     = null
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "argocd_namespace" {
  type    = string
  default = "argocd"
}

variable "dependency_ids" {
  type    = map(string)
  default = {}
}

variable "target_revision" {
  description = "Override of target revision of the application chart."
  type        = string
  default     = "v1.0.0-alpha.4" # x-release-please-version
}

variable "app_autosync" {
  description = "Automated sync options for the Argo CD Application resource."
  type = object({
    allow_empty = optional(bool)
    prune       = optional(bool)
    self_heal   = optional(bool)
  })
  default = {
    allow_empty = false
    prune       = true
    self_heal   = true
  }
}
