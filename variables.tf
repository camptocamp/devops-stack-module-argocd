#######################
## Standard variables
#######################

variable "cluster_name" {
  description = "Name given to the cluster. Value used for the ingress' URL of the application."
  type        = string
}

variable "base_domain" {
  description = "Base domain of the cluster. Value used for the ingress' URL of the application."
  type        = string
}

variable "argocd_namespace" {
  description = "Namespace used by Argo CD where the Application and AppProject resources should be created. Normally, it should take the outputof the namespace from the bootstrap module."
  type        = string
  default     = "argocd"
}

variable "target_revision" {
  description = "Override of target revision of the application chart."
  type        = string
  default     = "v3.0.0" # x-release-please-version
}

variable "cluster_issuer" {
  description = "SSL certificate issuer to use. Usually you would configure this value as `letsencrypt-staging` or `letsencrypt-prod` on your root `*.tf` files."
  type        = string
  default     = "ca-issuer"
}

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

variable "dependency_ids" {
  type    = map(string)
  default = {}
}

#######################
## Module variables
#######################

variable "oidc" {
  description = "OIDC settings for logging to the Argo CD web interface."
  type        = any
  default     = null
}

variable "repositories" {
  description = "List of repositories to add to Argo CD."
  type        = map(map(string))
  default     = {}
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
  description = "Signature key for session validation. *Must reuse the bootstrap output containing the secretkey.*"
  type        = string
  sensitive   = false
}

variable "extra_accounts" {
  description = "List of accounts for which tokens will be generated."
  type        = list(string)
  default     = []
}

variable "repo_server_iam_role_arn" {
  description = "IAM role ARN to associate with the argocd-repo-server ServiceAccount. This role can be used to give SOPS access to AWS KMS."
  type        = string
  default     = null
}

variable "repo_server_azure_workload_identity_clientid" {
  description = "Azure AD Workload Identity Client-ID to associate with argocd-repo-server. This role can be used to give SOPS access to a Key Vault."
  type        = string
  default     = null
}

variable "repo_server_aadpodidbinding" {
  description = "Azure AAD Pod Identity to associate with the argocd-repo-server Pod. This role can be used to give SOPS access to a Key Vault."
  type        = string
  default     = null
}

variable "helmfile_cmp_version" {
  description = "Version of the helmfile-cmp plugin."
  type        = string
  default     = "0.1.1"
}

variable "helmfile_cmp_env_variables" {
  description = "List of environment variables to attach to the helmfile-cmp plugin, usually used to pass authentication credentials. Use a an https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/[explicit format] or take the values from a https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#define-container-environment-variables-using-secret-data[Kubernetes secret]."
  type = list(object({
    name  = optional(string)
    value = optional(string)
    valueFrom = optional(object({
      secretKeyRef = optional(object({
        name = optional(string)
        key  = optional(string)
      }))
    }))
  }))
  default = []
}
