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

```text
src/
├── variables.tf          # Общие переменные (cloud, network, security)
├── vm-variables.tf       # Все переменные для ВМ
├── count-vm.tf           # Веб-серверы, использует переменные из vm-variables.tf
└── for_each-vm.tf        # Базы данных, использует переменные из vm-variables.tf
```

[yandex/compute_instance](https://library.tf/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance) :
> security_group_ids (Set Of String). Security Group (SG) IDs for network interface.

<details>
  <summary>Скриншоты</summary>

![Infrastructure map](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/KlVUbL24doo4VQ)

![Security group](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/1hC9lPrPHgAnjA)
</details>
