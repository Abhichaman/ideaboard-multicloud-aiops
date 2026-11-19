variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type    = string
  default = "asia-south1"
}

variable "project_name" {
  type    = string
  default = "ideaboard"
}

variable "db_password" {
  type      = string
  sensitive = true
}