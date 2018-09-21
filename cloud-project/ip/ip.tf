variable "project_id" {
  type = "string"
}

variable "ip_region" {
  type = "string"
}

terraform {
  backend "gcs" {
    bucket  = "shift-scheduler-1966-terraform-state"
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
