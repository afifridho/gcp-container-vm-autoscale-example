# GCP Terraform Container Optimized OS VM autoscale example

## Intro
this repo contain terraform scipts to create container optimized os managed VM with autoscale feature

there are 2 main folders in this repo
1. core: contain the main terraform scripts that needed for creating infrasructures in google cloud platform
2. modules: contain the modules that used for terraform scripts in core folder
## How To

### Prepare the App and its Infrastructure
```
export GOOGLE_CREDENTIALS="/your/path/to/credentials.json"
```

create the vpc and some networking stuffs
```
$ cd ./core/network
$ terraform apply
```

create the global load balancer and all its dependencies
```
$ cd ./core/https-load-balancer
$ terraform apply
```

create the managed vm for the main app
```
$ cd ./core/app
$ terraform apply
```

### How to adjust the autoscale

open `./core/app/main.tf` with your fav editor
```
$ vim ./core/app/main.tf
```

edit the autoscale section, adjust it as you like
```
  # autoscale
  min_replicas          = 2
  max_replicas          = 4
  cpu_utilization       = 0.50
  cooldown_period       = 100
```

