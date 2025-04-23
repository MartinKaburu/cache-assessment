terraform {
  backend "gcs" {
    bucket  = "cache-assessment-tf-state-bucket"
    prefix  = "cache/staging/terraform.tfstate"
  }
}
