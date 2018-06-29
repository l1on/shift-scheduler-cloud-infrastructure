variable "project_id" {}

provider "google" {}

resource "google_container_cluster" "primary" {
    name = "shift-scheduler"
    project = "${var.project_id}"
    initial_node_count = 3
    zone = "us-central1-a"

    node_config {
        disk_size_gb = 10
        machine_type = "f1-micro"

        oauth_scopes = [
            "https://www.googleapis.com/auth/compute",
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ]

    }
}


