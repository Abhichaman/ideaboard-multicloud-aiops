variable "project_name" {
  type = string
}

variable "gcp_project_id" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}