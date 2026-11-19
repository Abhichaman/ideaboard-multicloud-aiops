provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

module "gcp_platform" {
  source         = "../../modules/gcp-platform"
  project_name   = var.project_name
  gcp_project_id = var.gcp_project_id
  db_password    = var.db_password
}

output "cluster_name" {
  value = module.gcp_platform.cluster_name
}

output "kubeconfig_command" {
  value = module.gcp_platform.kubeconfig_command
}

output "database_url" {
  sensitive = true
  value     = module.gcp_platform.database_url
}