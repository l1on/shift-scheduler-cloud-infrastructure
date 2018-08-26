variable "project_id" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "cluster_zone" {
  type = "string"
}

variable "bucket_name" {
  type = "string"
}


terraform {
  backend "gcs" {
    bucket  = "${var.bucket_name}"
  }
}

provider "google" {}

resource "google_container_cluster" "primary" {
  name    = "${var.cluster_name}"
  project = "${var.project_id}"
  zone    = "${var.cluster_zone}"

  node_pool {
    initial_node_count = 3

    management {
      auto_repair  = true
      auto_upgrade = true
    }

    autoscaling {
      min_node_count = 1
      max_node_count = 6
    }

    node_config {
      disk_size_gb = 10
      machine_type = "g1-small"

      oauth_scopes = [
        "https://www.googleapis.com/auth/compute",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
      ]
    }
  }
}
