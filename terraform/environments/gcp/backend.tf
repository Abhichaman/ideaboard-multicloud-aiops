terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Production Remote State (Uncomment after creating GCS bucket)
  # backend "gcs" {
  #   bucket = "ideaboard-tf-state-gcp"
  #   prefix = "gcp/state"
  # }
}