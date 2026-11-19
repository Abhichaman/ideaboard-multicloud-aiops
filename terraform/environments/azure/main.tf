provider "azurerm" {
  features {}
}

module "azure_platform" {
  source       = "../../modules/azure-platform"
  project_name = var.project_name
  location     = var.location
  db_password  = var.db_password
}

output "cluster_name" {
  value = module.azure_platform.cluster_name
}

output "kubeconfig_command" {
  value = module.azure_platform.kubeconfig_command
}

output "database_url" {
  sensitive = true
  value     = module.azure_platform.database_url
}