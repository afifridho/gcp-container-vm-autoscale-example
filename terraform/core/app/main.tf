module "default" {
  source = "../../modules/container-ilb-autoscale/"

  # network
  subnetwork            = "projects/afif-ridho-personal-project/regions/asia-southeast1/subnetworks/afif-subnetwork"
  region                = "asia-southeast1"
  zones                 = ["asia-southeast1-a", "asia-southeast1-b", "asia-southeast1-c"]

  # instance detail
  project_name          = "wordpress"
  source_image          = module.gce-container.source_image
  machine_type          = "g1-small"
  target_size           = 2
  disk_size             = 50
  disk_type             = "pd-standard"
  can_ip_forward        = false

  # healthcheck
  request_path          = "/"
  healthcheck_port      = "80"
  check_interval_sec    = 10
  timeout_sec           = 5
  healthy_threshold     = 2
  unhealthy_threshold   = 3

  # label and tag
  environment           = "production"
  service_type          = "backend"
  containervm_label     = module.gce-container.vm_container_label

  # autoscale
  min_replicas          = 2
  max_replicas          = 4
  cpu_utilization       = 0.50
  cooldown_period       = 100

  # autohealing
  initial_delay_sec     = 60

  # update policy
  update_type           = "PROACTIVE"
  minimal_action        = "REPLACE"
  max_surge_fixed       = 3
  max_unavailable_fixed = 0
  min_ready_sec         = 60

  # backend service
  resp_timeout_sec      = 10
  draining_timeout_sec  = 30

  # metadata
  container_metadata    = module.gce-container.metadata_value
}