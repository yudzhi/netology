# Домашнее задание к занятию «Продвинутые методы работы с Terraform»

## Задание 1. Один remote-модуль = две ВМ
<details>
  <summary>Ход выполнения</summary>

  ### Нюанс 1. `template_file` vs `templatefile`

Цитата из задания:
>  Передайте ssh-ключ в функцию template_file в блоке vars ={} . Воспользуйтесь [примером](https://oneuptime.com/blog/post/2026-03-02-how-to-use-cloud-init-with-terraform-for-ubuntu-provisioning/view)

В задании указана функция template_file, однако это устаревший data source из deprecated-провайдера Template. Начиная с Terraform 0.12 рекомендуется использовать встроенную функцию templatefile(), которая поддерживает сложные типы данных и полноценные директивы шаблонизации. Cохраняя логику задания: результат сохранён в locals и передан в metadata.user-data, что соответствует логике задания: ssh-ключ приходит из переменной и подставляется в список ssh_authorized_keys в cloud-init.yml.

Вопрос к формулировке: в одном предложении и слово "функция", и "блок vars". Можно использовать data source template_file  с блоком vars. Но современный вариант - функция templatefile(), тогда vars = {} заменяется на второй аргумент функции — объект с переменными. Непонятно, поэтому беру templatefile(), который используется в примере по ссылке.

### Нюанс 2. Токен

В шаблоне требуется, но с лета 2026 вроде уже не работает. См. [HW_ter_3 Задание 1](https://github.com/yudzhi/netology/blob/main/ter_hw-03/README.md)

### Два вызова remote-модуля.

- Использован remote-модуль `yandex_compute_instance`
  (`git::https://github.com/udjin10/yandex_compute_instance.git?ref=v2.0.0`)
  дважды: для проектов **marketing** и **analytics**.
- Обе ВМ в одной VPC `develop`, подсеть `develop` (ru-central1-a).
- Принадлежность к проекту обозначена через `labels`:
  - `module.marketing_vm` → `labels = { project = "marketing", owner = "student" }`
  - `module.analytics_vm` → `labels = { project = "analytics", owner = "student" }`
- SSH-ключ передаётся через переменную `var.vms_ssh_root_key` в функцию
  `templatefile()`, результат сохранён в `locals`:
  ```hcl
  locals {
    cloudinit = templatefile("${path.module}/cloud-init.yml", {
      ssh_public_key = var.vms_ssh_root_key
    })
  }
  ```
  и передан в `metadata.user-data`.
- В `cloud-init.yml` ключ передан **списком**:
  ```yaml
  ssh_authorized_keys:
    - "${ssh_public_key}"
  ```
- В `cloud-init.yml` добавлена установка nginx:
  ```yaml
  packages:
    - nginx
  ```

### Файлы

- [`src/main.tf`](./main.tf)
- [`src/cloud-init.yml`](./cloud-init.yml)
- [`src/variables.tf`](./variables.tf)
- [`src/providers.tf`](./providers.tf)
- [`src/outputs.tf`](./outputs.tf)


</details>

<details>
  <summary>Скриншоты</summary>


**1. Подключение к ВМ и вывод `sudo nginx -t`:**

![nginx -t](./images/nginx-test.png)

**2. Консоль Yandex Cloud с метками ВМ:**

![Метки ВМ](./images/vm-labels.png)

**3. `terraform console` — содержимое модулей:**

![terraform console](./images/terraform-console.png)


![to be done](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/bG3LxXI5YN9uAA)
</details>
