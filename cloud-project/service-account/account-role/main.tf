variable "role" {
  type = "string"
}

variable "email" {
  type = "string"
}

variable "project" {
  type = "string"
}


terraform {
  backend "gcs" {
    bucket  = "shift-scheduler-3805-terraform-state"
  }
}

provider "google" {}

resource "google_service_account_iam_binding" "account_role" {
  service_account_id = "projects/${var.project}/serviceAccounts/${var.email}"
  role = "${var.role}"

  members = [
    "serviceAccount:${var.email}",
  ]
}
