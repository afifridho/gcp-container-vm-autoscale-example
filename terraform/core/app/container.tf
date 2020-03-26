variable "image_version" {
  default = "latest"
}

module "gce-container" {
  source = "github.com/terraform-google-modules/terraform-google-container-vm"

  container = {
     image = "hub.docker.com/_/wordpress:latest"

    volumeMounts = [
      {
        mountPath = "/cache"
        name      = "tempfs-0"
        readOnly  = false
      },
      {
        mountPath = "/data"
        name      = "host-path-0"
        readOnly  = false
      }
    ]
  }

  volumes = [
    {
      name = "tempfs-0"

      emptyDir = {
        medium = "Memory"
      }
    },
    {
      name = "host-path-0"
      hostPath = {
        path = "/mnt/stateful_partition"
      }
    },
  ]

  restart_policy = "Always"
}