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