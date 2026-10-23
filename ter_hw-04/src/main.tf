### Task 4. Создаём подсети во всех зонах доступности, 
### переданных в переменной типа list(object) при вызове модуля
module "vpc_prod" {
  source       = "./vpc"
  env_name     = "production"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", cidr = "10.0.2.0/24" },
    { zone = "ru-central1-d", cidr = "10.0.3.0/24" },
  ]
}

module "vpc_dev" {
  source       = "./vpc"
  env_name     = "develop"
  subnets = [
    { zone = "ru-central1-d", cidr = "10.0.1.0/24" },
  ]
}

### Задание 2. Создаём сеть и подсеть через модуль 
# module "vpc_dev" {
#   source   = "./vpc"
#   # providers = {
#   #   yandex = yandex
#   # }
#   env_name = "develop"
#   zone     = var.default_zone
#   cidr     = var.default_cidr[0]
# }

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
  subnet_zones = module.vpc_dev.vpc.subnet_zones
  subnet_ids = module.vpc_dev.vpc.subnet_ids
  # subnet_zones   = [module.vpc_dev.vpc.subnet_zone] Задание 2
  # subnet_ids     = [module.vpc_dev.vpc.subnet_id] Задание 2
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
  subnet_zones = module.vpc_dev.vpc.subnet_zones
  subnet_ids = module.vpc_dev.vpc.subnet_ids
  # subnet_zones   = [module.vpc_dev.vpc.subnet_zone] Задание 2
  # subnet_ids     = [module.vpc_dev.vpc.subnet_id] Задание 2  instance_name  = "analytics-vm"
  instance_name = "analytics-vm"
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