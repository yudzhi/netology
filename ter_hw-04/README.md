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