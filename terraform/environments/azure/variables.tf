variable "location" {
  type    = string
  default = "centralindia"
}

variable "project_name" {
  type    = string
  default = "ideaboard"
}

variable "db_password" {
  type      = string
  sensitive = true
}