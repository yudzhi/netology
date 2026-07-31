# Домашнее задание к занятию «Управляющие конструкции в коде Terraform»

## Задание 1. Запуск проекта
<details>
  <summary>Ход выполнения</summary>

### Шаг 1. Токен --> сервисный аккаунт

> Аутентификация по OAuth-токенам больше не поддерживается. С 1 июня 2026 года сервис аутентификации не принимает новые OAuth‑токены, полученные через Яндекс ID. https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token

#### Создан сервисный аккаунт с ролью `editor`:

```bash
yc iam service-account list
+----------------------+--------------+--------+---------------------+-----------------------+
|          ID          |     NAME     | LABELS |     CREATED AT      | LAST AUTHENTICATED AT |
+----------------------+--------------+--------+---------------------+-----------------------+
| ajebpt9aaf41hlevnr3g | terraform-sa |        | 2026-07-04 11:11:43 | 2026-07-23 21:50:00   |
+----------------------+--------------+--------+---------------------+-----------------------+

yc resource-manager folder list-access-bindings b1gd35ulrq15fj4fftut
+----------------------------------+----------------+----------------------+
|             ROLE ID              |  SUBJECT TYPE  |      SUBJECT ID      |
+----------------------------------+----------------+----------------------+
| iam.serviceAccounts.tokenCreator | serviceAccount | ajebpt9aaf41hlevnr3g |
| editor                           | serviceAccount | ajebpt9aaf41hlevnr3g |
+----------------------------------+----------------+----------------------+
```

#### Создан авторизованный ключ `.authorized_key.json`

`providers.tf`:
```hcl
provider "yandex" {
  # token     = var.token      # убираем
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
  service_account_key_file = file(pathexpand("~/.authorized_key.json"))
}
```

Убираем `var.token` из `variables.tf`.
</details>

<details>
  <summary>Скриншоты</summary>

![Security group](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/_TtUcV27_BoVLA)
</details>

## Задание 2. Создание ВМ

[Fork-репозиторий с кодом](https://github.com/yudzhi/ter-homeworks/tree/main/03/src)

```text
src/
├── variables.tf          # Общие переменные (cloud, network, security)
├── vm-variables.tf       # Все переменные для ВМ
├── count-vm.tf           # Веб-серверы, использует переменные из vm-variables.tf
└── for_each-vm.tf        # Базы данных, использует переменные из vm-variables.tf
```

<details>
  <summary>Ход выполнения</summary>

[yandex/compute_instance](https://library.tf/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance) :
> security_group_ids (Set Of String). Security Group (SG) IDs for network interface.

### Динамическое получение образа

Через data.yandex_compute_image с указанием семейства, чтобы не прописывать жёстко image_id актуального обновления. Всегда используется последняя версия из семейства.
Вынесена в общие параметры - все ВМ получают одинаковую базовую ОС

```text

###==============================================================================
### vms_platform.tf
###==============================================================================
 
    variable "vm_common_params" {
         type = object({
           image_family = string   # "ubuntu-2204-lts"
         })
         default = {
           image_family = "ubuntu-2204-lts"
         }
       }
###==============================================================================
### count-vm.tf / for_each-vm.tf
###==============================================================================
   │
   ├── data "yandex_compute_image" "ubuntu_web" {
   │     family = var.vm_common_params.image_family   # ← "ubuntu-2204-lts"
   │   }
   │
   └── resource "yandex_compute_instance" "web" {
         boot_disk {
           initialize_params {
             image_id = data.yandex_compute_image.ubuntu_web.image_id
           }
         }
       }

###==============================================================================
### YANDEX CLOUD API
###==============================================================================
│
├── 1. Запрос: "Найди образ по семейству ubuntu-2204-lts"
│
├── 2. Поиск в каталоге образов:
│   │
│   ├── ubuntu-2204-lts  →  fd80jm1j5h0ue6bh7j0b  (актуальный)
│
└── 3. Возврат: "Найден образ с ID = fd80jm1j5h0ue6bh7j0b"


###==============================================================================
### count-vm.tf / for_each-vm.tf 
###==============================================================================
├── data.yandex_compute_image.ubuntu_web.image_id = "fd80jm1j5h0ue6bh7j0b"
│
├── Использование в boot_disk:
│   │
│   └── image_id = "fd80jm1j5h0ue6bh7j0b"
│
└── Результат: Создаётся ВМ с Ubuntu 22.04 LTS
```
</details>

<details>
  <summary>Скриншоты</summary>

![Infrastructure map](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/KlVUbL24doo4VQ)

![Security group](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/1hC9lPrPHgAnjA)
</details>

## Задание 3. Дополнительные диски: создать и подключить

<details>
  <summary>Ход выполнения</summary>

### Шаг 1. Создание трёх виртуальных дисков
[resource yandex_compute_disk](https://library.tf/providers/yandex-cloud/yandex/latest/docs/resources/compute_disk)

### Шаг 2. Подключение дополнительных дисков к ВМ через `dynamic` + `for_each`
[vm-attach-disk](https://yandex.cloud/ru/docs/compute/operations/vm-control/vm-attach-disk)

> В конфигурационном файле в описании ресурса yandex_compute_instance добавьте новый блок secondary_disk:
```hcl
resource "yandex_compute_instance" "vm-1" {
  ...
  secondary_disk {
      disk_id = "<идентификатор_диска>"
  }
  ...
}
```

> Dynamic blocks используют для динамической генерации многократно повторяющихся, вложенных блоков
```hcl
dynamic "secondary_disk" {
  for_each = yandex_compute_disk.storage[*]
  content {
    disk_id = secondary_disk.value.id
  }
}
```

### Шаг 3. Проверка

```bash
# Проверка созданных дисков
yc compute disk list

# Проверка ВМ с подключёнными дисками
yc compute instance get storage

# Проверка через terraform output
terraform output storage_disks_info
terraform output storage_vm_ip
terraform output storage_disks_attached
```
</details>

<details>
  <summary>Скриншоты</summary>

![vm_storage_disks](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/lUBn83j7ygkeBA)
</details>

## Задание 4. Ansible Inventory
**UPD:** [Добавлено обновление inventory  по триггерам](https://github.com/yudzhi/ter-homeworks/commit/333783b367f11440da7d2701d14f82a496501f1e)

[terraform-03 branch commit](https://github.com/yudzhi/ter-homeworks/commit/e0e33b6e3146348edea6ecc3ff577d37d96386eb)

<details>
  <summary>Ход выполнения</summary>

### Шаг 1. Нужно получить inventory-файл:

```text
[webservers]
web-1 ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
web-2 ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>

[databases]
main ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
replica ansible_host<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>

[storage]
storage ansible_host=<внешний ip-адрес> fqdn=<полное доменное имя виртуальной машины>
```

### Шаг 2. Создать файл-шаблон `hosts.tftpl'

```hcl
[webservers]
%{~ for vm in webservers ~}
${vm.name} ansible_host=${vm.nat_ip} fqdn=${vm.fqdn}
%{~ endfor ~}

[databases]
%{~ for vm in databases ~}
${vm.name} ansible_host=${vm.nat_ip} fqdn=${vm.fqdn}
%{~ endfor ~}

[storage]
%{~ for vm in storage ~}
${vm.name} ansible_host=${vm.nat_ip} fqdn=${vm.fqdn}
%{~ endfor ~}

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_ed25519
host_key_checking=False
```

### Шаг 3. Сбор групп и генерация: `ansible.tf`

#### Переменные `locals`. Собираем все ВМ в группы для inventory
Целевые группы: webservers, databases, storage
Поля: name, nat_ip, fqdn

```hcl
locals {

  # Группа веб-серверов (из count-vm.tf)
  webservers = [
    for instance in yandex_compute_instance.web : {
      name   = instance.name
      nat_ip = instance.network_interface.0.nat_ip_address
      fqdn   = instance.fqdn
    }
  ]

  # Группа баз данных (из for_each-vm.tf)
  databases = [
    for instance in yandex_compute_instance.db : {
      name   = instance.name
      nat_ip = instance.network_interface.0.nat_ip_address
      fqdn   = instance.fqdn
    }
  ]

  # Группа storage (из disk_vm.tf)
  storage = [
    for instance in [yandex_compute_instance.storage] : {
      name   = instance.name
      nat_ip = instance.network_interface.0.nat_ip_address
      fqdn   = instance.fqdn
    }
  ]
}
```

#### Генерация inventory из шаблона - вынесено в `locals`:
```hcl
locals {
  # Генерация inventory из шаблона
  # Сохранено в переменную для реализации обновления
  inventory_content = templatefile("${path.module}/hosts.tftpl", {
    webservers = local.web_servers
    databases  = local.database_servers
    storage    = local.storage_servers
  })
}
```

#### Ресурс `local_file`. Создаем локальный файл `inventory.ini`

[resource local_file](https://library.tf/providers/hashicorp/local/latest/docs/resources/file)

`ansible.tf`:

```hcl
resource "local_file" "ansible_inventory" {
  content  = local.inventory_content
  filename = "${abspath(path.module)}/inventory.ini"
}

```
#### Функция `templatefile'.

[templatefile функция](https://developer.hashicorp.com/terraform/language/functions/templatefile)

- Читает файл-шаблон hosts.tftpl
- Подставляет в него переменные
- Возвращает готовый текст

#### Ресурс `terraform_data` и триггеры

[terraform_data resource](https://developer.hashicorp.com/terraform/language/resources/terraform-data)

*- Ресурс `local_file` создаёт файл только один раз, не обновляя при изменении ВМ*

*- `local_file` не поддерживает `triggers`*

>the terraform_data resource serves as a container for arbitrary operations taken by the provisioner "local-exec" block.

Аргумент `triggers_replace = { ... }` - это карта (map) значений, которые Terraform отслеживает. Если старые и новые значения различаются, ресурс пересоздаётся

```hcl
resource "terraform_data" "inventory_trigger" {
  # Триггеры для пересоздания при изменении ВМ
  triggers_replace = {
    web_instances     = join(",", [for vm in yandex_compute_instance.web : vm.id])
    db_instances      = join(",", [for vm in yandex_compute_instance.db : vm.id])
    storage_instance  = yandex_compute_instance.storage.id
    template_checksum = filemd5("${path.module}/hosts.tftpl")
    inventory_content = local.inventory_content
  }

  # Пересоздаём inventory-файл при срабатывании триггеров
  provisioner "local-exec" {
    command = <<-EOT
      cat > ${abspath(path.module)}/inventory.ini << 'INVENTORY'
${local.inventory_content}
INVENTORY
      echo "Inventory updated at $(date)" >> ${abspath(path.module)}/inventory-update.log
    EOT
  }
}
```

Отслеживаемые изменения: 
- перебираем все web-серверы, берём их ID. `join(",", [...])` — объединяем все ID в строку через запятую
- перебираем все ID баз данных
- ID storage
- MD5-хеш файла шаблона (изменился шаблон → изменился хеш)

#### Provisioner "local-exec" и обновление inventory




```bash
# Хеш последнего коммита
git log -1 --format=%H

# Полная ссылка на коммит
echo "https://github.com/$(git config --get remote.origin.url | sed 's/.*://' | sed 's/\.git$//')/commit/$(git rev-parse HEAD)"
```
</details>

<details>
  <summary>Скриншоты</summary>

![inventory file](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/8Y63zTfycXfKJw)
</details>

## Задание 5. Output

[terraform-03 коммит с заданием](https://github.com/yudzhi/ter-homeworks/commit/06e2efdb3f62a139ec91fca655a2abcee5bfead5)

<details>
  <summary>Скриншоты</summary>

![terraform output](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/uwzMaJoU2-vuHw)
</details>

## Задание 6. Ansible playbook + bastion

<details>
  <summary>Ход выполнения</summary>

[null_resource](https://library.tf/providers/hashicorp/null/latest)

> The primary use-case for the null resource is as a do-nothing container for arbitrary actions taken by a provisioner. In this example, three EC2 instances are created and then a null_resource instance is used to gather data about all three and execute a single action that affects them all. Due to the triggers map, the null_resource will be replaced each time the instance ids change, and thus the remote-exec provisioner will be re-run.
> 
> On Terraform 1.4 and later, use the terraform_data resource type instead. Terraform 1.9 and later support the moved configuration block from null_resource to terraform_data.
> 
> The triggers argument allows specifying an arbitrary set of values that, when changed, will cause the resource to be replaced.

</details>
