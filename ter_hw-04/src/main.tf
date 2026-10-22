### Задание 2. Создаём сеть и подсеть через модуль 
module "vpc_dev" {
  source   = "./vpc"
  # providers = {
  #   yandex = yandex
  # }
  env_name = "develop"
  zone     = var.default_zone
  cidr     = var.default_cidr[0]
}

# resource "yandex_vpc_network" "develop" {
#   name = var.vpc_name
# }
# resource "yandex_vpc_subnet" "develop" {
#   name           = var.vpc_name
#   zone           = var.default_zone
#   network_id     = yandex_vpc_network.develop.id
#   v4_cidr_blocks = var.default_cidr
# }

locals {
  cloudinit = templatefile("${path.module}/cloud-init.yml", {
    ssh_public_key = var.vms_ssh_root_key
  })
}

module "marketing_vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=v2.0.0"
  # providers = {
  #   yandex = yandex
  # }
  env_name       = "develop"
  # network_id     = yandex_vpc_network.develop.id
  # subnet_zones   = [var.default_zone]
  # subnet_ids     = [yandex_vpc_subnet.develop.id]
  network_id     = module.vpc_dev.vpc.network_id
  subnet_zones   = [module.vpc_dev.vpc.subnet_zone]
  subnet_ids     = [module.vpc_dev.vpc.subnet_id]
  instance_name  = "marketing-vm"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true
  platform = "standard-v2" #ради зоны ru-central1-d
  # boot_disk_size = 10

  labels = var.marketing_labels

  metadata = {
    user-data          = local.cloudinit
    serial-port-enable = 1
  }
}

module "analytics_vm" {
  source         = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=v2.0.0"
  # providers = {
  #   yandex = yandex
  # }
  env_name       = "develop"
  # network_id     = yandex_vpc_network.develop.id
  # subnet_zones   = [var.default_zone]
  # subnet_ids     = [yandex_vpc_subnet.develop.id]
  network_id     = module.vpc_dev.vpc.network_id
  subnet_zones   = [module.vpc_dev.vpc.subnet_zone]
  subnet_ids     = [module.vpc_dev.vpc.subnet_id]
  instance_name  = "analytics-vm"
  instance_count = 1
  image_family   = "ubuntu-2004-lts"
  public_ip      = true
  platform = "standard-v2" #ради зоны ru-central1-d
  # boot_disk_size = 10

  labels = var.analytics_labels

  metadata = {
    user-data          = local.cloudinit
    serial-port-enable = 1
  }
}