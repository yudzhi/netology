terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  # Параметры cloud_id, folder_id и token не указываются, так как
  # провайдер автоматически подхватит их из переменных окружения

  zone = "ru-central1-a"
}


# Сеть
#resource "yandex_vpc_network" "swarm-net" {
#  name = "swarm-network-tf"
#}

# Подсеть
resource "yandex_vpc_subnet" "swarm-subnet-a" {
  name           = "swarm-subnet-a-tf"
  zone           = "ru-central1-a"
  network_id     = "enprb83klnpar77ku705"
  v4_cidr_blocks = ["10.20.0.0/24"]
}

# Переменная для SSH-ключа. Можно использовать default или передать через файл .tfvars
variable "ssh_public_key" {
  default = "<содержимое_вашего_публичного_ключа_ssh>" # Очень небезопасно! Используйте файлы .tfvars
}

# Описание ВМ менеджера
resource "yandex_compute_instance" "swarm-manager" {
  name        = "swarm-manager-tf"
  platform_id = "standard-v3" # Intel Ice Lake
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20 # Экономия до 65%
  }

  boot_disk {
    initialize_params {
      image_id = "fd806c8slu9j1pa87msc" # ID образа Ubuntu 22.04 LTS в Yandex Cloud
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.swarm-subnet-a.id
    nat       = true # Публичный IP
  }

  metadata = {
    ssh-keys = "yc-user:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true # Экономия до 70%
  }
}

# Ресурс для рабочих нод. Можно использовать count для создания двух копий.
resource "yandex_compute_instance" "swarm-worker" {
  count       = 2
  name        = "swarm-worker-${count.index + 1}-tf"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd806c8slu9j1pa87msc"
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.swarm-subnet-a.id
    nat       = true
  }

  metadata = {
    ssh-keys = "yc-user:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }
}

output "manager_ip" {
  value = yandex_compute_instance.swarm-manager.network_interface.0.nat_ip_address
}

output "workers_ips" {
  value = yandex_compute_instance.swarm-worker[*].network_interface.0.nat_ip_address
}