output "argocd_namespace" {
  value = helm_release.argocd.metadata.0.namespace
}

output "values" {
  sensitive = true
  value     = [yamldecode(data.utils_deep_merge_yaml.values.output)]
}

output "id" {
  value = resource.null_resource.this.id
}

output "argocd_server_secretkey" {
  sensitive   = true
  description = "The ArgoCD server secret key."
  value       = local.argocd_server_secretkey
}

output "argocd_auth_token" {
  sensitive   = true
  description = "The token to set in ARGOCD_AUTH_TOKEN environment variable. May be used for configuring argocd terraform provider"
  value       = jwt_hashed_token.argocd.token
}

output "argocd_accounts_pipeline_tokens" {
  description = "The ArgoCD accounts pipeline tokens."
  value       = local.argocd_accounts_pipeline_tokens
}
