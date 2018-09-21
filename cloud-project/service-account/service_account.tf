variable "project_id" {
  type = "string"
}
variable "service_account" {
  type = "string"
}

terraform {
  backend "gcs" {
    bucket  = "shift-scheduler-00000-terraform-state"
  }
}

provider "google" {}

resource "google_service_account" "ci_account" {
  account_id = "${var.service_account}"
  project = "${var.project_id}"
}

module "ci_account_k8s_deployer" {
  source = "./account-role"

  role = "roles/container.developer"
  email = "${google_service_account.ci_account.email}"
  project = "${var.project_id}"
}

module "ci_account_ip_viewer" {
  source = "./account-role"

  role = "roles/compute.viewer"
  email = "${google_service_account.ci_account.email}"
  project = "${var.project_id}"
}

resource "google_service_account_key" "ci_deploy_key" {
  service_account_id = "${google_service_account.ci_account.unique_id}"
  project = "${var.project_id}"
  provisioner "local-exec" {
    working_dir = "../../../shift-scheduler-deployment"
    environment {
      KEY = "${base64decode(google_service_account_key.ci_deploy_key.private_key)}"
    }

    command = <<EOF
      echo $KEY >> ${var.service_account}-key.json
      travis login --org
      travis encrypt-file ${var.service_account}-key.json --add
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
