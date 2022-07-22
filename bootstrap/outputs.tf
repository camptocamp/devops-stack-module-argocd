output "argocd_server_secretkey" {
  description = "The ArgoCD server secret key."
  sensitive   = true
  value       = local.argocd_server_secretkey
}

output "argocd_accounts_pipeline_tokens" {
  description = "The ArgoCD accounts pipeline tokens."
  sensitive   = true
  value       = local.argocd_accounts_pipeline_tokens
}

output "argocd_namespace" {
  value = helm_release.argocd.metadata.0.namespace
}

output "argocd_domain" {
  value = local.argocd.domain
}

output "bootstrap_values" {
  value = [yamldecode(data.utils_deep_merge_yaml.values.output)]
  sensitive = true
}

output "id" {
  value = resource.null_resource.this.id
}
