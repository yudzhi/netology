# Домашнее задание к занятию «Продвинутые методы работы с Terraform»

## NB - сбой у Yandex Cloud
Подсеть и ВМ перенесены в зону `ru-central1-d`, дефолтная платформа заменена на доступную в этой зоне `standard-v2`: 

```
Error while requesting API to create instance: x-request-id = abbbef50-2a0f-4d6c-bc2a-3177da6fc77b x-server-trace-id = 970e497cdeb1fdf4:d5988e5d8126227c:49582a369b917f2d:1 x-client-trace-id = 0bac0c56-dac9-4d66-8577-0dde61a6df56 rpc error: code = FailedPrecondition desc = Zone ru-central1-a is not available
```

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

```bash
yc compute instance list
ssh ubuntu@<EXTERNAL IP>
sudo nginx -t
```

![nginx -t](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/K4KLvCCz1R2wBg)

[nginx -t_YD](https://disk.yandex.ru/i/K4KLvCCz1R2wBg)

**2. Консоль Yandex Cloud с метками ВМ:**

![Метки ВМ](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/HY6Qs97udaVm_g)

![Метки ВМ_YD](https://disk.yandex.ru/i/HY6Qs97udaVm_g)

![Карта ВМ](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/ZWXhNAp2T76A1w)

[Карта ВМ_YD](https://disk.yandex.ru/i/ZWXhNAp2T76A1w)

**3. `terraform console` — содержимое модулей:**

![terraform console](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/RqICwcZyTkWq5w)

[terraform console_YD](https://disk.yandex.ru/i/RqICwcZyTkWq5w)

![Сбой YC](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/iYc3i_eMsFBl3Q)

[Сбой YC_YD](https://disk.yandex.ru/i/iYc3i_eMsFBl3Q)

</details>

## Задание 2.

[`vpc/README.md`](https://github.com/yudzhi/netology/blob/terraform-04/ter_hw-04/src/vpc/README.md)

<details>
<summary>Ход выполнения</summary>

### У нас есть план, будем  его придерживаться
- Создать модуль
- Заменить старые ресурсы yandex_vpc_network и yandex_vpc_subnet на вызов module "vpc_dev"
- Передать subnet_id из модуля в модули ВМ
- Сгенерировать документацию через terraform-docs

### Нюанс 1. Расположение модуля
Remote-модули `analytics_vm` и `marketing_vm` подключались через удалённый источник:

```hcl

source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=v2.0.0"
```

`terraform init` => Terraform скачивает код из Git и кэширует его в `.terraform/modules` . Это временный кэш, который можно удалить в любой момент — Terraform восстановит его при следующем init.

Модуль `vpc` — локальный. Живёт в `vpc/` рядом с корневыми .tf-файлами и подключается через относительный путь:
```hcl

source = "./vpc"
```

Для локальных модулей Terraform не копирует код в `.terraform/modules`, читает файлы напрямую из указанной папки и автоматически замечает изменения в локальном модуле без повторного запуска `init` 

### vpc/variables.tf
Вызов из задания: 
```
module "vpc_dev" {
  source       = "./vpc"
  env_name     = "develop"
  zone = "ru-central1-a"
  cidr = "10.0.1.0/24"
}
```
Нужны:
- имя сети `env_name` - можно сформировать как `${var.env_name}`-subnet или `${var.env_name}`
- зона `zone`
- `cidr`

```hcl
variable "env_name" {
  type        = string
  description = "VPC network&subnet name"
}

variable "zone" {
  type        = string
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope (ru-central1-a)"
}

variable "cidr" {
  type        = string
  description = "CIDR block for the subnet (10.0.1.0/24)"
}
```
default-значения переменных убраны, чтобы модуль требовал их явно и ничего не придумывал сам.

### Нюанс 2. CIDR type
`src/variables.tf` - `list(string)`

Ресурс [yandex_vpc_subnet](https://yandex.cloud/ru/docs/terraform/data-sources/vpc_subnet) в  Yandex Cloud принимает аргумент `v4_cidr_blocks` как список строк.

Задание требует передать в модуль `cidr = "10.0.1.0/24"` — строку. Значит, в `vpc/variables.tf' будет `type = string`

Внутри модуля для `yandex_vpc_subnet` строку оборачиваем в список: `v4_cidr_blocks = [var.cidr]` — инкапсуляция.

### Нюанс 3. vpc/main.tf и `this`
В задании модуль должен создавать одну сеть и одну подсеть:

*когда модуль создаёт только один ресурс определённого типа (например, только одну сеть), рекомендуется называть его this. Это позволяет избежать повторения имени типа ресурса в имени ресурса и чётко обозначить «этот единственный» ресурc*

[antonbabenko/terraform-best-practices](https://raw.githubusercontent.com/wilsonmar/terraform-best-practices/refs/heads/master/naming.md#1)
>Resource name should be named `this` if there is no more descriptive and general name available, or if the resource module creates a single resource of this type (eg, in [AWS VPC module](https://github.com/terraform-aws-modules/terraform-aws-vpc) there is a single resource of type `aws_nat_gateway` and multiple resources of type`aws_route_table`, so `aws_nat_gateway` should be named `this` and `aws_route_table` should have more descriptive names - like `private`, `public`, `database`).

```hcl
resource "yandex_vpc_network" "this" {
  name = var.env_name
}

resource "yandex_vpc_subnet" "this" {
  name           = "${var.env_name}-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.cidr]
}
```

### Нюанс 4. vpc/outputs.tf - что выводить?

Что нужно? Информация о модуле `> module.vpc_dev`
ВМ модули запрашивают
- `network_id`
- `subnet_zones` (list)
- `subnet_ids` (list)

Можно сделать несколько outputs, можно один, можно один и прописать в нём конкретные параметры. Всё это влияет лишь на удобство передачи в корневом `main.tf` необходимых параметров в другие модули.
Нужно выбрать между:
- `module.vpc_dev.subnet.id` - а если другим модулям понадобятся другие outputs?
- `module.vpc_dev.subnet_id` - тут надо лезть в структуру, и в консоль выведеться только верхнеуровневая информация
- `module.vpc_dev.vpc.subnet_id` - нужно собрать универсальный набор параметров

Пусть будет один структурированный output:

```hcl
output "vpc" {
  description = "VPC module result: subnet object, IDs, and key attributes"
  value = {
    subnet         = yandex_vpc_subnet.this
    subnet_id      = yandex_vpc_subnet.this.id
    subnet_name    = yandex_vpc_subnet.this.name
    subnet_zone    = yandex_vpc_subnet.this.zone
    subnet_cidr    = yandex_vpc_subnet.this.v4_cidr_blocks
    network_id     = yandex_vpc_network.this.id
    network_name   = yandex_vpc_network.this.name
  }
}
```
**Итого:**
Модуль vpc возвращает единственный output `vpc`, внутри которого:

    `subnet` — полный объект yandex_vpc_subnet;

    `subnet_id` — ID подсети для передачи в модули ВМ;

    `network_id` — ID сети для передачи в модули ВМ.

    `subnet_zone` - ВМ гарантированно должна попасть в ту же зону, что и подсеть
    
   и др.

В terraform console команда `module.vpc_dev` показывает содержимое этого output.

### Нюанс 5. Вызов в main.tf и обёртка
- убираем `resource "yandex_vpc_network"`, `resource "yandex_vpc_subnet"`
- вызываем модуль

```hcl
module "vpc_dev" {
  source   = "./vpc"
  env_name = "develop"
  zone     = var.default_zone
  cidr     = var.default_cidr[0]
}
```
- передаём параметры в ВМ модули (на забыть обёртку `[...]` для `subnet_zones` & `subnet_ids`, поскольку модуль сейчас отдаёт по одному элементу - строке. Будет создавать по нескольку зон и подсетей - можно будет без обёртки, но не забываем следить, чтобы эти списки были одинаковой длины)

```hcl
network_id     = module.vpc_dev.vpc.network_id
subnet_zones   = [module.vpc_dev.vpc.subnet_zone]
subnet_ids     = [module.vpc_dev.vpc.subnet_id]
```

### Проверка. 

```bash
terraform init -upgrade
terraform validate
terraform plan
terraform apply
```

### terraform-docs

```bash
docker run --rm --volume "$(pwd):/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:latest markdown /terraform-docs/vpc > vpc/README.md
```

</details>

<details>
<summary>Скриншоты</summary>

```bash
terraform console
```
```hcl
module.vpc_dev
module.vpc_dev.vpc.subnet_id
```
![vpc_dev](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/YeA1K5p3xRgrrQ)

[vpc_dev_YD](https://disk.yandex.ru/i/YeA1K5p3xRgrrQ)
</details>

## Задание 3. Terraform state 

<details>
  <summary>Ход выполнения</summary>

### 1. terraform - список ресурсов

```bash
terraform state list

module.analytics_vm.data.yandex_compute_image.my_image
module.analytics_vm.yandex_compute_instance.vm[0]
module.marketing_vm.data.yandex_compute_image.my_image
module.marketing_vm.yandex_compute_instance.vm[0]
module.vpc_dev.yandex_vpc_network.this
module.vpc_dev.yandex_vpc_subnet.this


terraform state pull > state_before.json
```

**Добавить `*state_before.*` в `.gitignore`**

### 2. vpc модуль удалить из стейта

`state` можно редактировать отдельно от реальной инфраструктуры: команда `terraform state rm` убирает запись из `state`, но не удаляет сам ресурс в облаке 

```bash
terraform state rm module.vpc_dev
```

### 3. vm модуль удалить из стейта

```bash
terraform state rm module.marketing_vm
terraform state rm module.analytics_vm

terraform state list
```
[terraform_state_rm_YD](https://disk.yandex.ru/i/fcYbMNUSu011gQ)

### 4. импорт всего обратно. terraform plan

```bash
# Собираем ID
yc vpc network list
yc vpc subnet list
yc compute instance list

# Импортируем обратно
terraform import module.vpc_dev.yandex_vpc_network.this <NETWORK_ID>
terraform import module.vpc_dev.yandex_vpc_subnet.this <SUBNET_ID>
terraform import module.marketing_vm.yandex_compute_instance.vm[0] <MARKETING_VM_ID>
terraform import module.analytics_vm.yandex_compute_instance.vm[0] <ANALYTICS_VM_ID>


[IDs](https://disk.yandex.ru/i/WAWG4a4NDEvd9g)

[terraform import](https://disk.yandex.ru/i/IdkYIpUGU9Kvrg) 
# Проверка plan
terraform plan
```

После импорта `terraform plan` показал только незначительное изменение: добавление флага `allow_stopping_for_update = true` к обеим ВМ (update in-place, без пересоздания). После `terraform apply` plan показывает `No changes`. Значимых изменений нет.

[terraform_plan](https://disk.yandex.ru/i/ialkyQGiH7_uuw)

</details>

## Задание 4. vpc - каждой зоне по своей подсети

<details>
  <summary>Ход выполнения</summary>

### план, нюансы, мысли в слух

- `subnets = list(object)` instead of `zone, cidr = string`
- `for_each` или `count`?
Подсети идентифицируются по зоне, а не по позиции в списке. Для однотипных ВМ используем `count`, для подсетей есть ключ - зона, в которой она создаётся. Если удалить или переставить элемент в списке, `count` пересоздаст все подсети после изменённого индекса, а `for_each` затронет только ту, которую реально изменили.
- оставить `this` для сети (она по-прежнему одна), изменить имена для подсетей
Когда ресурсов несколько, имя должно отражать роль или ключ. Пусть будет
`resource "yandex_vpc_subnet" "for_zone"`
- обновить вызовы в корневом `main.tf`
- `terraform plan`
- Yandex Cloud не поддерживает зону [ru-central1-c](https://yandex.cloud/en/docs/overview/concepts/geo-scope) в новых проектах — можно будет добавить предупреждение - только ru-central1-a, ru-central1-b, ru-central1-d, ru-central1-e


### vpc/variables.tf

Пример вызова из задания:

```hcl
subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
  ]
```
Список объектов с фиксированными полями

```hcl
variable "subnets" {
  type = list(object({
    zone = string
    cidr = string
  }))
  description = "List of subnets to create: each object contains zone and cidr"
}
```

### vpc/main.tf и MOVED

```hcl
resource "yandex_vpc_subnet" "for_zone" {
  for_each = { for s in var.subnets : s.zone => s}

  name           = "${var.env_name}-subnet-${each.key}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [each.value.cidr]

}
```
`for_each` принимает `map` - надо преобразовать. 

Ключ - зона => значение - объект `{zone, cidr}`

**Как не пересоздавать подсеть**

```hcl
moved {
  from = yandex_vpc_subnet.this
  to   = yandex_vpc_subnet.for_zone["ru-central1-d"]
}
```

### vpc/outputs.tf

Пусть будет общий вывод (map) и выводы для передачи в модуль ВМ:

```hcl
output "vpc" {
  description = "VPC module result: network and subnets for each zone"
  value = {
    network_id     = yandex_vpc_network.this.id
    network_name   = yandex_vpc_network.this.name
    subnets = {
        for zone, subnet in yandex_vpc_subnet.for_zone : zone => {
            id   = subnet.id
            name = subnet.name
            zone = subnet.zone
            cidr = subnet.v4_cidr_blocks
        }
    }
    subnet_ids = [for s in yandex_vpc_subnet.for_zone : s.id]
    subnet_zones = [for s in yandex_vpc_subnet.for_zone : s.zone]
  }
}
```
### main.tf корневой

Берём код из примера вызова задания, заменяем неподдерживаемую зону `ru-central1-c`-> `ru-central1-d`

```hcl
module "vpc_prod" {
  source       = "./vpc"
  env_name     = "production"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", cidr = "10.0.2.0/24" },
    { zone = "ru-central1-d", cidr = "10.0.3.0/24" },
  ]
}

module "vpc_dev" {
  source       = "./vpc"
  env_name     = "develop"
  subnets = [
    { zone = "ru-central1-d", cidr = "10.0.1.0/24" },
  ]
}
```

Вызов в модуле ВМ:
```hcl
subnet_zones = module.vpc_dev.vpc.subnet_zones
subnet_ids = module.vpc_dev.vpc.subnet_ids
# subnet_zones   = [module.vpc_dev.vpc.subnet_zone] Задание 2
# subnet_ids     = [module.vpc_dev.vpc.subnet_id] Задание 2
```

Модули ВМ вызываются с `instance_count = 1`, поэтому создают одну ВМ в первой зоне из `subnet_zones` (индекс 0) и в первой подсети из `subnet_ids` (индекс 0). Списки `subnet_zones` и `subnet_ids` передаются из `module.vpc_dev.vpc`. Если увеличить `instance_count` до числа зон, модуль создаст по ВМ в каждой зоне (распределение по кругу через `element`):

```hcl
zone = element(var.subnet_zones, count.index)

subnet_id = element(var.subnet_ids, count.index)
```
</details>

<details>
  <summary>Скриншоты</summary>

```bash
terraform init -upgrade
terraform validate
terraform plan

# module.vpc_dev.yandex_vpc_subnet.for_zone["ru-central1-d"] will be created
# module.vpc_dev.yandex_vpc_subnet.this will be destroyed
 # module.analytics_vm.yandex_compute_instance.vm[0] will be updated in-place
# module.marketing_vm.yandex_compute_instance.vm[0] will be updated in-place

Plan: 5 to add, 2 to change, 1 to destroy
```

terraform предлагает пересоздать подсеть для `vpc_dev` из-за нового формата имени, при этом ВМ не пересозадются - новый `subnet_id` подставится 'in-place'. Плюс добавляется кластер сеть+подсети `vpc_prod`

[terraform_plan_1](https://disk.yandex.ru/i/LK6EkDnIOxcQLQ)

[terraform_plan_2](https://disk.yandex.ru/i/tczKxj0Mw7XSEw)

[terraform_plan_3](https://disk.yandex.ru/i/-JpJFuAgL-P5tg)

Чтобы избавиться от пересоздания подсети (которое невозможно, поскольку в ней уже работают две ВМ), добавляем в `vpc/main.tf` блок `moved`.

[terraform_plan_4](https://disk.yandex.ru/i/uhDOUul1CyiS6Q)

```bash
yc vpc subnet list
```

[yc_vpc_subnet_list](https://disk.yandex.ru/i/IwZkj-BPEmojvg)

[infrastructure_map](https://disk.yandex.ru/i/0v2BthSOqk_Tpw)

</details>

## Задание 5. БД MySQL

<details>
  <summary>Ход выполнения</summary>

### Начнём по порядку. Что нужно и что происходит
#### Ресурсы
- [yandex_mdb_mysql_cluster](https://library.tf/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_cluster)
- [yandex_mdb_mysql_database](https://library.tf/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_database)
- [yandex_mdb_mysql_user](https://library.tf/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_user)
#### Что нужно

1. Создать два независимых Terraform-модуля для Yandex Managed Service for MySQL:

- Модуль кластера — создаёт `yandex_mdb_mysql_cluster`. Переменная `ha` (bool): `true` → 2 хоста, `false` → 1 хост.

- Модуль базы и пользователя — создаёт `yandex_mdb_mysql_database` и `yandex_mdb_mysql_user` в существующем кластере по `cluster_id`.

2. Создать кластер `example` с одним хостом (`ha = false`), добавить БД `test` и пользователя `app`. 

3. `ha = true` —> Terraform добавляет второй хост. 

4. Удалить всё, потому что дорого. 
  
#### Что происходит

[Yandex Managed Service for MySQL](https://yandex.cloud/ru/docs/managed-mysql/)

- [Кластер](https://yandex.cloud/ru/docs/glossary/cluster) - Кластер — это группа серверов, объединенных с помощью коммуникационных каналов для совместного решения информационно-вычислительных задач. Для пользователя кластер выступает единой системой, независимо от своей структуры и состава. Каждый кластер состоит из одного или нескольких хостов БД — виртуальных машин с развернутыми серверами СУБД.

### Структура
```bash
mkdir -p modules/mysql-cluster
mkdir -p modules/mysql-db-user
touch modules/mysql-cluster/{main.tf,variables.tf,outputs.tf}
yudzhi@yudzhi-MacBookPro:~/YuDzhi/DevOps/Projects/netology/ter_hw-04/src$ touch modules/mysql-db-user/{main.tf,variables.tf,outputs.tf}

```

### Модуль кластера: `modules/mysql-cluster/variables.tf`
#### INPUTS
- `HA = bool`
- `cluster_name = String`
- `network_id = String`
- [`environment`](https://yandex.cloud/ru/docs/managed-mysql/operations/cluster-create) — окружение: `PRESTABLE` или `PRODUCTION`

#### Нюанс 1. Какой environment выбирать?

На стоимость никак не влияет.

[`PRODUCTION`](https://yandex.cloud/ru/docs/managed-mysql/api-ref/Cluster/create) : Environment for stable versions of your apps.
A conservative update policy is in effect: only bug fixes are applied during regular maintenance.

PRESTABLE: Environment for testing, including the Managed Service for MySQL itself.
This environment gets new features, improvements, and bug fixes in the first place, compared to the production environment.
However, not every update ensures backward compatibility.

Let it be Prestable

Можно добавить ещё проверку введённого значения:

```hcl
variable "environment" {
  type        = string
  default     = "PRESTABLE"
  description = "Cluster environment: PRESTABLE or PRODUCTION"

  validation {
    condition     = contains(["PRESTABLE", "PRODUCTION"], var.environment)
    error_message = "environment must be either PRESTABLE or PRODUCTION"
  }
}
```

#### Нюанс 2. Минимальная конфигурация (обновление 21.10.2026)

1. [Расчет стоимости использования Managed Service for MySQL®](https://yandex.cloud/ru/docs/managed-mysql/pricing#rules) учитывает:

- тип диска и размер хранилища;
- вычислительные ресурсы, выделенные хостам кластера;
- настройки и количество резервных копий;
- объем исходящего трафика из Yandex Cloud в интернет.

2. [Требуемые параметры](https://library.tf/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_cluster). Resources allocated to hosts of the MySQL cluster.

- `disk_size` (Number). Volume of the storage available to a MySQL host, in gigabytes.

- `disk_type_id` (String). Type of the storage of MySQL hosts.
  
- `resource_preset_id` (String). The ID of the preset for computational resources available to a MySQL host (CPU, memory etc.). For more information, see the official documentation.

3. `resource_preset_id` - [Классы хостов MySQL](https://yandex.cloud/ru/docs/managed-mysql/concepts/instance-types)

- Создание кластеров с гарантированной долей vCPU ниже 100% (b1, b2 или b3) больше недоступно.
- s2, s3, s4a, s4af — стандартные конфигурации, с соотношением количества гигабайт RAM к количеству vCPU 4:1.
- список доступных типов диска для s2, s3, m2, m3, c3: network-ssd, network-hdd, local-ssd, network-ssd-nonreplicated, network-ssd-io-m3

**Остальные `hdd` не поддерживают**

4. Минимально доступные конфигурации:

*   **Intel Cascade Lake (`s2`)**: `s2.micro` — 2 vCPU, 8 ГБ RAM, 100% vCPU.
*   **Intel Ice Lake (`s3`)**: `s3-c2-m8` — 2 vCPU, 8 ГБ RAM, 100% vCPU.
*   **AMD Zen 4 (`s4a`)**: `s4a-c2-m8` — 2 vCPU, 8 ГБ RAM, 100% vCPU.
*   **AMD Zen 4 HighFreq (`s4af`)**: `s4af-c2-m8` — 2 vCPU, 8 ГБ RAM, 100% vCPU.
*   **Intel Broadwell (`b2`)** — **недоступен для создания** (только для чтения существующих кластеров).

5. Стоимость для РФ:

| Платформа (класс) | vCPU (100%) | RAM (1 ГБ) | Расчёт часа (`2×vCPU + 8×RAM`) | Итого/час |
|---|---|---|---|---|
| **Intel Cascade Lake (`s2.micro`)** | 2,15 ₽ | 0,5879 ₽ | `2×2,15 + 8×0,5879` | **9,0032 ₽** |
| **Intel Ice Lake (`s3-c2-m8`)** | 1,93 ₽ | 0,53 ₽ | `2×1,93 + 8×0,53` | **8,10 ₽** |
| **AMD Zen 4 (`s4a-c2-m8`)** | 1,93 ₽ | 0,53 ₽ | `2×1,93 + 8×0,53` | **8,10 ₽** |
| **AMD Zen 4 HighFreq (`s4af-c2-m8`)** | 3,76 ₽ | 0,74 ₽ | `2×3,76 + 8×0,74` | **13,44 ₽** |

6. Стоимость хранилища (10 ГБ)

*   `network-hdd`: `10 × 0,0052 = 0,052 ₽/час`
*   `network-ssd`: `10 × 0,0218 = 0,218 ₽/час`

7. Итоговая стоимость часа (1 хост, 10 ГБ)

| Конфигурация | Вычисления | Хранилище | Итого/час |
|---|---|---|---|
| **`s3-c2-m8` + `network-hdd`** | 8,10 ₽ | 0,052 ₽ | **8,152 ₽** |
| `s2.micro` + `network-hdd` | 9,0032 ₽ | 0,052 ₽ | **9,0552 ₽** |
| `s4a-c2-m8` + `network-ssd` (вынужденно) | 8,10 ₽ | 0,218 ₽ | **8,318 ₽** |
| `s4af-c2-m8` + `network-ssd` | 13,44 ₽ | 0,218 ₽ | **13,658 ₽** |

**Самый дешёвый вариант — `s3-c2-m8` (Intel Ice Lake) + `network-hdd` — 8,152 ₽/час.** Он немного дешевле `s4a` (8,318 ₽/час), потому что `s4a` вынуждает использовать более дорогой SSD.

8. **`modules/mysql-cluster/variables.tf`:**

```hcl
variable "resource_preset_id" {
  type        = string
  default     = "s3-c2-m8"   # Intel Ice Lake, 2 vCPU 100%, 8 GB RAM
  description = "https://yandex.cloud/ru/docs/managed-mysql/concepts/instance-types"
}
```


9. Остановка кластера

`terraform destroy` 

При необходимости «заморозки» — остановить кластер (`yc managed-mysql cluster stop`), тогда тарифицируется только хранилище и бэкапы.

10. Ещё нюансы

- `yc managed-mysql resource-preset list` - проверка актуального списка пресетов
- **RAM 8 ГБ — минимальная**, даже пустой кластер стоит ~8 ₽/час.
- **Публичный IP** (`0,2766 ₽/IP×час`) 
- **Резервные копии** сверх размера хранилища тарифицируются (`0,00307 ₽/ГБ×час`). 

#### Нюанс 3. [Диски](https://yandex.cloud/ru/docs/managed-mysql/concepts/storage)

> Сетевые HDD-диски (`network-hdd`) — самый экономичный вариант для кластеров, не требовательных к скорости записи и чтения.

> Сетевые SSD-диски (`network-ssd`) — компромиссный вариант: медленнее, чем локальные SSD-диски, но, в отличие от них, обеспечивает сохранность данных при выходе из строя оборудования Yandex Cloud.

**Стоимость на ноябрь 2026**
|Диск|Стоимость|Единицы|
|----|---------|--------|
|Локальные SSD, стандартные хосты|	0,0198 ₽|ГБ × час|
|Нереплицируемые SSD|	0,0147 ₽ | ГБ × час|
|Сетевые HDD|	0,0052 ₽ | ГБ × час|
|Сетевые SSD| 0,0218 ₽ | ГБ × час|

```hcl
variable "disk_type_id" {
  type        = string
  default     = "network-hdd"
  description = "Disk type (network-hdd, network-ssd): https://yandex.cloud/ru/docs/managed-mysql/concepts/storage"

  validation {
    condition     = contains(["network-hdd", "network-ssd", "network-ssd-nonreplicated", "network-ssd-io-m3", "local-ssd"], var.disk_type_id)
    error_message = "disk_type_id must be either network-hdd or network-ssd"
  }
}

variable "disk_size" {
  type        = number
  default     = 10
  description = "Host disk size in GB https://yandex.cloud/ru/docs/managed-mysql/concepts/storage"
}
```

#### `mysql-cluster/variables.tf` и другие нюансы

- зону оставим `ru-central1-d` - пусть весь проект будет в ней.
- `mysql_version` - 5.7 уже устаревает, 8.4 ещё не везде поддерживается, let it be 8.0

```hcl
variable "cluster_name" {
  type        = string
  description = "Name of the MySQL cluster"
}

variable "network_id" {
  type        = string
  description = "The VPC Network ID of subnets which resource attached to"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for cluster hosts (must belong to network_id)"
}

variable "zone" {
  type        = string
  default     = "ru-central1-d"
  description = "Availability zone for hosts"
}

variable "ha" {
  type        = bool
  default     = true
  description = "If true, create 2 hosts (HA); if false, create 1 host"
}

variable "mysql_version" {
  type        = string
  default     = "8.0"
  description = "Version of the MySQL cluster: 5.7, 8.0, 8.4"
}

```

### Модуль кластера: `modules/mysql-cluster/main.tf`

**Что нужно?** 

Создать в `yandex_mdb_mysql_cluster` один или два блока `host` в зависимости от переменной `ha`, причём так, чтобы при изменении `ha` Terraform не пересоздавал уже существующие хосты, а только добавлял/удалял нужные


```hcl
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

locals {
  host_count = var.ha ? 2 : 1
  hosts = {
    for i in range(local.host_count) : "host-${i + 1}" => {
      zone      = var.zone
      subnet_id = var.subnet_id
    }
  }
}

resource "yandex_mdb_mysql_cluster" "this" {
  name        = var.cluster_name
  environment = var.environment
  network_id  = var.network_id
  version     = var.mysql_version

  resources {
    resource_preset_id = var.resource_preset_id
    disk_type_id       = var.disk_type_id
    disk_size          = var.disk_size
  }

  dynamic "host" {
    for_each = local.hosts
    content {
      zone      = host.value.zone
      subnet_id = host.value.subnet_id
      name      = host.key
    }
  }
}
```

#### `HA` и блок `locals`. Сколько хостов нужно?

Посчитаем хосты: `local.host_count = var.ha ? 2 : 1` —  тернарный оператор.

`if true => host_count = 2, if false => host_count = 1`

#### `hosts` и `dynamic-блок`. Создаём хосты

У `yandex_mdb_mysql_cluster` хосты — это вложенные блоки, а не отдельные ресурсы. `count/for_each` на ресурсе создают несколько кластеров, а не несколько хостов внутри одного кластера. 

Можно прописывать вручную, но для динамического создания существует dynamic-блок — он генерирует вложенные блоки по коллекции.

Будем создавать коллекцию map `hosts`. Нужны параметры `zone`, `subnet_id`, ключи-имена хостам зададим семантические, а не цифры, чтобы нумерация не съезжала и не пересоздавать лишний раз ничего

```hcl
hosts = {
  for i in range(local.host_count) : "host-${i + 1}" => {
    zone      = var.zone
    subnet_id = var.subnet_id
  }
}
```

[host](https://library.tf/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_cluster) [Block]. A host of the MySQL cluster.

- `assign_public_ip` (Bool). Sets whether the host should get a public IP address. It can be changed on the fly only when name is set.
- `backup_priority` (Number). Host backup priority. Value is between 0 and 100, default is 0.
- `fqdn` (Read-Only) (String). The fully qualified domain name of the host.
- `name` (String). Host state name. It should be set for all hosts or unset for all hosts. This field can be used by another host, to select which host will be its replication source. Please refer to replication_source_name parameter.
- `priority` (Number). Host master promotion priority. Value is between 0 and 100, default is 0.
- `replication_source` (Read-Only) (String). Host replication source (fqdn), when replication_source is empty then host is in HA group.
- `replication_source_name` (String). Host replication source name points to host's name from which this host should replicate. When not set then host in HA group. It works only when name is set.
- `subnet_id` (String). The ID of the subnet, to which the host belongs. The subnet must be a part of the network to which the cluster belongs.
- `zone` (Required)(String). The availability zone where resource is located. If it is not provided, the default provider zone will be used.

```hcl
dynamic "host" {
  for_each = local.hosts
  content {
    zone      = host.value.zone
    subnet_id = host.value.subnet_id
    name      = host.key
  }
}
```

`dynamic "host"` с `for_each = local.hosts` генерирует вложенные блоки `host` в ресурсе кластера — по одному на элемент map. В `content` используются `host.key` (имя хоста "host-1", "host-2") и `host.value.zone`/`host.value.subnet_id`.

Внутри `content` переменная цикла называется по имени блока — `host`, а не `each`. Это отличается от for_each у ресурса, где используется `each.key` / `each.value`. В `dynamic` — `<имя_блока>.key` / `<имя_блока>.value`.

#### Модуль кластера: `modules/mysql-cluster/outputs.tf`

```hcl
output "cluster_id" {
  description = "ID of the created MySQL cluster"
  value       = yandex_mdb_mysql_cluster.this.id
}

output "cluster_name" {
  description = "Name of the created MySQL cluster"
  value       = yandex_mdb_mysql_cluster.this.name
}
```

### Модуль БД и пользователя 
#### `modules/mysql-db-user/variables.tf`

```hcl
variable "cluster_id" {
  type        = string
  description = "ID of the existing MySQL cluster"
}

variable "database_name" {
  type        = string
  description = "Name of the database to create"
}

variable "user_name" {
  type        = string
  description = "Name of the user to create"
}

variable "user_password" {
  type        = string
  sensitive   = true
  description = "Password for the user"
}
```

#### Модуль БД и пользователя: `modules/mysql-db-user/main.tf`

```hcl
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

resource "yandex_mdb_mysql_database" "this" {
  cluster_id = var.cluster_id
  name       = var.database_name
}

resource "yandex_mdb_mysql_user" "this" {
  cluster_id = var.cluster_id
  name       = var.user_name
  password   = var.user_password

  permission {
    database_name = yandex_mdb_mysql_database.this.name
    roles         = ["ALL"]
  }
}
```

[permission](https://library.tf/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_user) [Block]. Set of permissions granted to the user.

- `database_name` (Required)(String). The name of the database that the permission grants access to.
- `roles` (List Of String). List user's roles in the database. Allowed roles: `ALL`,`ALTER`,`ALTER_ROUTINE`,`CREATE`,`CREATE_ROUTINE`,`CREATE_TEMPORARY_TABLES`, `CREATE_VIEW`,`DELETE`,`DROP`,`EVENT`,`EXECUTE`,`INDEX`,`INSERT`,`LOCK_TABLES`,`SELECT`,`SHOW_VIEW`,`TRIGGER`,`UPDATE`,`REFERENCES`.

#### Модуль БД и пользователя: `modules/mysql-db-user/outputs.tf`

```hcl
output "database_name" {
  value = yandex_mdb_mysql_database.this.name
}

output "user_name" {
  value = yandex_mdb_mysql_user.this.name
}
```

### Вызов модулей в корневом `mysql.tf`

```hcl
module "mysql_cluster" {
  source = "./modules/mysql-cluster"

  cluster_name = "example"
  network_id   = module.vpc_dev.vpc.network_id
  subnet_id    = module.vpc_dev.vpc.subnet_ids[0]
  zone         = module.vpc_dev.vpc.subnet_zones[0]
  ha           = false   # сначала один хост
}

module "mysql_db_user" {
  source = "./modules/mysql-db-user"

  cluster_id    = module.mysql_cluster.cluster_id
  database_name = "test"
  user_name     = "app"
  user_password = var.mysql_app_password
}
```

#### Пароль для mysql_db_user

`src/variables.tf`:

```hcl
variable "mysql_app_password" {
  type        = string
  sensitive   = true
  description = "Password for MySQL user app"
}
```

`personal.auto.tfvars`:

```hcl
mysql_app_password = "YourStrongPassword123!"
```

### Проверка
#### Один хост `ha = false'
```bash
terraform init -upgrade
terraform validate
terraform plan
terraform apply
```

#### Два хоста `ha = true`

```bash
terraform plan
terraform apply

yc managed-mysql cluster list
yc managed-mysql host list --cluster-name example
yc managed-mysql database list --cluster-name example
yc managed-mysql user list --cluster-name example

terraform destroy
```

</details>

<details>
<summary>Скриншоты</summary>

1. [Single host terraform plan 01](https://disk.yandex.ru/i/wirro7rgJfYBOw)

2. [Single host terraform plan 02](https://disk.yandex.ru/i/wcGG6FfgAl7CoA)

3. [Single host cluster&host lists](https://disk.yandex.ru/i/N3Vxg_xnGAiaNA)

4. [Two hosts plan& quota limit](https://disk.yandex.ru/d/u3-e_cva0IC5og)

Второй хост создать не удалось из-за квоты. Но в плане он присутствует. 

5. [Infrastructure map](https://disk.yandex.ru/i/hYFMeYLZ_nhBJQ)

6. [db & user lists](https://disk.yandex.ru/i/rDiHGltuQbrwZw)

7. [Console & pricing](https://disk.yandex.ru/i/votktrc54M9hNw)
</details>