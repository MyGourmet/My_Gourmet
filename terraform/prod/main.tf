# Terraform configuration to set up providers by version.
terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }
}

# Configures the provider to use the resource block's specified project for quota checks.
provider "google-beta" {
  user_project_override = true
  credentials           = file("my-gourmet-160fb-3f17914b9edb.json")
}

# Configures the provider to not use the resource block's specified project for quota checks.
# This provider should only be used during project creation and initializing services.
provider "google-beta" {
  alias                 = "no_user_project_override"
  user_project_override = false
}

resource "google_firebase_project" "default" {
  provider = google-beta
  project  = var.project_id
}

resource "google_firebase_storage_bucket" "default" {
  provider  = google-beta
  project   = var.project_id
  bucket_id = "my-gourmet-160fb.appspot.com"
}

resource "google_storage_bucket" "default" {
  provider = google-beta
  project  = var.project_id
  name     = "model-jp-my-gourmet-image-classification-2023-08"
  location = var.region

  public_access_prevention = "enforced"
}

resource "google_cloudfunctions2_function" "default" {
  provider = google-beta
  project  = var.project_id
  location = var.region
  name     = "classifyImage"

  build_config {
    entry_point = "handler"
    runtime     = "python311"

    source {
      storage_source {
        bucket     = "gcf-v2-sources-588802119789-asia-northeast1"
        object     = "classifyImage/function-source.zip"
        generation = 1701263863797525
      }
    }
  }

  service_config {
    all_traffic_on_latest_revision   = true
    available_cpu                    = "1000m"
    available_memory                 = "2Gi"
    ingress_settings                 = "ALLOW_ALL"
    max_instance_count               = 100
    max_instance_request_concurrency = 1
    min_instance_count               = 0
    service_account_email            = "588802119789-compute@developer.gserviceaccount.com"
    timeout_seconds                  = 3600
  }

  labels = {
    "deployment-tool" = "console-cloud"
  }
}

resource "google_firestore_database" "default" {
  provider    = google-beta
  project     = var.project_id
  type        = "FIRESTORE_NATIVE"
  location_id = var.region
  name        = "(default)"
}

resource "google_firebase_android_app" "default" {
  provider     = google-beta
  project      = var.project_id
  display_name = "my_gourmet"
  package_name = "com.example.my_gourmet"

  lifecycle {
    ignore_changes = [
      sha1_hashes,
      sha256_hashes,
    ]
  }
}

resource "google_project_service" "compute" {
  provider = google-beta
  project  = var.project_id
  service  = "compute.googleapis.com"
}

# resource "google_project_service" "firestore" {
#   provider = google-beta
#   project  = var.project_id
#   service  = "cloud_firestore.googleapis.com"
# }

# resource "google_project_service" "firebase_management" {
#   provider = google-beta
#   project  = var.project_id
#   service  = "firebasemanagement.googleapis.com"
# }

# resource "google_project_service" "cloud_functions" {
#   provider = google-beta
#   project  = var.project_id
#   service  = "cloudfunctions.googleapis.com"
# }

# resource "google_project_service" "cloud_resource_manager" {
#   provider = google-beta
#   project  = "my-gourmet-160fb"
#   service  = "cloudresourcemanager.googleapis.com"
# }
