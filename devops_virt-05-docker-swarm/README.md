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


#### Установка Terraform
```bash
unzip terraform_1.15.7_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```
#### Настройка Terraform

[Начало работы - справка Yandex Cloud](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart)

#### Аутентификация в YC

Для Terraform в Yandex Cloud используется переменная YC_SERVICE_ACCOUNT_KEY_FILE. Она может содержать либо путь к JSON-файлу с ключом сервисного аккаунта, либо содержимое этого файла.

#### Создать сервисный аккаунт

Использование сервисного аккаунта с помощью имперсонации является рекомендованным и наиболее безопасным способом аутентификации.

При создании IAM-токена рекомендуется использовать имперсонацию для созданного сервисного аккаунта, указав его идентификатор в параметре `--impersonate-service-account-id`. В результате Terraform будет от имени сервисного аккаунта управлять ресурсами в каталоге и использовать IAM-токен сервисного аккаунта.

! При каждой операции аутентификация будет происходить с помощью этого IAM-токена, пока не истечет время его жизни (не более 12 часов). После этого снова потребуется пройти аутентификацию. 

Список сервисных аккаунтов в каталоге по умолчанию:
```bash
yc iam service-account list
```

Создан статический ключ доступа (access_key и secret_key) от сервисного аккаунта. Но вроде Terraform не относится к поддерживаемым сервисам. Для него нужен "авторизованный ключ", который будет обмениваться на IAM-token. Нужно создать файл с авторизованным ключом. 

```bash
yc iam key create \
  --service-account-name terraform-sa \
  --output key.json

id: ajekk84kglhjf5jaet2o
service_account_id: ajebpt9aaf41hlevnr3g
created_at: "2026-07-04T19:53:24.452674526Z"
key_algorithm: RSA_2048
```
Или можно создать самостоятельно `key.json` со статическим ключом, НЕ ТЕСТИРОВАЛОСЬ:

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

#### Настройка переменных окружения

Рекомендации YC - Запишите аутентификационные данные в переменные окружения, используя имперсонацию:

```bash
export YC_TOKEN=$(yc iam create-token --impersonate-service-account-id <идентификатор_сервисного_аккаунта>)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

Переменные, созданные через export, действуют только в текущей сессии терминала. Чтобы они сохранялись, надо добавить их в файл `~/.bashrc`:
Нужно указать Terraform, где находится файл `key.json`. 

```bash
nano ~/.bashrc
```
Добавлены в конец файла строки:
```bash
export YC_SERVICE_ACCOUNT_KEY_FILE="~/key.json"
export YC_CLOUD_ID="b1gve0m7402c1phkc44c"
export YC_FOLDER_ID="b1gd35ulrq15fj4fftut"
```

Сохранить файл и выполнить:

```bash
source ~/.bashrc
```

#### Настройка провайдера

Файл конфигурации Terraform CLI - нужно указать источник, из которого будет устанавливаться провайдер:

```bash
nano ~/.terraformrc
```

Файл `.terraformrc` должен располагаться в корне домашней папки пользователя, например, `/home/user/`.

Добавить в него блок:

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
#### Файл объявления переменных `variables.tf`

В корневой папке Terraform-проекта.

```bash
# variables.tf
# Объявление всех переменных, используемых в конфигурации

variable "ssh_public_key" {
  description = "Публичный SSH-ключ пользователя для доступа к ВМ"
  type        = string
}

variable "cloud_id" {
  description = "Идентификатор облака в Yandex Cloud"
  type        = string
}

variable "folder_id" {
  description = "Идентификатор каталога в Yandex Cloud"
  type        = string
}

variable "zone" {
  description = "Зона доступности для размещения ресурсов"
  type        = string
  default     = "ru-central1-a"
}

variable "image_id" {
  description = "ID образа операционной системы для ВМ"
  type        = string
}

variable "vpc_network_id" {
  description = "ID существующей сети VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR-блок для подсети"
  type        = string
  default     = "10.20.0.0/24"
}

variable "vm_name_prefix" {
  description = "Префикс для имен виртуальных машин"
  type        = string
  default     = "swarm"
}

variable "worker_count" {
  description = "Количество рабочих нод"
  type        = number
  default     = 2
}
```

#### Файл конфигурации `main.tf`

Создана директория `cloud-terraform`. В ней будут храниться конфигурационные файлы и сохраненные состояния Terraform и инфраструктуры и `key.json` (**TODO включить `key.json` в `.gitignore**).

Конфигурационный файл `main.tf`

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

#### Инфраструктурный план, или на что обратить внимание!

- Актуальность ID образа
Список доступных публичных образов:

```bash
yc compute image list --folder-id standard-images
```

- Выбор сети - YC разрешает созданее не более двух:
Список сетей:

```bash
yc vpc network list
+----------------------+---------+
|          ID          |  NAME   |
+----------------------+---------+
| enpk17sut5bjiq73p826 | default |
| enprb83klnpar77ku705 | net     |
+----------------------+---------+

yc vpc network get default
id: enpk17sut5bjiq73p826
folder_id: b1gd35ulrq15fj4fftut
created_at: "2026-05-08T19:53:58Z"
name: default
description: Auto-created network
default_security_group_id: enp310qsrocrlt0u4p2j
```

- SSH-подключение - указать правильное имя пользователя для каждой ВМ

```bash
metadata = {
    ssh-keys = "yudzhi:${var.ssh_public_key}"
```

- SSH-подключение - передать terraform публичный ключ

Для Yandex Cloud рекомендуется создавать ключи Ed25519 (т. е. на основе криптографического алгоритма Ed25519)

```bash
cat ~/.ssh/id_ed25519.pub
```

Файл `terraform.tfvars`:
```hcl
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
```

#### Создание ресурсов

Выполните команду в папке с конфигурационным файлом .tf. Эта команда инициализирует провайдеров, указанных в конфигурационных файлах, и позволяет работать с ресурсами и источниками данных провайдера. 

```bash
terraform init

Initializing provider plugins found in the configuration...
- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.213.0...
- Installed yandex-cloud/yandex v0.213.0 (unauthenticated)
Terraform has been successfully initialized!
```

Проверка конфигурации:

```bash
terraform validate

Success! The configuration is valid.
```

Форматирование файлов конфигураций в текущем каталоге и подкаталогах (**TODO Осознать, что происходит**:

```bash
terraform fmt
```

После проверки конфигурации:

```bash
terraform plan
```
В терминале будет выведен список ресурсов с параметрами. Это проверочный этап: ресурсы не будут созданы. Если в конфигурации есть ошибки, Terraform на них укажет.

Создание ресурсов:

```bash
terraform apply

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

manager_ip = "62.84.127.52"
workers_ips = [
  "62.84.124.140",
  "111.88.251.252",
]
```

**Пересоздание ВМ**

В Яндекс Облаке есть особенность: если вы укажете неправильный публичный ключ при создании ВМ, вы не сможете подключиться. Единственный способ исправить это — пересоздать ВМ или использовать серийную консоль в веб-интерфейсе.

Если что-то пошло не так:
```bash
terraform destroy
```

</details>

### 1.2 Установка docker на каждую ВМ.

<details>
  <summary>Ход выполнения</summary>

#### Подключение к ВМ

ssh -i ~/.ssh/id_ed25519 yc-user@<IP VM>

#### Установка Docker на каждой ВМ

```bash
# Обновление списка пакетов
sudo apt update

# Установка вспомогательных пакетов
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Добавление официального ключа и репозитория Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Установка Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Добавление пользователя в группу docker (чтобы не использовать sudo)
sudo usermod -aG docker $USER
```

</details>

### 1.3 Создание swarm-кластера из 1 мастера и 2-х рабочих нод.

### 1.4 Проверка списка нод командой:

```bash
docker node ls
```
