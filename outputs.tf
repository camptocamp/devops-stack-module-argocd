output "id" {
  value = resource.null_resource.this.id
}

output "extra_tokens" {
  description = "Map of extra accounts and their tokens."
  value       = {for account in var.extra_accounts : account => jwt_hashed_token.tokens[account].token}
  sensitive   = true
}
