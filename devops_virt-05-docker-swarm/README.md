# Домашнее задание к занятию 6. «Оркестрация кластером Docker контейнеров на примере Docker Swarm»
## 1. Создание Docker Swarm-кластера в Яндекс Облаке.

### 1.1 Создание 3 облачных виртуальных машин в одной сети через Terraform

```bash
terraform version
Terraform v1.15.7
on linux_amd64
+ provider registry.terraform.io/yandex-cloud/yandex v0.213.0
```
<details>
  <summary>Ход выполнения</summary>

**Установка Terraform**
```bash
unzip terraform_1.15.7_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```
**Настройка Terraform**

[Начало работы - справка Yandex Cloud](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart)


Файл `main.tf`

```hcl
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
```
  
</details>

### 1.2 Установка docker на каждую ВМ.

### 1.3 Создание swarm-кластера из 1 мастера и 2-х рабочих нод.

### 1.4 Проверка списка нод командой:

```bash
docker node ls
```
