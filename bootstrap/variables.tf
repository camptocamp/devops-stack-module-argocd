variable "helm_values" {
  description = "Helm values, passed as a list of HCL structures."
  type        = any
  default     = [{}]
}
