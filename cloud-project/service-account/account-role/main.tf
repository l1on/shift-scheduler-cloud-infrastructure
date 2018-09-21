variable "role" {
  type = "string"
}

variable "id" {
  type = "string"
}

variable "email" {
  type = "string"
}

terraform {
  backend "gcs" {
    bucket  = "shift-scheduler-18090-terraform-state"
  }
}

provider "google" {}

resource "google_service_account_iam_binding" "account_role" {
  service_account_id = "${var.id}"
  role = "${var.role}"

  members = [
    "serviceAccount:${var.email}",
  ]
}
