provider "aws" {
  region = var.aws_region
}

module "aws_platform" {
  source       = "../../modules/aws-platform"
  project_name = var.project_name
  db_password  = var.db_password
}

output "cluster_name" {
  value = module.aws_platform.cluster_name
}

output "kubeconfig_command" {
  value = module.aws_platform.kubeconfig_command
}

output "database_url" {
  sensitive = true
  value     = module.aws_platform.database_url
}