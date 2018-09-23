variable "project_id" {
  type = "string"
}
variable "service_account" {
  type = "string"
}

terraform {
  backend "gcs" {
    bucket  = "shift-scheduler-3805-terraform-state"
  }
}

provider "google" {
  version = "1.13"
}

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
