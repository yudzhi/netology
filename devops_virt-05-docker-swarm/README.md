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

Для Terraform в Yandex Cloud используется переменная YC_SERVICE_ACCOUNT_KEY_FILE. Она может содержать либо путь к JSON-файлу с ключом сервисного аккаунта, либо содержимое этого файла.

Использование сервисного аккаунта с помощью имперсонации является рекомендованным и наиболее безопасным способом аутентификации.

При создании IAM-токена используйте имперсонацию для созданного сервисного аккаунта, указав его идентификатор в параметре --impersonate-service-account-id. В результате Terraform будет от имени сервисного аккаунта управлять ресурсами в каталоге и использовать IAM-токен сервисного аккаунта.

У вас уже есть статический ключ доступа (access_key и secret_key) от сервисного аккаунта, который вы создали ранее. Теперь нужно создать файл с авторизованным ключом.

```bash
yc iam key create \
  --service-account-name terraform-sa \
  --output key.json

id: ajekk84kglhjf5jaet2o
service_account_id: ajebpt9aaf41hlevnr3g
created_at: "2026-07-04T19:53:24.452674526Z"
key_algorithm: RSA_2048
```
Или можно создать самостоятельно `key.json` со статическим ключом:

```bash
{
  "id": "идентификатор_ключа",
  "service_account_id": "идентификатор_сервисного_аккаунта",
  "created_at": "2024-01-01T00:00:00Z",
  "key_algorithm": "RSA_2048",
  "public_key": "публичный_ключ",
  "private_key": "секретный_ключ_в_формате_PEM"
}
```

Теперь нужно указать Terraform, где находится этот файл. 
Переменные, созданные через export, действуют только в текущей сессии терминала. Чтобы они сохранялись, добавьте их в файл `~/.bashrc`:

```bash
nano ~/.bashrc
```
Добавьте в конец файла строки:
```bash
export YC_SERVICE_ACCOUNT_KEY_FILE="~/key.json"
export YC_CLOUD_ID="ваш_cloud_id"
export YC_FOLDER_ID="ваш_folder_id"
```

Сохраните файл и выполните:

```bash
source ~/.bashrc
```

**Провайдер**

Откройте файл конфигурации Terraform CLI:

```bash
nano ~/.terraformrc
```

Файл `.terraformrc` должен располагаться в корне домашней папки пользователя, например, `/home/user/`.

Добавьте в него следующий блок:

```bash
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

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
