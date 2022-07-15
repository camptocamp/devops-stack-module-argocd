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
  default     = [{}]
}

variable "argocd_server_secretkey" {
  description = "ArgoCD Server Secert Key to avoid regenerate token on redeploy."
  type        = string
  default     = null
}
