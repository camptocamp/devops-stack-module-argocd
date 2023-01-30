variable "cluster_name" {
  description = "The name of the cluster to create."
  type        = string
}

variable "cluster_issuer" {
  description = "Cluster Issuer"
  type        = string
}

variable "oidc" {
  description = "OIDC Settings"
  type        = any
  default     = null
}

variable "base_domain" {
  description = "The base domain for building Ingress following DevOps Stack convention, e.g. argocd.apps.<cluster_name>.<base_domain>"
  type        = string
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

variable "namespace" {
  description = "Destination Namespace for Application child resources."
  type        = string
  default     = "argocd"
}

variable "argocd_namespace" {
  description = "Namespace for the resources AppProject and Application."
  type        = string
  default     = "argocd"
}

variable "dependency_ids" {
  type    = map(string)
  default = {}
}

variable "target_revision" {
  description = "Override of target revision of the application chart."
  type        = string
  default     = "v1.0.0-alpha.5" # x-release-please-version
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

variable "admin_enabled" {
  description = "Flag to indicate whether to enable admin user."
  type        = bool
  default     = false
}

variable "accounts_pipeline_tokens" {
  description = "API token for pipeline account."
  type        = string
  sensitive   = true
}

variable "server_secretkey" {
  description = "Signature key for session validation. Must reuse bootstrap secretkey."
  type        = string
  sensitive   = false
}
