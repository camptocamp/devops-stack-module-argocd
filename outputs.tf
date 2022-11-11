output "id" {
  value = resource.null_resource.this.id
}

output "deep_merge_values" {
  value = data.utils_deep_merge_yaml.values.output
}

output "values" {
  value     = [yamldecode(data.utils_deep_merge_yaml.values.output)]
  sensitive = true
}

output "argocd_server_admin_password" {
  description = "The ArgoCD admin password."
  sensitive   = true
  value       = random_password.argocd_server_admin.result
}