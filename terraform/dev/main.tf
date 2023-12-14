# Terraform configuration for development environment
terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }
}

# Use separate credentials for the development environment if necessary
provider "google-beta" {
  user_project_override = true
  credentials           = file("my-gourmet-160fb-3f17914b9edb.json")
}

provider "google-beta" {
  alias                 = "no_user_project_override"
  user_project_override = false
}

resource "google_firebase_project" "default" {
  provider = google-beta
  project  = var.project_id
}

# Ensure bucket names are unique for the development environment
resource "google_firebase_storage_bucket" "default" {
  provider  = google-beta
  project   = var.project_id
  bucket_id = "dev-my-gourmet.appspot.com"
}

resource "google_storage_bucket" "default" {
  provider = google-beta
  project  = var.project_id
  name     = "dev-model-jp-my-gourmet-image-classification"
  location = var.region

  public_access_prevention = "enforced"
}

# Update cloud function names and sources for development
resource "google_cloudfunctions2_function" "default" {
  provider = google-beta
  project  = var.project_id
  location = var.region
  name     = "dev-classifyImage"

  build_config {
    entry_point = "handler"
    runtime     = "python311"

    source {
      storage_source {
        bucket = "dev-gcf-v2-sources"
        object = "dev-classifyImage/function-source.zip"
      }
    }
  }

  service_config {
    // Configurations may vary based on environment requirements
  }

  labels = {
    "environment" = "development"
  }
}

resource "google_firestore_database" "default" {
  provider    = google-beta
  project     = var.project_id
  type        = "FIRESTORE_NATIVE"
  location_id = var.region
  name        = "(default)"
}

# Update android app configurations for development
resource "google_firebase_android_app" "default" {
  provider     = google-beta
  project      = var.project_id
  display_name = "dev_my_gourmet"
  package_name = "com.example.dev_my_gourmet"

  lifecycle {
    ignore_changes = [
      sha1_hashes,
      sha256_hashes,
    ]
  }
}

# Commented-out resources can be enabled if those services are needed in development
# Make sure to use the correct project ID and service names for the dev environment
