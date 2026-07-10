# Домашнее задание к занятию «Введение в Terraform»

## Задание 0. Установка Terraform

```bash
Terraform v1.15.7
on linux_amd64
+ provider registry.terraform.io/yandex-cloud/yandex v0.213.0

Docker version 29.6.1, build 8900f1d
```
<details>
  <summary>Скриншоты</summary>

![Terraform-version](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/F7iukzgm3n5j2A)

</details>

## Задание 1. 
### Шаг 1. Установка зависимостей Terraform (включая Docker-провайдер)

#### Несовместимость версий Terraform

- Установлен Terraform v1.15.7
- В файле `main.tf` указана версия: `required_version = ">1.12.0"`
- Terraform версия 1.15.7 не поддерживается этим ограничением

**Решение - менеджер версий tfenv:**

```bash
tfenv use 1.12.2
tfenv: Switching default version to v1.12.2
tfenv: Default version (when not overridden by .terraform-version or TFENV_TERRAFORM_VERSION) is now: 1.12.2
```
<details>
  <summary>Варианты решения:</summary>

**Вариант 1: Исправить версию в main.tf**

```hcl
required_version = ">= 1.12.0, < 2.0.0"  # Поддержка всех версий 1.х.х
```
*С одной стороны, для random_password и docker версия Terraform не критична и код должен быть полностью совместим.
В учебных целях предположим, что `main.tf` менять нельзя*

**Вариант 2: Установить несколько версий Terraform через менеджер версий tfenv** - *выбран из интереса*

```bash
# Установка tfenv
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Установка версии 1.12.2: 
- из зеркала скачан архив `terraform_1.12.2_linux_amd64.zip`
- создаём директорию, где tfenv по умолчанию хранит установленные версии Terraform
- распаковываем туда архив

```bash
mkdir -p ~/.tfenv/versions/1.12.2
unzip terraform_1.12.2_linux_amd64.zip -d ~/.tfenv/versions/1.12.2
Archive:  terraform_1.12.2_linux_amd64.zip
  inflating: /home/yudzhi/.tfenv/versions/1.12.2/LICENSE.txt  
  inflating: /home/yudzhi/.tfenv/versions/1.12.2/terraform  
```
- Активируем установленную версию

```bash
# Переключение на версию 1.12.2 для директории src
tfenv use 1.12.2

# Проверить версию
terraform version
Terraform v1.12.2
on linux_amd64
```

**Вариант 3: Использовать Docker-версию Terraform** - *пока нет*

```bash
# Запуск Terraform 1.12.9 в Docker
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  hashicorp/terraform:1.12.9 \
  init
```

</details>

#### Установка зависимостей:

```bash
terraform init
```


<details>
  <summary>Скриншоты</summary>

![Unsupported_terraform_version](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/y-9JtA8lRHMXug)

![tfenv](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/l3qxqbVPlQQvvQ)

![terraform_init](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/t8sNZSmxvi0xCg)

</details>

### Шаг 2. `.gitignore` и место для секретов

```text
# own secret vars store.
personal.auto.tfvars
```

Личную секретную информацию (логины, пароли, ключи, токены) допустимо сохранять в файле `personal.auto.tfvars`.

### Шаг 3. Первый запуск кода и поиск пароля в state-файле
