# Домашнее задание к занятию 5. «Практическое применение Docker»
## Задача 0
Docker Compose version v5.1.4

<details>
  <summary>Скриншоты</summary>
  
![Проверка версии Docker Compose](https://s112klg.storage.yandex.net/rdisk/ca946812feb7846d128e82d23fe549e4e1a54871e1b8a0a7babf120726a89e95/6a1eef30/iFwHyHfHYV6LpWmkyGg1uIO-fm5aeK13JdPsJiw1_kJAb-I8Xu5xaLqOQXZOjv0MC-Q5_ZCs3us3NC251j8y6A==?uid=22194168&filename=virt-04_Qst0_1.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=178483&hid=21a90af2cefed16679f23548347787c8&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=60b84ea97f9d2f409989659b9757334a&ts=6534685362c00&s=ccad3cb79568dea83dae039d6402d5b1c0f8a567a69c37380f3e869b5a1f0c7c&pb=U2FsdGVkX1_rD1wCvvHAhdzegMnbLfTSkRsLL9TlIDdkeBFNrJjq6GQet4u6z0kxiWr6lAGLPiSttEY1WR5i1S_RW6BMPAfTvj8HqLiP0kY)
</details>

<details>
  <summary>Ход выполнения</summary>

**0. Проверка версии Docker Compose**
```bash
sudo usermod -aG docker $USER
newgrp docker

docker-compose --version
Command 'docker-compose' not found, but can be installed with:
sudo snap install docker          # version 29.3.1, or
sudo apt  install docker-compose  # version 1.29.2-1
See 'snap info docker' for additional versions.

docker compose version
Docker Compose version v5.1.4
```
</details>

---

## Задача 1.3

**1. Запуск MySQL в Docker-контейнере**
```bash
# Запустить MySQL контейнер с параметрами для приложения
docker run -d \
  --name mysql-local \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=example \
  -e MYSQL_USER=app \
  -e MYSQL_PASSWORD=very_strong \
  mysql:8.0
```

### Источник параметров: файл  `main.py`

| Параметр Docker run | Значение | Откуда взято |
|---------------------|----------|--------------|
| `MYSQL_ROOT_PASSWORD=rootpass` | `rootpass` | **Придумано для локального запуска** (не из .env) |
| `MYSQL_DATABASE=example` | `example` | Из `main.py` (значение по умолчанию) |
| `MYSQL_USER=app` | `app` | Из `main.py` (значение по умолчанию) |
| `MYSQL_PASSWORD=very_strong` | `very_strong` | Из `main.py` (значение по умолчанию) |

```bash
--name mysql-local
```
Придумано для локального запуска  
Даёт контейнеру понятное имя, чтобы потом можно было обращаться: `docker stop mysql-local`

```bash
-p 3306:3306
```
Port mapping. Стандартный порт MySQL  
Пробрасывает порт 3306 из контейнера на хост (чтобы приложение на хосте могло подключиться к `localhost:3306`)

```bash
-e MYSQL_ROOT_PASSWORD=rootpass
```
**Придумано для локального запуска** (простой пароль для тестирования)  
**Почему не из `.env`:** В `.env` указан `MYSQL_ROOT_PASSWORD="YtReWq4321"`, но:
- Для локального тестирования не нужен сложный пароль
- `main.py` НЕ использует root-пользователя, он использует пользователя `app`

```bash
-e MYSQL_DATABASE=example
```
**Откуда:** Из `main.py` (значение по умолчанию)
**Почему `example`, а не `virtd` (из .env)?**
- В Docker-сборке мы использовали `.env` с `virtd`, потому что меняли переменные в `compose.yaml`
- Для локального запуска мы НЕ меняем переменные, приложение берёт `example` по умолчанию
- Так проще тестировать - не нужно экспортировать `DB_NAME=virtd`


```python
# --- 1. Конфигурация ---
# Считываем конфигурацию БД из переменных окружения
db_host = os.environ.get('DB_HOST', '127.0.0.1')
db_user = os.environ.get('DB_USER', 'app')
db_password = os.environ.get('DB_PASSWORD', 'very_strong')
db_name = os.environ.get('DB_NAME', 'example')
```

```bash
mysql:8.0
```
**Откуда:** Официальный образ MySQL версии 8.0 (используется и в Docker-сборке)


Файл `.env` в проекте содержит:
```bash
MYSQL_ROOT_PASSWORD="YtReWq4321"
MYSQL_DATABASE="virtd"
MYSQL_USER="app"
MYSQL_PASSWORD="QwErTy1234"
```

**Но для локального запуска использую значения по умолчанию из `main.py`**, потому что:
1. Не нужно экспортировать дополнительные переменные
2. Приложение само подключится с дефолтными значениями
3. Простота тестирования

<details>
  <summary>Ход выполнения</summary>

**Запуск MySQL в Docker-контейнере**
```bash
# Запустить MySQL контейнер с параметрами для приложения
docker run -d \
  --name mysql-local \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=example \
  -e MYSQL_USER=app \
  -e MYSQL_PASSWORD=very_strong \
  mysql:8.0
```
</details>
