output "argocd_namespace" {
  value = helm_release.argocd.metadata.0.namespace
}

output "id" {
  value = resource.null_resource.this.id
}

output "argocd_server_secretkey" {
  sensitive   = true
  description = "The ArgoCD server secret key."
  value       = random_password.argocd_server_secretkey.result
}

output "argocd_auth_token" {
  sensitive   = true
  description = "The token to set in ARGOCD_AUTH_TOKEN environment variable. May be used for configuring argocd terraform provider"
  value       = jwt_hashed_token.argocd.token
}

output "argocd_accounts_pipeline_tokens" {
  description = "The ArgoCD accounts pipeline tokens."
  value       = local.argocd_accounts_pipeline_tokens
  sensitive   = true
}
