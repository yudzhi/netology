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

#### 2. В main.tf опечатка
```hcl
platform_id = "standard-v4"  # standart → standard (опечатка)
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
