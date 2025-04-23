variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "cache-assessment"
}

variable "region" {
  default = "us-east1"
}

variable "db_user" {
  default = "app_user"
}

variable "db_password" {
  description = "Sensitive DB password"
  sensitive = true
}
