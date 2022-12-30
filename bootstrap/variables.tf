variable "namespace" {
  type    = string
  default = "argocd"
}

variable "helm_values" {
  description = "Helm values, passed as a list of HCL structures."
  type        = any
  default     = [{
    argo-cd = {}
  }]
}
