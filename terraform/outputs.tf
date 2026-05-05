output "demo_bank_app_repository_url" {
  description = "ECR repository URL for demo-bank-app"
  value       = module.ecr_demo_bank_app.repository_url
}

output "demo_bank_app_repository_arn" {
  description = "ECR repository ARN for demo-bank-app"
  value       = module.ecr_demo_bank_app.repository_arn
}

output "my_node_app_repository_url" {
  description = "ECR repository URL for my-node-app"
  value       = module.ecr_my_node_app.repository_url
}

output "my_node_app_repository_arn" {
  description = "ECR repository ARN for my-node-app"
  value       = module.ecr_my_node_app.repository_arn
}

output "my_nginx_app_repository_url" {
  description = "ECR repository URL for my-nginx-app"
  value       = module.ecr_my_nginx_app.repository_url
}

output "my_nginx_app_repository_arn" {
  description = "ECR repository ARN for my-nginx-app"
  value       = module.ecr_my_nginx_app.repository_arn
}

output "ecr_replication_dr_region" {
  description = "DR region where both ECR repositories are replicated"
  value       = var.dr_region
}
