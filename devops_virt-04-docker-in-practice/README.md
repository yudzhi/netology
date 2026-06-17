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

## Задача 1

### 1.1
[Fork репозитория](https://github.com/yudzhi/shvirtd-example-python)

### 1.2
[Dockerfile.python](https://github.com/yudzhi/shvirtd-example-python/blob/main/Dockerfile.python)

[.dockerignore](https://github.com/yudzhi/shvirtd-example-python/blob/main/.dockerignore)

### 1.3 Запуск приложения без Docker с помощью venv

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
<details>
  <summary>Скриншоты</summary>

![Запуск и проверка MySQL](https://3.downloader.disk.yandex.ru/disk/848fd76a41bb46527ad3121b3c3a22136c283e87e77ac02f24b43a357ddc2bcd/6a2df0f2/iFwHyHfHYV6LpWmkyGg1uAKWEW1fIgkyI0Czcl-K-st8XaACJoFaGG9-ewbYZ8DwyEqc_mDxx9kFzk0KAjUbYw%3D%3D?uid=22194168&filename=04-docker_1-3_1.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=252597&hid=1139de45f76da415ee38620786db13e2&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=dc813393e4595f7e036200c7efd39c19)

![venv and requirements](https://4.downloader.disk.yandex.ru/disk/79961d68375216a22317e61d13fed5efe14e5087fc149a6c984155d81a380f74/6a2df404/iFwHyHfHYV6LpWmkyGg1uCBIWiLbUpImSbh552Tj2sTfzL5Hn1mgdawrlyPAEs0bwPv0hi55G4bmQuova1wmUQ%3D%3D?uid=22194168&filename=04-docker_1-3_2.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=243268&hid=f3b1e55f67b5c0d021ccf7875512e3cd&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=498d625137f170250f408391585aaebd)

![App startup](https://1.downloader.disk.yandex.ru/disk/fc4abba676bdbaff6aabde11c1bdf5b10c3c38e623c707caa9eec9d71196f348/6a2e0944/iFwHyHfHYV6LpWmkyGg1uCUOE6QfDhwnVlpOWKH8tiGIF6FHNw7yVaA_fSh8fovWTaJMhzFT2fcYMRRECW41cg%3D%3D?uid=22194168&filename=04-docker_1-3_3.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=66212&hid=0a36dabbe643b2c70b869a387df9476b&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=056a7635b49578c5acbd0306de3cc138)

![Second Terminal](https://3.downloader.disk.yandex.ru/disk/3e6708afdc051c437724fc560593fdc3572efd963829ffa153fa930542d9c82f/6a2e09db/iFwHyHfHYV6LpWmkyGg1uA8RiyQnsNbcAeI3g-dClgci-reJskhLZP32_dj4iDn8Q-Rq__Yol4O6uJm8axOwHg%3D%3D?uid=22194168&filename=04-docker_1-3_4.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=48625&hid=164cf9c4deb1a70ea4eb228e36185b7e&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=f996ec511a807862a6b9e5bcbdec77ba)

</details>
<details>
  <summary>Ход выполнения</summary>

**1. Запуск MySQL. Источник параметров: файл  `main.py`**

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

---

**2. Проверка работы MySQL**
- Проверить, что контейнер запустился
```bash
docker ps
```
- Проверить логи (убедиться, что БД инициализировалась)
```bash
docker logs mysql-local
```
- Подключиться к MySQL и проверить базу данных
```bash
docker exec -it mysql-local mysql -uroot -prootpass -e "SHOW DATABASES;"
```

---

**3. Создание виртуального окружения**
```bash
# Перейти в папку проекта
cd ~/projects/shvirtd-example-python

# Создать виртуальное окружение
python3 -m venv venv

# Активировать виртуальное окружение
source venv/bin/activate

# Убедиться, что активировалось (должна появиться приставка (venv))
which python
```

---

**4. Установка зависимостей**
```bash
# Убедиться, что pip обновлён
pip install --upgrade pip

# Установить зависимости из requirements.txt
pip install -r requirements.txt
```
Содержимое файла 'requirements.txt':
```python
 fastapi==0.104.1
uvicorn[standard]==0.24.0
mysql-connector-python==8.2.0
```

---

**5. Настройка переменных окружения для приложения и запуск**
- Что считывает 'main.py':
```python
# --- 1. Конфигурация ---
# Считываем конфигурацию БД из переменных окружения
db_host = os.environ.get('DB_HOST', '127.0.0.1')
db_user = os.environ.get('DB_USER', 'app')
db_password = os.environ.get('DB_PASSWORD', 'very_strong')
db_name = os.environ.get('DB_NAME', 'example')
```
- Экспорт
```bash
export DB_HOST='127.0.0.1'
export DB_USER='app'
export DB_PASSWORD='very_strong'
export DB_NAME='example'
```
- Проверка установленных переменных
```bash
env | grep DB_
```
- Запуск
```bash
uvicorn main:app --host 0.0.0.0 --port 5000 --reload
```

**6. Проверка работы**
Во новом терминале:
```bash
curl http://localhost:5000
"TIME: 2026-06-13 16:23:55, IP: похоже, что вы направляете запрос в неверный порт(например curl http://127.0.0.1:5000). Правильное выполнение задания - отправить запрос в порт 8090."

# Проверить эндпоинт /requests
curl http://localhost:5000/requests

# Проверить отладочный эндпоинт
curl http://localhost:5000/debug
```

**7. Остановка приложения и очистка**
- Остановка uvicorn - Ctrl+C в терминале с сервером
- Деактивация виртуального окружения
```bash
deactivate
```

- Остановка и удаление контейнера MySQL
```bash
docker stop mysql-local
docker rm mysql-local
```
</details>

### 1.4 Добавление управления названием таблицы через ENV переменную

**1. Изучение 'main.py':**
```python
def ensure_table_exists():
    """Создает таблицу requests если она не существует"""
    try:
        with get_db_connection() as db:
            cursor = db.cursor()
            create_table_query = f"""
            CREATE TABLE IF NOT EXISTS {db_name}.requests (
                id INT AUTO_INCREMENT PRIMARY KEY,
                request_date DATETIME,
                request_ip VARCHAR(255)
            )
            """
            cursor.execute(create_table_query)
            db.commit()
            cursor.close()
            return True
    except mysql.connector.Error as err:
        print(f"Ошибка при создании таблицы: {err}")
        return False
```
В коде 'main.py' название таблицы 'requests' сейчас жёстко зашито. Нужно добавить переменную, чтобы можно было менять название таблицы.
Зададим переменную окружения 'TABLE_NAME'.

<details>
  <summary>Скриншоты</summary>

![Terminal 1](https://2.downloader.disk.yandex.ru/disk/8e2f86285e65faf4c72a001848041758b7d8cbb06a5477cdd54a20f3b06ae096/6a2ecccc/iFwHyHfHYV6LpWmkyGg1uAJnXot7OUaTTFFqvxG3LUU2yEaPDu36ioMfVNYtoaAu-H9TGi64Dj9XPQBpXvVkMw%3D%3D?uid=22194168&filename=04-docker_1-4_1.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=147235&hid=144e3fb8493a9728dc47b983c1d82a91&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=6a3983ce027bff2133adc04a1bf29f93)

![Terminal 2](https://3.downloader.disk.yandex.ru/disk/18c35a43ad319a01fb23e42c72e95ca774b3e263f1abbb3172d003b23d72fa72/6a2ecd24/iFwHyHfHYV6LpWmkyGg1uLYxpE_p0Mu1df-rErJpBb1Sbna7iYpJn2L8e88J4dXe3aCsSns_FfVS-9fpGgir-g%3D%3D?uid=22194168&filename=04-docker_1-4_2.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=104378&hid=94a2a5b34533d3280fee671a0b999f5c&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=c7b9e4f3370490fd29e5e934cdf15d36)

![Terminal 2 \requests](https://3.downloader.disk.yandex.ru/disk/efcd268533de4fb3e746abebb3881277a2e80b79a5126b8bd4970c50d6e70147/6a2ecf55/iFwHyHfHYV6LpWmkyGg1uFJDaP7Y-2sdNhG9C5-sb9b8o2HunHvOe8-GIU-6evw9KbpoRbjA5oFowCatt1KNUw%3D%3D?uid=22194168&filename=04-docker_1-4_3.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=12081&hid=38b776a097e0dcf479ab01cadb21a562&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=09c955a11d13d5215a70fc6e59f55c44)
</details>

<details>
  <summary>Ход выполнения</summary>

**2. Добавление переменной окружения 'TABLE_NAME' в блок с конфигурацией 'main.py':**
```python
table_name = os.environ.get('TABLE_NAME', 'requests')
```

**3. Изменение функции ensure_table_exists()**
```python
create_table_query = f"""
CREATE TABLE IF NOT EXISTS {db_name}.{table_name} (
    id INT AUTO_INCREMENT PRIMARY KEY,
    request_date DATETIME,
    request_ip VARCHAR(255)
)
"""
```

**4. Изменение функции index()**
```python
query = "INSERT INTO {table_name} (request_date, request_ip) VALUES (%s, %s)"
```

**5. Изменение функции get_requests()**
```python
query = f"SELECT id, request_date, request_ip FROM {table_name} ORDER BY id DESC LIMIT 50"
```

**6. Тестирование**
- Проверка, что переменная table_name определена
```bash
grep "table_name =" main.py                                                                                                                                                                          # table_name = os.environ.get('TABLE_NAME', 'requests')  # <-- НОВАЯ СТРОКА
```

- Запуск MySQL
```bash
docker run -d \
  --name mysql-local \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=example \
  -e MYSQL_USER=app \
  -e MYSQL_PASSWORD=very_strong \
  mysql:8.0
```

- Активация виртуального окружения
```bash
cd ~/projects/shvirtd-example-python
source venv/bin/activate
```

- Новые переменные окружения:
```bash
export DB_HOST='127.0.0.1'
export DB_USER='app'
export DB_PASSWORD='very_strong'
export DB_NAME='example'
export TABLE_NAME='my_logs'   # <-- НОВАЯ ПЕРЕМЕННАЯ, таблица будет называться my_logs
```
**ИЛИ Файл .env для локального запуска:**
```bash
cat > .env.local << 'EOF'
DB_HOST=127.0.0.1
DB_USER=app
DB_PASSWORD=very_strong
DB_NAME=example
EOF
```

- Запуск:
```bash
export $(cat .env.local | xargs)
uvicorn main:app --host 0.0.0.0 --port 5000 --reload
```

- Второй терминал:
```bash
# Отправить запрос - создаст таблицу my_logs
curl http://localhost:5000

# Проверить, что таблица создалась с новым именем
docker exec mysql-local mysql -uroot -prootpass -e "USE example; SHOW TABLES;"

#Tables_in_example
#my_logs 
```

- Проверка со значением по умолчанию:
```bash
# Терминал 1:
# Перезапустить uvicorn (Ctrl+C и снова uvicorn main:app...)
# Отключить TABLE_NAME - должна использоваться таблица 'requests'
unset TABLE_NAME

# Терминал 2:
# Отправить запрос
curl http://localhost:5000

# Проверить таблицы
docker exec mysql-local mysql -uroot -prootpass -e "USE example; SHOW TABLES;"

# Tables_in_example
# my_logs
# requests 
```

UPD:
Исправлено main.py get_requests(), теперь правильный ответ:
```bash
yudzhi@DESKTOP-5VK4TT0:~/projects/shvirtd-example-python$ curl http://localhost:5000/requests
{"total_records":2,"records":[{"id":2,"request_date":"2026-06-14 14:42:35","request_ip":null},{"id":1,"request_date":"2026-06-14 14:35:31","request_ip":null}]}
```

- Очистка
```bash
# Остановить uvicorn (Ctrl+C)

# Деактивировать venv
deactivate

# Остановить и удалить MySQL
docker stop mysql-local
docker rm mysql-local
```
</details>

---

## Задача 2. Работа с Yandex Cloud Container Registry

### 2.1 Создать реестр (registry) с именем "test" в Yandex Cloud Container Registry

<details>
  <summary>Ход выполнения</summary>

**- Установка Yandex Cloud yc**
```bash
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash

# Yandex Cloud CLI 1.13.0 linux/amd64
# Скрипт установит CLI и добавит путь до исполняемого файла в переменную окружения PATH.
# yc PATH has been added to your '/home/yudzhi/.bashrc' profile                                                                                                                                                                                
# Перезапустить терминал
source ~/.bashrc

yc version
# Yandex Cloud CLI 1.13.0 linux/amd64
```

**- Аутентификация в Yandex Cloud**
```bash
yc init --username=ruthhieris@yandex.ru

# Проверка настройки профиля CLI:
yc config list
```

**- Docker version 29.5.3, build d1c06ef**
**- Создание реестра в Yandex Container Registry с именем 'test'**
```bash
yc container registry create --name test

done
id: crp***********
folder_id: b1g*******
name: test
status: ACTIVE
created_at: "2026-06-14T19:52:44.360Z"                                                                                                                                                     
```

**- Сохранение ID реестра**
```bash
# Получить ID реестра по имени
REGISTRY_ID=$(yc container registry get --name test --format json | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
echo $REGISTRY_ID
```
</details>

### 2.2 Настроить аутентификацию локального Docker в этом реестре
<details>
  <summary>Ход выполнения</summary>

**- Настройка Docker Credential Helper**

Настраивает Docker для автоматической аутентификации в Yandex Container Registry
```bash
yc container registry configure-docker

docker configured to use yc --profile "default" for authenticating "cr.yandex" container registries
Credential helper is configured in '/home/yudzhi/.docker/config.json'  
```

**- Проверка**
```bash
cat ~/.docker/config.json

{
"credHelpers": {
"container-registry.cloud.yandex.net": "yc",
"cr.cloud.yandex.net": "yc",
"cr.yandex": "yc"
},
"credsStore": "desktop.exe" 

yc container registry list 
```
</details>

### 2.3 Собрать и загрузить образ с Python-приложением из предыдущего задания

*!!! Пришлось перейти с Linux-машины на wsl*

| Где проблема? | В чём проблема?  |
|---------------------------------|-------------------------------|
| WSL/Docker Desktop	| По умолчанию создаёт мультиплатформенные образы для совместимости с разными архитектурами |
| BuildKit | Иногда создаёт мультиплатформенные образы по умолчанию |
| Yandex Cloud	| Поддерживает сканирование только образов с одним типом архитектуры |
| Решение	| Явно указать --platform linux/amd64 при сборке + отключить BuildKit |

```bash
# Собрать с отключённым BuildKit
DOCKER_BUILDKIT=0 docker build --platform linux/amd64 --no-cache -f Dockerfile.python -t cr.yandex/$REGISTRY_ID/python-app:latest .
```

<details>
  <summary>Ход выполнения</summary>

```bash
cd ~/projects/shvirtd-example-python

# Собрать образ
docker build -f Dockerfile.python -t cr.yandex/$REGISTRY_ID/python-app:latest .
```

**- Проверка, что образ создался**
```bash
docker images | grep cr.yandex
```

**- Загрузка образа в Yandex Container Registry**
```bash
docker push cr.yandex/$REGISTRY_ID/python-app:latest
```

**- Проверка, что образ появился в реестре**
```bash
yc container image list --registry-name test
```

**- Диагностика**
```bash
# ============================================
# 1. Удалить образы из Yandex Cloud Registry
# ============================================

# Удалить все образы в реестре через YC CLI
for id in $(yc container image list --registry-name test --format json | grep -o '"id": "[^"]*"' | cut -d'"' -f4); do
    echo "Deleting image from registry: $id"
    yc container image delete $id
done

# ============================================
# 2. Очистить локальные образы Docker
# ============================================

# Безопасное удаление (только образы cr.yandex)
docker images --format "{{.Repository}}:{{.Tag}}" | grep cr.yandex | xargs -r docker rmi -f
# Флаг -r означает "не выполнять, если нет аргументов"

# Или через ID
docker images --filter "reference=cr.yandex/*" -q | xargs -r docker rmi -f

# ============================================
# 3. Очистить кэш
# ============================================

docker builder prune -af
docker system prune -af

# ============================================
# 4. Пересобрать образ
# ============================================

REGISTRY_ID=$(yc container registry get --name test --format json | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)

# Собрать с отключённым BuildKit
DOCKER_BUILDKIT=0 docker build --platform linux/amd64 --no-cache -f Dockerfile.python -t cr.yandex/$REGISTRY_ID/python-app:latest .

# ============================================
# 5. Проверить, что образ собран для правильной платформы
# ============================================

docker inspect cr.yandex/$REGISTRY_ID/python-app:latest | grep -i architecture
# Должно быть: "Architecture": "amd64"

# ============================================
# 6. Загрузить образ
# ============================================

docker push cr.yandex/$REGISTRY_ID/python-app:latest

# ============================================
# 7. Сканировать
# ============================================

IMAGE_ID=$(yc container image list --registry-name test --format json | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
yc container image scan $IMAGE_ID
```
</details>

### 2.4 Просканировать образ на уязвимости
<details>
  <summary>Ход выполнения</summary>

**- Получить ID образа**
```bash
IMAGE_ID=$(yc container image list --registry-name test --format json | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
echo "Image ID: $IMAGE_ID"
```

**- Запуск сканирования**
```bash
yc container image scan $IMAGE_ID

# Проверить статус сканирования
yc container image list-scan-results --image-id $IMAGE_ID
```

**- ID результата сканирования**
```bash
SCAN_ID=$(yc container image list-scan-results --image-id $IMAGE_ID --format json | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
echo "Scan ID: $SCAN_ID"
```

</details>

### 2.5 Предоставить отчёт сканирования
[Файл отчёта сканирования](https://github.com/yudzhi/shvirtd-example-python/blob/main/vulnerability-report.json)

<details>
  <summary>Ход выполнения</summary>

**- Детальный отчёт об уязвимостях**
```bash
yc container image list-vulnerabilities --scan-result-id $SCAN_ID
```

**- Сохранение отчёта в файл**
```bash
yc container image list-vulnerabilities --scan-result-id $SCAN_ID --format json > vulnerability-report.json
```

**- Просмотр в удобном формате**
```bash
# Показать уязвимости по уровням серьезности
echo "=== CRITICAL ==="
cat vulnerability-report.json | grep -A5 '"severity": "CRITICAL"'

echo "=== HIGH ==="
cat vulnerability-report.json | grep -A5 '"severity": "HIGH"'

echo "=== MEDIUM ==="
cat vulnerability-report.json | grep -A5 '"severity": "MEDIUM"'

cat vulnerability-report.json
```

**- Очистка**
```bash
# Список всех образов
yc container image list --registry-name test

yc container image delete $IMAGE_ID

# Удалить все образы (если нужно)
for id in $(yc container image list --registry-name test --format json | grep -o '"id": "[^"]*"' | cut -d'"' -f4); do
    yc container image delete $id
done

# Удалить реестр
yc container registry delete --name test

# Удалить Docker-образ локально
docker rmi cr.yandex/$REGISTRY_ID/python-app:latest
```
</details>

---

## Задача 3. Запуск проекта с помощью Docker Compose

### 3.1 Исходные данные

**Proxy.yaml**

| Сервис	| Назначение	| Порт	| Особенности |
|--------|-------------|---------|-------------|
|reverse-proxy |	HAProxy	 | 8080	| Прокси между Nginx и web |
|ingress-proxy	| Nginx |	8090	| Внешний вход, режим network_mode: host |
|backend	 | Сеть	| 172.20.0.0/24	| Bridge-сеть с фиксированной подсетью |

Для простоты тестирования:
- Используется сборка из Dockerfile.python

### 3.2 Создание compose.yaml
[compose.yaml](https://github.com/yudzhi/shvirtd-example-python/blob/main/compose.yaml)

<details>
  <summary>Ход выполнения</summary>

#### 3.2.1 Описание сервиса `web`

- *Образ приложения должен собираться при запуске compose из файла Dockerfile.python. Контейнер должен работать в bridge-сети с названием backend и иметь фиксированный ipv4-адрес 172.20.0.5.*  

- *Сервис должен всегда перезапускаться в случае ошибок.*

|Значение	| Что делает |
|-------------|--------------|
|restart: unless-stopped	| Перезапускается при ошибках/падении, НО не перезапускается, если вы вручную остановили (docker stop) |
|restart: always	| Перезапускается всегда: при падении, при перезагрузке Docker, даже если остановлен вручную |

В задании сказано "всегда перезапускаться" — следовало бы использовать restart: always, но unless-stopped — это лучшая практика для разработки (удобнее).

- *Передайте необходимые ENV-переменные для подключения к Mysql базе данных по сетевому имени сервиса web*

| Переменная	| Значение	| Откуда |
|-----------|------------|-----------|
| DB_HOST |	"db"	| Сетевое имя сервиса (не IP-адрес!) |
| DB_USER	| `${MYSQL_USER}` |	Из файла .env (app) |
| DB_PASSWORD |	`${MYSQL_PASSWORD}` |	Из файла .env (QwErTy1234) |
| DB_NAME	| `${MYSQL_DATABASE}` |	Из файла .env (virtd) |

#### 3.2.2 Описание сервиса `deb`

- *image=mysql:8.*
- *Контейнер должен работать в bridge-сети с названием backend и иметь фиксированный ipv4-адрес 172.20.0.10.*
- *Явно перезапуск сервиса в случае ошибок.*
- *Передайте необходимые ENV-переменные для создания: пароля root пользователя, создания базы данных, пользователя и пароля для web-приложения.Обязательно используйте уже существующий .env file для назначения секретных ENV-переменных!*

```yaml
include:
  - proxy.yaml

services:
  # ============================================
  # MySQL база данных
  # ============================================
  db:
    image: mysql:8.0
    container_name: mysql_db
    restart: unless-stopped
    env_file:
      - .env
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    networks:
      backend:
        ipv4_address: 172.20.0.10
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${MYSQL_ROOT_PASSWORD}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  # ============================================
  # Python FastAPI приложение
  # ============================================
  web:
    build:
      context: .
      dockerfile: Dockerfile.python
    container_name: python_app
    restart: unless-stopped
    depends_on:
      db:
        condition: service_healthy
    environment:
      DB_HOST: "db"
      DB_USER: ${MYSQL_USER}
      DB_PASSWORD: ${MYSQL_PASSWORD}
      DB_NAME: ${MYSQL_DATABASE}
    networks:
      backend:
        ipv4_address: 172.20.0.5
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 20s

volumes:
  mysql_data:
```
#### 3.2.4 Проверка синтаксиса `compose.yaml`
```bash
# Проверить, что файл корректен
docker compose config
```
</details>

### 3.3 Локальный запуск проекта с помощью Docker Compose

**Проблема: Nginx не слушает порт 8090, не опубликовал порт 8090 на хост.**

Из вывода видно:

- Все контейнеры запущены и healthy
- ❌ curl не может подключиться к порту 8090
- В логах MySQL видно, что БД virtd создана успешно

Причина: 
В `proxy.yaml` (который подключается через `include`) у Nginx указан `network_mode: host`:

- `network_mode: host` — контейнер использует сеть хоста напрямую
- В этом режиме секция `ports` игнорируется
- Нужно либо убрать `network_mode: host`, либо добавить `ports`


<details>
  <summary>Ход выполнения</summary>

```bash
# Запустить все сервисы
docker compose up -d

# Проверить статус контейнеров
docker compose ps
 
NAME                   IMAGE                        COMMAND                  SERVICE         CREATED          STATUS                    PORTS
mysql_db                                 mysql:8.0                    "docker-entrypoint.s…"   db              17 seconds ago   Up 16 seconds (healthy)   0.0.0.0:3306->3306/tcp, [::]:3306->3306/tcp
shvirtd-example-python-ingress-proxy-1   nginx:latest                 "/docker-entrypoint.…"   ingress-proxy   17 seconds ago   Up 16 seconds
shvirtd-example-python-reverse-proxy-1   haproxy:2.4                  "docker-entrypoint.s…"   reverse-proxy   17 seconds ago   Up 16 seconds             127.0.0.1:8080->8080/tcp
shvirtd-example-python-web               shvirtd-example-python-web   "uvicorn main:app --…"   web             17 seconds ago   Up 10 seconds (healthy)
```

</details>


<details>
  <summary>Скриншоты</summary>
</details>


---
