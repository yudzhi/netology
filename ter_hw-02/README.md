# Домашнее задание к занятию «Основы Terraform. Yandex Cloud»
## Задание 1

[Fork-репозиторий с исправленным кодом](https://github.com/yudzhi/ter-homeworks/commits/main/02/src)

	modified:   02/src/main.tf
	modified:   02/src/providers.tf
	modified:   02/src/variables.tf

<details>
  <summary>Ход выполнения</summary>

  ### Шаг 1. Подготовка
  
```bash
# версия Yandex Cloud CLI
yc version
Yandex Cloud CLI 1.17.0 linux/amd64

# версия terraform
terraform --version
Terraform v1.12.2
on linux_amd64

yc iam service-account list
eval $(ssh-agent) && ssh-add ~/.ssh/id_ed25519

# Создание ключа
yc iam key create \
  --service-account-name terraform-sa \
  --output ~/.authorized_key.json
```
**`personal.auto.tfvars'**

```bash
cat > personal.auto.tfvars << EOF
cloud_id = "$(yc config get cloud-id)"
folder_id = "$(yc config get folder-id)"
default_zone = "ru-central1-a"
vms_ssh_root_key = "$(cat ~/.ssh/id_ed25519.pub)"
EOF
```

### Шаг 2. Поиск ошибок
#### 1. В providers.tf
```bash
Error: Invalid function argument
│ 
│   on providers.tf line 15, in provider "yandex":
│   15:   service_account_key_file = file("~/.authorized_key.json")
```

Terraform не интерпретирует символ ~ как домашнюю директорию, в отличие от командной оболочки. Функция file() ищет файл с буквальным именем ~, которого не существует в файловой системе.
**Что делать?** Использовать функцию pathexpand() для преобразования ~ в абсолютный путь перед передачей в file().

```bash
service_account_key_file = file(pathexpand("~/.authorized_key.json"))
```

#### 2. В main.tf название и конфигурация платформы

```bash
│ Error: Error while requesting API to create instance: client-request-id = 2701128f-9daa-474f-845e-ba52605c3ac6 client-trace-id = 7dc3905e-67a5-4f9f-be3c-1d9855b8bab0 rpc error: code = FailedPrecondition desc = Platform "standart-v4" not found
│ 
│   with yandex_compute_instance.platform,
│   on main.tf line 15, in resource "yandex_compute_instance" "platform":
│   15: resource "yandex_compute_instance" "platform" {
```
По привычке выберем Ice Lake standard-v3
[Перечень платформ ВМ Yandex Cloud](https://yandex.cloud/ru/docs/compute/concepts/vm-platforms)

Платформа | Процессор | Макс. кол-во ядер (vCPU)</br> на виртуальной машине | Базовая тактовая</br> частота процессора, ГГц
--- | --- | --- | ---
Intel Broadwell</br>(`standard-v1`) | Intel® Xeon® Processor E5-2660 v4 | 32 | 2.00
Intel Cascade Lake</br>(`standard-v2`) | Intel® Xeon® Gold 6230 | 80 | 2.10
Intel Ice Lake</br>(`standard-v3`) | Intel® Xeon® Gold 6338 | 96 | 2.00
AMD Zen 3</br>(`amd-v1`)^1^ | AMD EPYC™ 7713 | 128 | 2.00
AMD Zen 4</br>(`standard-v4a`) | AMD EPYC™ 9654 | 288 | 2.40

```bash
│ Error: Error while requesting API to create instance: client-request-id = c439ec24-1893-4c12-950c-1d8c82c9fca0 client-trace-id = efbdaa85-7eb2-4044-9b33-4feced8501d5 rpc error: code = InvalidArgument desc = the specified core fraction is not available on platform "standard-v3"; allowed core fractions: 20, 50, 100
```
* Платформа Intel Ice Lake (`standard-v3`):

    Лимит | Уровень<br>производительности | vCPU | RAM, ГБ<br>всего | RAM, ГБ<br>на 1 ядро
    ------------ | ----------------------------- | ---- | ---------------- | -----------------
    Мин.         | 20%                           | 2    | 1                | 0.5
    Макс.        | 100%                          | 96   | 640              | 16
  
Уровень производительности core fraction 5 доступен только для standard-v1, v2. Выберем минимальное 20%.
Количество ядер минимально возможно 2.

```hcl
  platform_id = "standard-v3" # standart → standard (опечатка)
  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }
```


#### 3.В файле variables.tf

Замените значение по умолчанию для vms_ssh_root_key переопределяется через personal.auto.tfvars.
```hcl
variable "vms_ssh_root_key" {
  type        = string
  default     = null  # Было: "<your_ssh_ed25519_key>"
  description = "ssh-keygen -t ed25519"
}
```

### Шаг 3. Ответы
Оба параметра существенно экономият бюджет, хороши для тестирования и обучения. В продакшене и критичных сервисах использовать не стоит.

#### `preemptible = true`
Прерываемая ВМ может быть остановлена Yandex Cloud в любой момент (через 24 часа или при нехватке ресурсов). 

#### `core_fraction=5`
Выделяется 5% от одного vCPU (гарантированная доля). 

</details>

<details>
  <summary>Скриншоты</summary>

![service_account_created](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/TucFQCP4Y0X3sQ)

![Yandex Cloud Console](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/DNaymBcgND-uoQ)

![Curl in Terminal](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/7FEpsWTcCPSddg)
</details>

## Задание 2. Рефакторинг Terraform кода - вынос хардкода в переменные

[Fork-репозиторий с рефакторингом](https://github.com/yudzhi/ter-homeworks/tree/main/02/src)

	modified:   02/src/main.tf
	modified:   02/src/variables.tf

<details>
  <summary>Скриншоты</summary>

![Terraform plan after refactoring](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/SVloPJymT2_phg)
</details>

## Задание 3. Создание второй ВМ
```text
VPC Network "develop"
├── Subnet "develop-a" (ru-central1-a, 10.0.1.0/24)
│   └── Web VM (ru-central1-a) 
└── Subnet "develop-b" (ru-central1-b, 10.0.2.0/24)
    └── DB VM (ru-central1-b) 
```

### Автоматизация создания подсетей - файл `locals.tf` с логикой для подсетей
Если полностью избавляться от хардкода, нужен код, который будет поддерживать все сценарии размещения ВМ (A/B, A/A, B/A, B/B), автоматически создавая только нужные подсети для уникальных зон. Можно будет расширить и на остальные зоны, но пока разберёмся с двумя.
[Hashicorp справка](https://developer.hashicorp.com/terraform/tutorials/configuration-language/locals)

`vm_web_zone = "a"`, `vm_db_zone = "b"` → `unique_zones = ["a", "b"]`

`vm_web_zone = "a"`, `vm_db_zone = "a"` → `unique_zones = ["a"]`

<details>
	<summary>Ход выполнения</summary>

```bash
	modified:   02/src/locals.tf
	modified:   02/src/main.tf
	modified:   02/src/variables.tf

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	02/src/vms_platform.tf
```

#### Файл `locals.tf`- динамическое создание подсетей только в тех зонах, где будут размещены ВМ

```hcl
locals {
  # Собираем все уникальные зоны, в которых будут созданы ВМ
  unique_zones = toset(distinct([var.vm_web_zone, var.vm_db_zone]))
  
  # Создаём map с CIDR блоками для каждой зоны
  zone_cidr_map = {
    "ru-central1-a" = var.subnet_cidr_a
    "ru-central1-b" = var.subnet_cidr_b
  }
  
  # Создаём map с именами подсетей для каждой зоны
  subnet_names = {
    for zone in local.unique_zones : 
    zone => "${var.vpc_name}-${replace(zone, "-", "_")}"
  }
  
  # Определяем, какой CIDR использовать для каждой зоны
  subnet_cidrs = {
    for zone in local.unique_zones : 
    zone => local.zone_cidr_map[zone]
  }
}
```
Функция `distinct` удаляет из списка дубликаты. Если обе переменные имеют значение "ru-central1-a", то на выходе будет list список ["ru-central1-a"] .

Функция `toset` преобразует список в множество (set) . Требуется для `for_each`, который принимает либо map, либо set of strings .

#### main.tf --> for_each мета-аргумент
[hashicorp for_each meta-argument](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each)

Мета-аргумент for_each в Terraform используется для динамического создания нескольких копий ресурса, модуля или блока данных на основе коллекции. Он заменяет необходимость писать дублирующийся код, итерируясь по словарю (map) или множеству (set) строк.

```hcl
resource "yandex_vpc_subnet" "develop" {
  for_each = local.unique_zones
  
  name           = local.subnet_names[each.key]
  zone           = each.key
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = local.subnet_cidrs[each.key]
}
```

`develop` становится map c ключами = зонам, поэтому обращение к подсети:

```hcl
subnet_id = yandex_vpc_subnet.develop[var.vm_db_zone].id
```

</details>

<details>
	<summary>Скриншоты</summary>

![Yandex Cloud Infrastructure map](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/wZgHxNCm1DaCGw)
</details>

## Задание 4. Создание Outputs
[Hashicorp Developer: Outputs](https://developer.hashicorp.com/terraform/language/v1.14.x/block/output#sensitive)

<details>
	<summary>Ход выполнения</summary>

### 'locals.tf':

```hcl
  # Список всех ВМ
  all_vms = [
    yandex_compute_instance.platform_web,
    yandex_compute_instance.platform_db
  ]
```

### 'outputs.tf':

```hcl
output "vms_info" {
  description = "Information about all VM instances"
  
  sensitive = false

  value = {
    for vm in local.all_vms :
    vm.name => {
      instance_name = vm.name
      external_ip   = vm.network_interface[0].nat_ip_address
      fqdn          = vm.fqdn
    }
  }
}
```

### `terraform output` - вывод только IP

```bash
terraform output -json vms_info | jq -r '.[] | .external_ip'
```
</details>

<details>
	<summary>Скриншоты</summary>

![Terraform output IP](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/6ayRfhy7KOPIcQ)
</details>

## Задание 5. Интерполяция и динамические имена ВМ

<details>
	<summary>Ход выполнения</summary>

### Шаг 1.1 `variables.tf` - общие переменные для всех ВМ

```hcl
### Переменные для именования (общие для всех ВМ)

variable "project_name" {
  type        = string
  default     = "netology"
  description = "Project name prefix for all resources"
}

variable "environment" {
  type        = string
  default     = "develop"
  description = "Environment: dev, staging, prod"
}

variable "platform_type" {
  type        = string
  default     = "platform"
  description = "Platform type for resource naming"
}
```

### Шаг 1.2 `vms_platform.tf` - переменные, специфичные для каждой ВМ

```hcl
variable "vm_web_role" {
  type        = string
  default     = "web"
  description = "Role of the web VM (used in naming)"
}
```

### Шаг 1.3 `locals.tf` - интерполяция

```hcl
vm_web_name = "${var.project_name}-${var.environment}-${var.platform_type}-${var.vm_web_role}"
vm_db_name  = "${var.project_name}-${var.environment}-${var.platform_type}-${var.vm_db_role}"
```

### Шаг 2 Обновление переменных

В `vms_platform.tf` удаляем переменные `vm_web_name`, `vm_db_name`
В `main.tf' используем `local.vm_web_name`, `local.vm_db_name`

### Шаг 3 Проверка

```bash
terraform validate
Success! The configuration is valid.

terraform console
> local.vm_web_name
"netology-develop-platform-web"
> local.vm_db_name
"netology-develop-platform-db"
> exit
```
</details>

<details>
	<summary>Скриншоты</summary>

![Terraform plan nothing changed](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/cx0lZt_1SBo2jg)
</details>

## Задание 6. Map-переменные для ресурсов и metadata

<details>
	<summary>Ход выполнения</summary>

`vms_platform.tf`

```hcl
### ==========================================
### MAP VARIABLE FOR VM RESOURCES
### ==========================================

variable "vms_resources" {
  description = "Resource configurations for all VMs"
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
  }))
  default = {
    web = {
      cores         = 2
      memory        = 1
      core_fraction = 20
    }
    db = {
      cores         = 2
      memory        = 2
      core_fraction = 20
    }
  }
}
```
</details>

<details>
	<summary>Скриншоты</summary>

![Terraform plan nothing changed](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/a7mULt1nw_hY5w)
</details>

## Задание 7. Terraform Console
### 7.1 Напишите, какой командой можно отобразить второй элемент списка test_list.

```bash
terraform console
> local.test_list[1]
"staging"
```

### 7.2 Найдите длину списка test_list с помощью функции length(<имя переменной>).
```bash
> length(local.test_list)
3
```

### 7.3 Напишите, какой командой можно отобразить значение ключа admin из map test_map.

```bash
> local.test_map.admin
"John"
> local.test_map["admin"]
"John"
```
### 7.4 Напишите interpolation-выражение, результатом которого будет: "John is admin for production server based on OS ubuntu-20-04 with X vcpu, Y ram and Z virtual disks", 
используйте данные из переменных test_list, test_map, servers и функцию length() для подстановки значений.

```hcl
> "${local.test_map.admin} is ${keys(local.test_map)[0]} for ${local.test_list[2]} server based on OS ${local.servers[local.test_list[2]].image} with ${local.servers[local.test_list[2]].cpu} vcpu, ${local.servers[local.test_list[2]].ram} ram and ${length(local.servers[local.test_list[2]].disks)} virtual disks"
```

<details>
	<summary>Ход выполнения</summary>

`John` = `local.test_map.admin`

'is'

'admin' = `keys(local.test_map)[0]`

'for'

'production' = `local.test_list[2]`

'server based on OS'

'ubuntu-20-04' = `local.servers.[local.test_list[2]].image`

'with'

X = `local.servers[local.test_list[2]].cpu`

'vcpu, '

Y = `local.servers[local.test_list[2]].ram`

'ram and'

Z = `length(local.servers.[local.test_list[2]].disks)`

'virtual disks'


❌ Terraform Console не позволяет объявлять новые переменные и присваивать значения:
```hcl
> local.env = local.test_list[2]

Error: Extra characters after expression
│ 
│   on <console-input> line 1:
│   (source code not available)
│ 
│ An expression was successfully parsed, but extra characters were found after it.
╵
```

Можно использовать цикл for
```hcl
> [for env in local.test_list : 
    "${local.test_map.admin} is ${keys(local.test_map)[0]} for ${env} server with ${local.servers[env].cpu} cpu, ${local.servers[env].ram} ram and ${length(local.servers[env].disks)} disks"
  ][2]
```
Но в текущем варианте `console.tf` это не работает:

| Элемент в test_list |	Ключ в servers	| Совпадают? |
|----------------|-----------|------------|
| "develop"	| "develop"	| Да |
| "staging"	| "stage"	| ❌ НЕТ! |
| "production"	| "production"	| Да |

Если изменить `console.tf`:
```hcl
test_list = ["develop", "stage", "production"] # staging --> stage
```
всё работает:

```hcl
[for env in local.test_list : 
:     "${local.test_map.admin} is ${keys(local.test_map)[0]} for ${env} server with ${local.servers[env].cpu} cpu, ${local.servers[env].ram} ram and ${length(local.servers[env].disks)} disks"
:   ]
[
  "John is admin for develop server with 2 cpu, 4 ram and 2 disks",
  "John is admin for stage server with 4 cpu, 8 ram and 2 disks",
  "John is admin for production server with 10 cpu, 40 ram and 4 disks",
]
> [for env in local.test_list : 
:     "${local.test_map.admin} is ${keys(local.test_map)[0]} for ${env} server with ${local.servers[env].cpu} cpu, ${local.servers[env].ram} ram and ${length(local.servers[env].disks)} disks"
:   ][2]
"John is admin for production server with 10 cpu, 40 ram and 4 disks"
```

</details>

<details>
	<summary>Скриншоты</summary>

![Terraform console](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/5VEah2qsFs7B9g)

![console.tf changed](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/2C8qkN369d9R8Q)
</details>

