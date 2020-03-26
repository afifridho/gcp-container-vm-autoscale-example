variable "project" {
  default = "afif-ridho-personal-project"
}

variable "target_size" {
  default = 1
}

variable "machine_type" {
  default = ""
}

variable "subnetwork" {
  default = ""
}

variable "region" {
  default = ""
}

variable "zones" {
  default = ["asia-southeast1-a", "asia-southeast1-b", "asia-southeast1-c"]
}

variable "tags" {
  default = []
}

variable "source_image" {
  default = ""
}

variable "project_name" {
  default = ""
}

variable "healthcheck_port" {
  default = 55155
}

variable "request_path" {
  default = "/"
}

variable "environment" {
  default = ""
}

variable "min_replicas" {
  default = 1
}

variable "max_replicas" {
  default = 1
}

variable "cpu_utilization" {
  default = 0.5
}

variable "initial_delay_sec" {
  default = 120
}

variable "service_group" {
  default = ""
}

variable "service_name" {
  default = ""
}

variable "service_type" {
  default = ""
}

variable "cooldown_period" {
  default = 60
}

variable "check_interval_sec" {
  default = 5
}

variable "timeout_sec" {
  default = 5
}

variable "healthy_threshold" {
  default = 2
}

variable "unhealthy_threshold" {
  default = 3
}

variable "update_type" {
  default = "PROACTIVE"
}

variable "minimal_action" {
  default = "REPLACE"
}

variable "max_surge_fixed" {
  default = 3
}

variable "max_unavailable_fixed" {
  default = 0
}

variable "min_ready_sec" {
  default = 60
}

variable "resp_timeout_sec" {
  default = "30"
}

variable "draining_timeout_sec" {
  default = "30"
}

variable "can_ip_forward" {
  default = false
}

variable "disk_size" {
  default = 50
}

variable "target_size_percent" {
  default = 100
  type = "string"
}

variable "disk_type" {
  default = "pd-standard"
}

variable "session_affinity" {
  default = "NONE"
}

variable "containervm_label"{
    default = ""
}

variable "container_metadata"{
    default = ""
}

variable "startup_script"{
    default = ""
}

variable "logging_enabled"{
    default = "true"
}