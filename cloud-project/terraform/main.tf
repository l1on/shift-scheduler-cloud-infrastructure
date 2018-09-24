terraform {
  backend "gcs" {
    bucket  = "shift-scheduler-20217-terraform-state"
  }
}

provider "google" {
  version = "1.13"
}

###############################################################################
# GCP Kubernetes Load Balancer IP
###############################################################################
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

###############################################################################
# GCP Kubernetes Cluster
###############################################################################
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

###############################################################################
# Deployment Service Account for GCP 
###############################################################################
resource "google_service_account" "ci_account" {
  account_id = "${var.service_account}"
  project = "${var.project_id}"
}

resource "google_project_iam_policy" "account_role" {
  project     = "${var.project_id}"
  policy_data = "${data.google_iam_policy.account_role.policy_data}"
}

data "google_iam_policy" "account_role" {

  binding {
    role = "roles/container.developer"

    members = [
      "serviceAccount:${google_service_account.ci_account.email}",
    ]
  }

  binding {
    role = "roles/compute.viewer"

    members = [
      "serviceAccount:${google_service_account.ci_account.email}",
    ]
  }
}

resource "google_service_account_key" "ci_deploy_key" {
  service_account_id = "${google_service_account.ci_account.unique_id}"

  provisioner "local-exec" {
    working_dir = "../../../shift-scheduler-deployment"
    environment {
      KEY = "${base64decode(google_service_account_key.ci_deploy_key.private_key)}"
    }

    command = <<EOF
      echo $KEY >> ${var.service_account}-key.json
      travis login --org --auto
      travis encrypt-file ${var.service_account}-key.json --force --add
      rm ${var.service_account}-key.json
      git add ${var.service_account}-key.json.enc
      git commit -m "Changed deploy service account."
      git push
    EOF
  }

  provisioner "local-exec" {
    when = "destroy"
    working_dir = "../../../shift-scheduler-deployment"

    command = <<EOF
      rm ${var.service_account}-key.json.enc
      git add ${var.service_account}-key.json.enc
      git commit -m "Deleted deploy service account."
      git push
    EOF
  }
}
