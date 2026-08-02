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
[task 6 commit](https://github.com/yudzhi/ter-homeworks/commit/671ad9adab8c6c943d4d178acc7556110c6c54a5)

<details>
  <summary>Ход выполнения</summary>

[null_resource](https://library.tf/providers/hashicorp/null/latest)

> The primary use-case for the null resource is as a do-nothing container for arbitrary actions taken by a provisioner. In this example, three EC2 instances are created and then a null_resource instance is used to gather data about all three and execute a single action that affects them all. Due to the triggers map, the null_resource will be replaced each time the instance ids change, and thus the remote-exec provisioner will be re-run.
> 
> On Terraform 1.4 and later, use the terraform_data resource type instead. Terraform 1.9 and later support the moved configuration block from null_resource to terraform_data.
> 
> The triggers argument allows specifying an arbitrary set of values that, when changed, will cause the resource to be replaced.

### Шаг 1. Отключаем внешние IP у существующих ВМ
Вводим новые управляющие переменные в `vms_platform.tf`:

```hcl
variable "enable_nat_for_vms" {
  description = "Включать ли NAT (внешний IP) для обычных ВМ"
  type        = bool
  default     = true
}

variable "enable_nat_for_bastion" {
  description = "Включать ли NAT для bastion-сервера"
  type        = bool
  default     = true
}
```

Обновляем ресурсы:
```hcl
# count-vm.tf
network_interface {
  nat = var.enable_nat_for_vms  # ✅
}

# for_each-vm.tf
network_interface {
  nat = var.enable_nat_for_vms  # ✅
}

# disk_vm.tf
network_interface {
  nat = var.enable_nat_for_vms  # ✅
}
```

### Шаг 2. Создадим bastion-server
`vms_platform.tf`
```hcl
variable "bastion" {
  description = "Параметры bastion-сервера"
  type = object({
    enable    = bool # bool => count=1, false => count=0
    name      = string
    cpu       = number
    ram       = number
    disk_size = number
  })
  default = {
    enable    = true
    name      = "bastion"
    cpu       = 2
    ram       = 2
    disk_size = 20
  }
}
```

`bastion.tf`:
```hcl
resource "yandex_compute_instance" "bastion" {
  count = var.bastion.enable ? 1 : 0
```

### Шаг 3. Обновим шаблон inventory (`hosts.tftpl`)

Теперь нужно, чтобы inventory использовал внешние IP для ВМ при отсутствии бастиона и внутренние IP при его наличии.
Используем переменную `vm.ansible_host` для автоматизации подстановки нужного IP:
```hcl
[webservers]
%{ for vm in webservers ~}
${vm.name} ansible_host=${vm.ansible_host} fqdn=${vm.fqdn}
%{~ endfor ~}

[databases]
%{ for vm in databases ~}
${vm.name} ansible_host=${vm.ansible_host} fqdn=${vm.fqdn}
%{~ endfor ~}

[storage]
%{ for vm in storage ~}
${vm.name} ansible_host=${vm.ansible_host} fqdn=${vm.fqdn}
%{~ endfor ~}

[bastion]
%{ for vm in bastion ~}
${vm.name} ansible_host=${vm.ansible_host} fqdn=${vm.fqdn}
%{~ endfor ~}
```

### Шаг 4. Настройка прокси-бастиона в `inventory.ini`
```ini
# inventory.ini
[webservers]
web-1 ansible_host=10.0.1.11

# Настройка прокси:
[webservers:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ubuntu@84.201.150.100"'

# Ansible подключается через прокси:
ssh -o ProxyCommand="ssh -W %h:%p -q ubuntu@84.201.150.100" ubuntu@10.0.1.11
```

`ProxyCommand=`	Указывает Ansible, как подключаться к целевой ВМ

`ssh`	Используем SSH для проксирования

`-W %h:%p`	Перенаправляем трафик на целевой хост (%h) и порт (%p)

`-q`	Тихий режим (без лишних сообщений)

`ubuntu@84.201.150.100`	Подключаемся к bastion под пользователем ubuntu

*Для подключения к целевой ВМ сначала запусти SSH-туннель через bastion-сервер, и перенаправь весь трафик через него*

`hosts.tftpl`:
```hcl
# Proxy через bastion (если есть)
%{ if length(bastion) > 0 }
[webservers:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ubuntu@${bastion[0].ansible_host}"'

[databases:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ubuntu@${bastion[0].ansible_host}"'

[storage:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ubuntu@${bastion[0].ansible_host}"'
%{ endif }

```

### Шаг 5. Выбор внутреннего или внешнего IP - функция `coalesce`

Определим для всех групп `ansible_host` переменную.

`ansible.tf`:
```hcl
locals {
  # --------------------------------------------
  # Выбор внутреннего или внешнего IP для Ansible
  # --------------------------------------------
  
  # Все ВМ в одном map для удобства
  all_vms = merge(
    # vm — это элемент списка
    { for vm in yandex_compute_instance.web : vm.name => vm },
    # name — это ключ, vm — значение
    { for name, vm in yandex_compute_instance.db : vm.name => vm },
    # превращаем в список и перебираем
    { for vm in [yandex_compute_instance.storage] : vm.name => vm }
  )

  # Вспомогательная функция для выбора IP
  # Использует coalesce() - возвращает первое НЕ ПУСТОЕ значение
  # Если внешний IP есть → используем его, иначе → внутренний IP
  # Функция для получения ansible_host для любой ВМ
  get_ansible_host = {
    for name, vm in local.all_vms : 
    name => coalesce(
      vm.network_interface.0.nat_ip_address,
      vm.network_interface.0.ip_address
    )
  }
```
Далее во всех группах:

```hcl
      ansible_host = local.get_ansible_host[instance.name]
      nat_ip      = instance.network_interface.0.nat_ip_address
      internal_ip = instance.network_interface.0.ip_address
```

#### Особенности синтаксиса для for

|Ресурс |	Способ создания	| Тип данных |	Доступ к элементам |
|--------|------------|-------------|----------------|
| yandex_compute_instance.web |	count	| Список (list)	| По индексу: web[0], web[1] |
| yandex_compute_instance.db	| for_each | Map (словарь) |	По ключу: db["main"] |
| yandex_compute_instance.storage |	Одиночный |	Объект (object) |	Прямой доступ: storage |

`for instance in yandex_compute_instance.db` работает, потому что Terraform автоматически преобразует map в список значений, когда `for` используется без указания ключа.

Способ 1: С ключом и значением (явный)
```hcl

# Получаем И ключ, И значение
[ for name, instance in yandex_compute_instance.db : {
  key = name           # ← "main", "replica"
  name = instance.name # ← "db-main", "db-replica"
}]
```
Способ 2: Только со значением (неявный)
```hcl

# Получаем только значение (ключ игнорируется)
[ for instance in yandex_compute_instance.db : {
  name = instance.name  # ← "db-main", "db-replica"
}]
# map → [значение1, значение2] → for instance in список
```

### Шаг 6. Добавляем группу bastion в `ansible.tf`
```hcl
# Группа Bastion-сервер
  bastion_servers = [
    for instance in yandex_compute_instance.bastion : {
      name        = instance.name
      nat_ip      = instance.network_interface.0.nat_ip_address
      internal_ip = instance.network_interface.0.ip_address
      
      # Для bastion используем внешний IP (он всегда есть)
      ansible_host = instance.network_interface.0.nat_ip_address
    }
  ]
```

### Шаг 7. Анализ `test.yml` - playbook
```yaml
---
- name: test                      # Название play
  gather_facts: false              # Не собирать факты (быстрее)
  hosts: webservers                # Только для группы webservers
  vars:
    ansible_ssh_user: ubuntu       # Пользователь для SSH
  become: yes                      # Использовать sudo

  pre_tasks:                       # Задачи ДО основных
    - name: Validating the ssh port is open
      wait_for:                    # Ожидание готовности SSH
        host: '{{ (ansible_ssh_host|default(ansible_host))|default(inventory_hostname) }}'
        port: 22
        delay: 5
        timeout: 300
        search_regex: OpenSSH

  tasks:                           # Основные задачи
    - name: save own secret        # Сохранить секрет для конкретной ВМ
      copy:
        dest: /tmp/own.pass
        content: "{{ secrets[inventory_hostname] }}"
      when: secrets[inventory_hostname] is defined

    - name: save all secrets       # Сохранить все секреты
      copy:
        dest: /tmp/all.pass
        content: "{{ secrets }}"
      when: secrets is defined
```

#### - pre_tasks — ожидание готовности SSH перед выполнением задач

- Ждёт, пока на порту 22 (SSH) не появится служба
- Проверяет каждые 5 секунд (delay: 5)
- Ждёт до 300 секунд (5 минут)
- Ищет строку "OpenSSH" в ответе

ВМ может создаваться несколько минут, Cloud-init может настраивать систему после первого запуск - без этого Ansible может попытаться подключиться к ещё не готовой ВМ

#### - работа с secrets — передача чувствительных данных через Ansible

- Переменная secrets передаётся извне (через --extra-vars)
- Для каждой ВМ сохраняется свой секрет в /tmp/own.pass
- Все секреты сохраняются в /tmp/all.pass

Для передачи и безопасного хранения чувствительных данных - паролей, токенов, ключей на ВМ

#### - передача данных через --extra-vars

### Шаг 8. Запуск playbook

#### Переменная запуска в `vms_platform.tf`
```hcl
# ============================================
# Применение Ansible playbook
# ============================================

variable "run_ansible" {
  description = "Запускать ли Ansible playbook"
  type        = bool
  default
```

#### null-resource в `ansible.tf`
```hcl
resource "null_resource" "ansible_provision" {
  count = var.run_ansible ? 1 : 0
  
  depends_on = [
    yandex_compute_instance.web,
    yandex_compute_instance.db,
    yandex_compute_instance.storage,
    yandex_compute_instance.bastion,
    local_file.ansible_inventory
  ]
  
  triggers = {
    all_vm_ids     = join(",", local.all_vm_ids)
    inventory_hash = md5(local.inventory_content)
    playbook_hash  = filemd5("${path.module}/site.yml")
  }
  
  # Добавление приватного ключа в ssh-agent
  provisioner "local-exec" {
    command = "eval $(ssh-agent) && cat ~/.ssh/id_ed25519 | ssh-add -"
    on_failure = continue
  }
  
  # УБИРАЕМ sleep 60 (это делает pre_tasks в Ansible)
  # provisioner "local-exec" {
  #   command = "sleep 60"
  #   on_failure = continue
  # }
  
  # Запуск Ansible playbook с передачей секретов
  provisioner "local-exec" {
    command = <<-EOT
      echo "Запуск Ansible playbook..."
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible-playbook \
        -i ${abspath(path.module)}/inventory.ini \
        ${abspath(path.module)}/site.yml \
        --extra-vars '{
          "secrets": ${jsonencode({
            for vm in yandex_compute_instance.web : 
            vm.name => "secret_for_${vm.name}"
          })}
        }'
      
      if [ $? -eq 0 ]; then
        echo "Ansible playbook выполнен успешно"
      else
        echo "Ошибка при выполнении Ansible playbook"
        exit 1
      fi
    EOT
    on_failure = continue
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}
```

### Шаг 9. Обновление security group (добавление правил для bastion)

Для бастиона (публичный доступ):

    Кто: Трафик приходит из публичного интернета (0.0.0.0/0).

    Что: Правила разрешают входящий SSH-доступ на порт 22 с любых IP-адресов.

    Зачем: Чтобы разработчик или администратор мог подключиться к бастион-хосту из любой точки мира.

Для внутренних ВМ (web, db, storage):

    Кто: Трафик приходит только от бастион-хоста, а не из публичного интернета.

    Что: Правила разрешают входящий SSH-доступ на порт 22 только с внутреннего IP-адреса бастиона (например, из подсети 10.0.1.0/24).

    Зачем: Это позволяет полностью скрыть внутренние ВМ от внешнего мира, делая их доступными исключительно через защищенный бастион. Это значительно снижает поверхность атак.

**А давайте реализуем динамическую группу безопасности, которая будет автоматически адаптироваться под текущую конфигурацию. Потому что почему бы и нет**

```text
ЛОГИКА ОПРЕДЕЛЕНИЯ ПРАВИЛ
│
├── 1. БАЗОВЫЕ ПРАВИЛА (всегда)
│   └── HTTP (80) и HTTPS (443) → всегда нужны для веб-серверов
│
├── 2. SSH ПРАВИЛА (зависят от enable_nat_for_vms)
│   │
│   ├── Если enable_nat_for_vms = true:
│   │   └── SSH из интернета (0.0.0.0/0) → прямой доступ
│   │
│   └── Если enable_nat_for_vms = false:
│       └── SSH из подсети (10.0.1.0/24) → только через bastion
│
└── 3. SSH ДЛЯ BASTION (зависит от bastion.enable)
    │
    └── Если bastion.enable = true:
        └── SSH из интернета (0.0.0.0/0) → доступ к bastion
```

```hcl
locals {
  # Получаем CIDR из созданного ресурса подсети
  subnet_cidr = yandex_vpc_subnet.develop.v4_cidr_blocks

  # Базовые правила, которые нужны всегда
  ingress_rules_always = [
    # HTTP доступ (всегда нужен для веб-серверов)
    {
      protocol       = "TCP"
      description    = "HTTP доступ (веб-серверы)"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 80
    },
    # HTTPS доступ (всегда нужен для веб-серверов)
    {
      protocol       = "TCP"
      description    = "HTTPS доступ (веб-серверы)"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 443
    }
  ]

  # Правила для SSH в зависимости от режима
  ingress_rules_ssh = var.enable_nat_for_vms ? [
    # Режим с NAT (ВМ видны из интернета)
    {
      protocol       = "TCP"
      description    = "SSH доступ из интернета (прямой)"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 22
    }
    ] : [
    # Режим без NAT (ВМ скрыты, доступ через bastion)
    {
      protocol       = "TCP"
      description    = "SSH доступ из приватной подсети (через bastion)"
      v4_cidr_blocks = local.subnet.cidr
      port           = 22
    }
  ]

  # Правила для bastion (если он включён)
  ingress_rules_bastion = var.bastion.enable ? [
    {
      protocol       = "TCP"
      description    = "SSH доступ для bastion (публичный)"
      v4_cidr_blocks = ["0.0.0.0/0"]
      port           = 22
    }
  ] : []

  # Финальный набор правил
  ingress_rules = concat(
    local.ingress_rules_always, # HTTP, HTTPS
    local.ingress_rules_ssh,    # SSH (зависит от режима)
    local.ingress_rules_bastion # SSH для bastion (если включён)
  )
}

# --------------------------------------------
# ГРУППА БЕЗОПАСНОСТИ С ДИНАМИЧЕСКИМИ ПРАВИЛАМИ
# --------------------------------------------

resource "yandex_vpc_security_group" "example" {
  name       = var.security_group_name
  network_id = yandex_vpc_network.develop.id
  folder_id  = var.folder_id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      protocol       = ingress.value.protocol
      description    = ingress.value.description
      port           = lookup(ingress.value, "port", null)
      from_port      = lookup(ingress.value, "from_port", null)
      to_port        = lookup(ingress.value, "to_port", null)
      v4_cidr_blocks = ingress.value.v4_cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.security_group_egress_rules
    content {
      protocol       = egress.value.protocol
      description    = egress.value.description
      port           = lookup(egress.value, "port", null)
      from_port      = lookup(egress.value, "from_port", null)
      to_port        = lookup(egress.value, "to_port", null)
      v4_cidr_blocks = egress.value.v4_cidr_blocks
    }
  }
}
```
</details>

<details>
  <summary>Скриншоты</summary>

![inventory with bastion](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/bG3LxXI5YN9uAA)
</details>

## Задание 7. Удаление элементов из списков Terraform

```hcl
{
  network_id  = local.vpc.network_id
  subnet_ids  = concat(slice(local.vpc.subnet_ids, 0, 2), slice(local.vpc.subnet_ids, 3, length(local.vpc.subnet_ids)))
  subnet_zones = concat(slice(local.vpc.subnet_zones, 0, 2), slice(local.vpc.subnet_zones, 3, length(local.vpc.subnet_zones)))
}
```

С комментариями:

```hcl
# Исходный список
subnet_ids = ["e9b0le401619ngf4h68n", "e2lbar6u8b2ftd7f5hia", "b0ca48coorjjq93u36pl", "fl8ner8rjsio6rcpcf0h"]
# индексы:          0                         1                         2                         3

# slice(list, start, end) — берёт элементы от start до end (не включая end)
slice(subnet_ids, 0, 2)  # → ["e9b0le401619ngf4h68n", "e2lbar6u8b2ftd7f5hia"]  (элементы 0 и 1)
slice(subnet_ids, 3, 4)  # → ["fl8ner8rjsio6rcpcf0h"]                        (элемент 3)

# concat() — объединяет списки
concat(slice(...), slice(...))  # → ["e9b0le401619ngf4h68n", "e2lbar6u8b2ftd7f5hia", "fl8ner8rjsio6rcpcf0h"]
```
## Задание 9. Сложные списки
`["rc01","rc02","rc03","rc04",rc05","rc06","rc11","rc12","rc13","rc14",rc15","rc16","rc19"....."rc96"]` те список от "rc01" до "rc96", пропуская все номера, заканчивающиеся на "0","7", "8", "9", за исключением "rc19"

```bash
# Запуск консоли
terraform console

# Задача 1: Список от rc01 до rc99
> [for i in range(1, 100) : format("rc%02d", i)]

# Задача 2: Список с пропусками
> [
    for i in range(1, 97) :
    format("rc%02d", i)
    if i == 19 || !contains([0, 7, 8, 9], i % 10)
  ]
```

```text
ЗАДАЧА 1: Список "rc01" - "rc99"
│
└── [for i in range(1, 100) : format("rc%02d", i)]

ЗАДАЧА 2: Список с пропусками
│
└── [
      for i in range(1, 97) :
      format("rc%02d", i)
      if i == 19 || !contains([0, 7, 8, 9], i % 10)
    ]

КЛЮЧЕВЫЕ ФУНКЦИИ:
│
├── range(start, end) — генерирует числа
├── format("rc%02d", i) — форматирует с ведущим нулём
├── contains(list, value) — проверяет наличие
└── i % 10 — последняя цифра числа

ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ:
│
├── Имена ВМ: [for i in range(1, 10) : format("web-%02d", i)]
├── Имена дисков: [for i in range(1, 5) : format("disk-%02d", i)]
└── Имена подсетей: [for i in range(1, 4) : format("subnet-%02d", i)]
```
### Задача 1: Список от "rc01" до "rc99"

```hcl

[for i in range(1, 100) : format("rc%02d", i)]
```

- range(1, 100) — генерирует числа от 1 до 99
- `format("rc%02d", i)` — форматирует число в строку с ведущим нулём
- `%02d` — означает: число минимум из 2 цифр, с ведущим нулём

### Задача 2: Список с пропусками

```hcl

[
  for i in range(1, 97) :
  format("rc%02d", i)
  if i == 19 || !contains([0, 7, 8, 9], i % 10)
]
```

- `i % 10` возвращает последнюю цифру числа i
- `contains([0, 7, 8, 9], i % 10)` — проверяет, является ли последняя цифра одной из запрещённых
- `!contains(...)` — инвертирует условие (пропускаем, если НЕ заканчивается на 0,7,8,9)
- `i == 19 || ... `— всегда включаем 19

*i % 10 — это оператор взятия остатка от деления (modulo)*
### Практическое применение в проекте: 
```hcl
# vms_platform.tf
variable "vm_count" {
  description = "Количество ВМ"
  type        = number
  default     = 99
}

locals {
  # Список имён ВМ
  vm_names = [for i in range(1, var.vm_count + 1) : format("vm-%02d", i)]
  
  # Список имён ВМ с пропусками
  vm_names_filtered = [
    for i in range(1, var.vm_count + 1) :
    format("vm-%02d", i)
    if i == 19 || !contains([0, 7, 8, 9], i % 10)
  ]
}

# Использование в ресурсах
resource "yandex_compute_instance" "vm" {
  count = length(local.vm_names)
  name  = local.vm_names[count.index]
  # ...
}
```
