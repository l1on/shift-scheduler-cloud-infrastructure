terraform {
  backend "gcs" {
    bucket  = "shift-scheduler-terraform-state"
  }
}

provider "google" {}

resource "google_compute_address" "ip" {
  name = "load-balancer-ip"
  project = "${var.project_id}"

  provisioner "local-exec" {
    working_dir = "../../../shift-scheduler-app"

    command = <<EOF
      sed 's/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/${google_compute_address.ip.address}/' public/_redirects | tee public/_redirects
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