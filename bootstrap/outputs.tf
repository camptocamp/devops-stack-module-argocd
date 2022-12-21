output "argocd_namespace" {
  value = helm_release.argocd.metadata.0.namespace
}

output "values" {
  value     = [yamldecode(data.utils_deep_merge_yaml.values.output)]
  sensitive = true
}

output "id" {
  value = resource.null_resource.this.id
}

output "argocd_server_secretkey" {
  description = "The ArgoCD server secret key."
  sensitive   = true
  value       = local.argocd_server_secretkey
}

output "argocd_auth_token" {
  description = "The token to set in ARGOCD_AUTH_TOKEN environment variable. May be used for configuring argocd terraform provider"
  value       = jwt_hashed_token.argocd.token
  sensitive   = true
}
