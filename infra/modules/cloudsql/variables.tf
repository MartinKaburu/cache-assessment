variable "instance_name" {}

variable "region" {}

variable "network" {}

variable "db_name" {}

variable "db_user" {}

variable "env" {}

variable "db_password" {
    description = "Sensitive DB password"
    sensitive   = true
}
