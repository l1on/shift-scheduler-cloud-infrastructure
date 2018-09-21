variable "project_id" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "cluster_zone" {
  type = "string"
}

variable "ip_region" {
  type = "string"
}

terraform {
  backend "gcs" {
    bucket  = "shift-scheduler-4627-terraform-state"
  }
}

provider "google" {}

resource "google_compute_address" "ip" {
  name = "load-balancer-ip"
  project = "${var.project_id}"
  region = "${var.ip_region}"

  provisioner "local-exec" {
    working_dir = "../../../shift-scheduler-app"

    command = <<EOF
      sed 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/${google_compute_address.ip.address}/' public/_redirects > public/_redirects.bk
      mv public/_redirects.bk public/_redirects
      git add public/_redirects
      git commit -m "Changed load balancer IP for the cluster."
      git push
    EOF
  }

    provisioner "local-exec" {
      when = "destroy"
      working_dir = "../../../shift-scheduler-app"

      command = <<EOF
        sed 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/0.0.0.0/' public/_redirects | tee public/_redirects
        git add public/_redirects
        git commit -m "Removed load balancer IP for the cluster."
        git push
      EOF
    }
}

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
