# 1. GKE Cluster & Node Pool
resource "google_container_cluster" "main" {
  name                = "${var.project_name}-gke"
  location            = "asia-south1-a"
  initial_node_count  = 1
  deletion_protection = false

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# 2. Managed PostgreSQL (Cloud SQL)
resource "google_sql_database_instance" "postgres" {
  name                = "${var.project_name}-pg"
  database_version    = "POSTGRES_15"
  region              = "asia-south1"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "allow-all"
        value = "0.0.0.0/0"
      }
    }
  }
}

resource "google_sql_database" "db" {
  name     = "ideaboard"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "user" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}