# ---------------------------------------------------------------------------------------------------------------------
# LAUNCH A LOAD BALANCER WITH INSTANCE GROUP AND STORAGE BUCKET BACKEND
#
# This is an example of how to use the http-load-balancer module to deploy a HTTP load balancer
# with multiple backends and optionally ssl and custom domain.
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # The modules used in this example have been updated with 0.12 syntax, which means the example is no longer
  # compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

# ------------------------------------------------------------------------------
# CONFIGURE OUR GCP CONNECTION
# ------------------------------------------------------------------------------

provider "google" {
  version = "~> 2.7.0"
  region  = var.region
  project = var.project
}

provider "google-beta" {
  version = "~> 2.7.0"
  region  = var.region
  project = var.project
}

# ------------------------------------------------------------------------------
# CREATE THE LOAD BALANCER
# ------------------------------------------------------------------------------

module "lb" {
  source                = "../../modules/http-load-balancer"
  name                  = "wordpress"
  project               = "afif-ridho-personal-project"
  url_map               = google_compute_url_map.urlmap.self_link
  dns_managed_zone_name = var.dns_managed_zone_name
  custom_domain_names   = [var.custom_domain_name]
  create_dns_entries    = var.create_dns_entry
  dns_record_ttl        = var.dns_record_ttl
  enable_http           = "true"
  enable_ssl            = "true"
  ssl_certificates      = google_compute_ssl_certificate.certificate.*.self_link

  custom_labels = var.custom_labels
}

# ------------------------------------------------------------------------------
# CREATE THE URL MAP TO MAP PATHS TO BACKENDS
# ------------------------------------------------------------------------------

resource "google_compute_url_map" "urlmap" {
  project = var.project

  name        = "${var.name}-url-map"
  description = "URL map for ${var.name}"

  default_service = "https://www.googleapis.com/compute/v1/projects/afif-ridho-personal-project/global/backendServices/wordpress-backend-service"

  host_rule {
    hosts        = ["*"]
    path_matcher = "all"
  }

  path_matcher {
    name            = "all"
    default_service = "https://www.googleapis.com/compute/v1/projects/afif-ridho-personal-project/global/backendServices/wordpress-backend-service"

    path_rule {
      paths   = ["/"]
      service = "https://www.googleapis.com/compute/v1/projects/afif-ridho-personal-project/global/backendServices/wordpress-backend-service"
    }
  }
}

# ------------------------------------------------------------------------------
# IF SSL IS ENABLED, CREATE A SELF-SIGNED CERTIFICATE
# ------------------------------------------------------------------------------

resource "tls_self_signed_cert" "cert" {
  # Only create if SSL is enabled
  count = var.enable_ssl ? 1 : 0

  key_algorithm   = "RSA"
  private_key_pem = join("", tls_private_key.private_key.*.private_key_pem)

  subject {
    common_name  = var.custom_domain_name
    organization = "Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_private_key" "private_key" {
  count       = var.enable_ssl ? 1 : 0
  algorithm   = "RSA"
  ecdsa_curve = "P256"
}

# ------------------------------------------------------------------------------
# CREATE A CORRESPONDING GOOGLE CERTIFICATE THAT WE CAN ATTACH TO THE LOAD BALANCER
# ------------------------------------------------------------------------------

resource "google_compute_ssl_certificate" "certificate" {
  project = var.project

  count = var.enable_ssl ? 1 : 0

  name_prefix = var.name
  description = "SSL Certificate"
  private_key = join("", tls_private_key.private_key.*.private_key_pem)
  certificate = join("", tls_self_signed_cert.cert.*.cert_pem)

  lifecycle {
    create_before_destroy = true
  }
}