terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

locals {
  host_count = var.ha ? 2 : 1
  hosts = {
    for i in range(local.host_count) : "host-${i + 1}" => {
      zone      = var.zone
      subnet_id = var.subnet_id
    }
  }
}

resource "yandex_mdb_mysql_cluster" "this" {
  name        = var.cluster_name
  environment = var.environment
  network_id  = var.network_id
  version     = var.mysql_version

  resources {
    resource_preset_id = var.resource_preset_id
    disk_type_id       = var.disk_type_id
    disk_size          = var.disk_size
  }

  dynamic "host" {
    for_each = local.hosts
    content {
      zone      = host.value.zone
      subnet_id = host.value.subnet_id
      name      = host.key
    }
  }
}