variable "project" {
  default = "afif-ridho-personal-project"
}

resource "google_compute_network" "network" {
  name                    = "afif-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "afif-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "asia-southeast1"
  network       = google_compute_network.network.self_link
}

resource "google_compute_firewall" "firewall" {
  project = "afif-ridho-personal-project"
  name    = "afif-firewall"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_ranges = ["0.0.0.0"]
}