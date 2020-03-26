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
# CREATE THE BACKEND SERVICE CONFIGURATION FOR THE INSTANCE GROUP
# ------------------------------------------------------------------------------

resource "google_compute_backend_service" "default" {
  provider = "google-beta"

  name = "${var.project_name}-backend-service"
#  load_balancing_scheme = "INTERNAL_SELF_MANAGED"
#  locality_lb_policy = "ROUND_ROBIN"
  protocol = "HTTPS"
  port_name = "https"
  timeout_sec = 10

  backend {
    group = google_compute_region_instance_group_manager.instance_group_manager.instance_group
  }

  health_checks = [google_compute_health_check.health-check.self_link]

  depends_on = [google_compute_region_instance_group_manager.instance_group_manager]
}

# ------------------------------------------------------------------------------
# CONFIGURE HEALTH CHECK FOR THE API BACKEND
# ------------------------------------------------------------------------------

resource "google_compute_health_check" "health-check" {
  name                = "${var.project_name}-hc"
  check_interval_sec  = "${var.check_interval_sec}"
  timeout_sec         = "${var.timeout_sec}"
  healthy_threshold   = "${var.healthy_threshold}"
  unhealthy_threshold = "${var.unhealthy_threshold}"

  http_health_check {
    request_path = "${var.request_path}"
    port         = "${var.healthcheck_port}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# CREATE THE INSTANCE GROUP WITH A SINGLE INSTANCE AND THE BACKEND SERVICE CONFIGURATION
#
# We use the instance group only to highlight the ability to specify multiple types
# of backends for the load balancer
# ------------------------------------------------------------------------------

resource "google_compute_instance_template" "instance-template" {
  project = var.project
  name_prefix         = "${var.project_name}-tpl-"

  labels = {
    environment        = "${var.environment}"
    service_name       = "${var.project_name}"
    service_type       = "${var.service_type}"
    created_by         = "terraform"
    container-vm       = "${var.containervm_label}"
  }

  metadata = {
    gce-container-declaration = "${var.container_metadata}"
    google-logging-enabled    = "${var.logging_enabled}"
  }

  tags = ["${var.environment}", "${var.project_name}", "${var.service_type}", "terraform"]

  machine_type         = "${var.machine_type}"
  can_ip_forward       = "${var.can_ip_forward}"

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "projects/${var.project}/global/images/${var.source_image}"
    auto_delete  = true
    boot         = true
    disk_type    = "${var.disk_type}"
    disk_size_gb = "${var.disk_size}"
  }

  network_interface {
    subnetwork         = var.subnetwork
  }

  lifecycle {
    create_before_destroy = true
  }

  service_account {
      scopes = ["cloud-platform"]
  }

}

resource "google_compute_region_instance_group_manager" "instance_group_manager" {
  provider           = "google-beta"
  project            = var.project
  name               = "${var.project_name}-group"
  #target_size        = "${var.target_size}"
  region	     = var.region

  version {
    name              = "${var.project_name}"
    instance_template = "${google_compute_instance_template.instance-template.self_link}"
  }

  named_port {
    name = "https"
    port = 443
  }

  base_instance_name        = "app-${var.project_name}"
  distribution_policy_zones = "${var.zones}"

  auto_healing_policies {
    health_check      = "${google_compute_health_check.health-check.self_link}"
    initial_delay_sec = "${var.initial_delay_sec}"
  }

  update_policy  {
    type                  = "${var.update_type}"
    minimal_action        = "${var.minimal_action}"
    max_surge_fixed       = "${var.max_surge_fixed}"
    max_unavailable_fixed = "${var.max_unavailable_fixed}"
    min_ready_sec         = "${var.min_ready_sec}"
  }
}

resource "google_compute_region_autoscaler" "region-autoscaler" {
  name   = "${var.project_name}-autoscaler"
  region = var.region
  target = "${google_compute_region_instance_group_manager.instance_group_manager.self_link}"

  autoscaling_policy {
    max_replicas    = "${var.max_replicas}"
    min_replicas    = "${var.min_replicas}"
    cooldown_period = "${var.cooldown_period}"

    cpu_utilization {
      target = "${var.cpu_utilization}"
    }
  }
}