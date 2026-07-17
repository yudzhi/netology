# Домашнее задание к занятию «Основы Terraform. Yandex Cloud»
## Задание 1

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

```bash
│ Error: Error while requesting API to create instance: client-request-id = c439ec24-1893-4c12-950c-1d8c82c9fca0 client-trace-id = efbdaa85-7eb2-4044-9b33-4feced8501d5 rpc error: code = InvalidArgument desc = the specified core fraction is not available on platform "standard-v3"; allowed core fractions: 20, 50, 100
```

Уровень производительности core fraction 5 доступен только для standard-v1, v2. Выберем минимальное 20%.

Платформа | Процессор | Макс. кол-во ядер (vCPU)</br> на виртуальной машине | Базовая тактовая</br> частота процессора, ГГц
--- | --- | --- | ---
Intel Broadwell</br>(`standard-v1`) | Intel® Xeon® Processor E5-2660 v4 | 32 | 2.00
Intel Cascade Lake</br>(`standard-v2`) | Intel® Xeon® Gold 6230 | 80 | 2.10
Intel Ice Lake</br>(`standard-v3`) | Intel® Xeon® Gold 6338 | 96 | 2.00
AMD Zen 3</br>(`amd-v1`)^1^ | AMD EPYC™ 7713 | 128 | 2.00
AMD Zen 4</br>(`standard-v4a`) | AMD EPYC™ 9654 | 288 | 2.40

```hcl
  platform_id = "standard-v3" # standart → standard (опечатка)
  resources {
    cores         = 1
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
</details>

<details>
  <summary>Скриншоты</summary>

![service_account_created](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/TucFQCP4Y0X3sQ)
</details>
