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
</details>
