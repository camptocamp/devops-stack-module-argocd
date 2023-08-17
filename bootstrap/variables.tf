variable "namespace" {
  description = "Namespace where to deploy Argo CD."
  type        = string
  default     = "argocd"
}

variable "helm_values" {
  description = "Helm chart value overrides. They should be passed as a list of HCL structures."
  type        = any
  default = [{
    argo-cd = {}
  }]
}

variable "avp_config" {
  description = "Backend config of ArgoCD Vault plugin."
  type        = any # Note type is any for the moment. TODO check how define per provider object. Submodules ?
}
