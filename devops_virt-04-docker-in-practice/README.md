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

**1. Изучение 'main.py':
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
</details>

<details>
  <summary>Ход выполнения</summary>
</details>

---
