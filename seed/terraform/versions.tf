terraform {
  required_version = ">= 1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }

  backend "gcs" {
    prefix = "seed/bootstrap"
  }
}

provider "google" {
  project = var.seed_gcp_project_id
  region  = var.gcp_region
}
