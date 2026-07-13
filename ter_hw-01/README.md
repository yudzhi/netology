# Домашнее задание к занятию «Введение в Terraform»

[Код в fork-репозитории](https://github.com/yudzhi/ter-homeworks/tree/main/01/src)

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

```bash
terraform apply
cat terraform.tfstate
```
**Ответ:** `"result": "ybRAieAQAZF2cb6g"`

### Шаг 4. Поиск ошибок в `main.tf` и запуск

[library.tf](https://library.tf/providers/kreuzwerker/docker/latest/docs/resources/container)

```bash
terraform validate
╷
│ Error: Missing name for resource
│ 
│   on main.tf line 23, in resource "docker_image":
│   23: resource "docker_image" {
│ 
│ All resource blocks must have 2 labels (type, name).
╵
╷
│ Error: Invalid resource name
│ 
│   on main.tf line 28, in resource "docker_container" "1nginx":
│   28: resource "docker_container" "1nginx" {
│ 
│ A name must start with a letter or underscore and may contain only letters, digits, underscores, and dashes.
```
#### 1. Нет имени ресурса `resource "docker_image" {`
Имя берём из обращения в блоке docker_container: docker_image.**nginx**.image_id

```hcl
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}
```

#### 2. Некорректное имя ресурса "1nginx" (не может начинаться с цифры)

```hcl
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "example_${random_password.random_string_FAKE.resulT}"
```

#### 3. Неправильное обращение к ресурсу `resource "random_password" "random_string"`

```hcl
  name = "example_${random_password.random_string.result}"
```

#### 4. Неправильное имя атрибута `result`
`resulT` --> `result`

### Шаг 5. Выполнение кода

`main.tf' (исправленный фрагмент):
```hcl
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "example_${random_password.random_string.result}"

  ports {
    internal = 80
    external = 9090
  }
}
```

```bash
docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                  NAMES
eaa872feeef7   ec4ed8b5299e   "/docker-entrypoint.…"   20 seconds ago   Up 19 seconds   0.0.0.0:9090->80/tcp   example_ybRAieAQAZF2cb6g
```
<details>
  <summary>Скриншоты</summary>

![docker_ps](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/5HJGG69-jXccHw)
</details>

### Шаг 6. Меняем имя контейнера на `hello_world`

```hcl
resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  #name  = "example_${random_password.random_string.result}"
  name = "hello_world"
```

**terraform apply -auto-approve**

Не дожидается подтверждения и выполняет инструкции сразу.

Опасность: 
- не видно заранее плана и нет возможности предварительно отследить ошибку конфигурации
- легко всё сломать, если нужные ресурсы уничтожатся без предупреждения

Зачем нужно?
- там, где важна скорость и нет тестировщика, нажимающего тысячу раз `yes`
- там, где не критична ошибка
- для автоматизации

<details>
  <summary>Скриншоты</summary>

![docker_ps_helloworld](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/dyKmBfeB3GNRAQ)
</details>

### Шаг 7. Уничтожаем ресурсы и проверяем state-файл

```bash
terraform destroy
docker ps -a
```
Контейнер установлен и удалён. 

`terraform.tfstate`
```hcl
{
  "version": 4,
  "terraform_version": "1.12.2",
  "serial": 11,
  "lineage": "45c18f52-91f3-27a2-a630-965d38270a1d",
  "outputs": {},
  "resources": [],
  "check_results": null
}
```
<details>
  <summary>Скриншоты</summary>

![terraform_destroy](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/r8VE0avAoMLBnQ)
</details>

### Шаг 8. Почему не удалился образ nginx:latest?

В ресурсе `docker_image` установлен параметр
```hcl
keep_locally = true
```

"keep_locally (Boolean) If true, then the Docker image won't be deleted on destroy operation. If this is false, it will delete the image from the docker local storage on destroy operation."

## Задание 2. Развертывание ВМ в Yandex Cloud и удаленное управление Docker через Terraform

![mysql-env_VM](https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/i/F2O8suESaeCBCg)
