output "cluster_name" {
  value = google_container_cluster.main.name
}

output "kubeconfig_command" {
  value = "gcloud container clusters get-credentials ${google_container_cluster.main.name} --zone asia-south1-a --project ${var.gcp_project_id}"
}

output "database_url" {
  sensitive = true
  value     = "postgresql://postgres:${var.db_password}@${google_sql_database_instance.postgres.public_ip_address}:5432/ideaboard"
}