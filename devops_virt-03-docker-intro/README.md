# Домашнее задание к занятию 4 «Оркестрация группой Docker контейнеров на примере Docker Compose»
## Задача 1
### Ответ: 
[https://hub.docker.com/repository/docker/yudzhi/custom-ngninx/general](https://hub.docker.com/repository/docker/yudzhi/custom-nginx/general)
<details>
  <summary>Ход выполнения</summary>
             
```ruby
docker compose version
```
*Docker Compose version v5.1.4*
```ruby
docker -v
```
*Docker version 29.5.2, build 79eb04c*
```ruby
docker login -u yudzhi
```
*Password: 
Login Succeeded*
```ruby
mkdir custom-nginx-project
cd custom-nginx-project/
sudo docker pull nginx:1.29.0
```
*Status: Downloaded newer image for nginx:1.29.0
docker.io/library/nginx:1.29.0*
```ruby
nano index.html
nano Dockerfile
sudo docker build -t yudzhi/custom-nginx:1.0.0 .
sudo docker login
sudo docker push yudzhi/custom-nginx:1.0.0
```
*The push refers to repository [docker.io/yudzhi/custom-nginx]
1.0.0: digest: sha256:64036ce20b86c93be3e6b97f46ed880e0cd44ca6ec25b5760be8a0cc34afc7b3 size: 856*
</details>

## Задача 2
### Ответ:
![Qst2 screenshot #1](https://downloader.disk.yandex.ru/disk/98680c9e21b6955a6f49e0d1f064cbfb7fc3632e1c950e5ff6d3e0f85b56e650/6a19a04d/iFwHyHfHYV6LpWmkyGg1uGYMlolVBhEweByo3RwwXLNcEKfkNeZQUVGbP-nZxqZyHZb1tozJ_sHun0DOvY4qFg%3D%3D?uid=0&filename=Qst2_docker-run-nginx_1.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=0&fsize=539283&hid=209557afa97150064214fb4b60654321&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=c47e2719843541a7e583a990c6099f7a)

![Qst2 screenshot #2](https://3.downloader.disk.yandex.ru/disk/2996bfc1f6a9fb38f8ca71085f6f235ee2aa9095c63953aed202c9652b4e3fe2/6a19a114/iFwHyHfHYV6LpWmkyGg1uPEXmM24G-FC7bt-ZiFSwgLFh5x3tj9_dbAh302HoKgYosti9_eNBkK2NNBEgrYs2g%3D%3D?uid=22194168&filename=Qst2_docker-run-nginx_2.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=548531&hid=df7c971cd6183dd29130e10a9133e89a&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=d762f577b91823f616607626952b020c)

<details>
  <summary>
    Ход выполнения
  </summary>
  
```ruby
  # docker run -d -p 127.0.0.1:8080:80 --name "DzhebrailovaYN-custom-nginx-t2" yudzhi/custom-nginx:1.0.0
  # docker rename "DzhebrailovaYN-custom-nginx-t2" custom-nginx-t2
  # date +"%d-%m-%Y %T.%N %Z" ; sleep 0.150 ; docker ps ; ss -tlpn | grep 127.0.0.1:8080:80 ; docker logs custom-nginx-t2 -n1 ; docker exec -it custom-nginx-t2 base64 /usr/share/nginx/html/index.html

  29-05-2026 10:26:57.623779602 MSK
CONTAINER ID   IMAGE                       COMMAND                  CREATED         STATUS         PORTS                    NAMES
5e058e2ed4c7   yudzhi/custom-nginx:1.0.0   "/docker-entrypoint.…"   9 minutes ago   Up 9 minutes   127.0.0.1:8080->80/tcp   custom-nginx-t2
172.17.0.1 - - [29/May/2026:07:26:05 +0000] "HEAD / HTTP/1.1" 200 0 "-" "curl/7.81.0" "-"
PGh0bWw+CjxoZWFkPgpIZXksIE5ldG9sb2d5CjwvaGVhZD4KPGJvZHk+CjxoMT5JIHdpbGwgYmUg
RGV2T3BzIEVuZ2luZWVyITwvaDE+CjwvYm9keT4KPC9odG1sPgo=
```
```ruby
# curl -I http://127.0.0.1:8080
HTTP/1.1 200 OK
Server: nginx/1.29.0
Date: Fri, 29 May 2026 07:26:05 GMT
Content-Type: text/html
Content-Length: 95
Last-Modified: Fri, 29 May 2026 02:41:29 GMT
Connection: keep-alive
ETag: "6a18fcd9-5f"
Accept-Ranges: bytes
```
</details>

## Задача 3
### Ответ:
![Ctrl+C didn't stop the container](https://2.downloader.disk.yandex.ru/disk/c989b6aff9a34b63f8e76c3a2ed43873c004ebd5b132b90f7207c1f0f3033239/6a19a70d/iFwHyHfHYV6LpWmkyGg1uBh9y0YJxvThP9ChkW_cwWDfwvYdhMX1d3AzkFdXOboIgfip9EgN_wpfYtIEy9n0FQ%3D%3D?uid=22194168&filename=Qst3_docker-logs_1.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=581529&hid=fe533f8b5e3c8640426dab70f11996d1&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=46f65e02aa95805843347f990c958146)

**Объяснение:** Ctrl+C посылает сигнал прерывания процессу в контейнере, завершая главный процесс (Nginx), что приводит к остановке контейнера.

**Нюанс**
Ctrl+C завершило подключение к потоку логирования, но не остановило сам контейнер.

**Версия:**
запущен контейнер был в одном терминале командой `# docker run -d -p 127.0.0.1:8080:80 --name "DzhebrailovaYN-custom-nginx-t2" yudzhi/custom-nginx:1.0.0 `, а процесс логирования был запущен в другом терминале командой `# docker logs -f custom-nginx-t2`. Hажатие `Ctrl+C` в терминале с `docker logs -f` не остановило контейнер. Была прервана сама команда `docker logs -f`, контейнер продолжил работать в фоне — его главный процесс (Nginx) даже не получил сигнала.
Я просто вернулась в командную строку терминала.

   > «Контейнер был остановлен командой `docker stop`, которая отправила сигнал `SIGTERM` основному процессу (Nginx). Процесс завершил работу, и контейнер перешёл в статус `Exited`».

---
![Docker stop and bash](https://3.downloader.disk.yandex.ru/disk/2ab5e58541dcb420fc4b4197c27a76a38ba556bff71ef4e271321005145af88e/6a1a20e2/iFwHyHfHYV6LpWmkyGg1uNFFbXlT-byx3fEqY50jQ3zKYJVtAS69XXcArDIUl7Vp6GAQiGxC2yHWjWp5hgFNOA%3D%3D?uid=22194168&filename=Qst3_docker-logs_2.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=511217&hid=b9adea12896f427d90530e6393f8c630&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=369fdcd41cdef261dd4c8e36a9b92553)

![Nano installed and port 80->>81](https://2.downloader.disk.yandex.ru/disk/95a4288b345f3218b6434d1853a230def379b5a1a4d71459b49463067911b2dc/6a1a217d/iFwHyHfHYV6LpWmkyGg1uM-n2cEuCdTVOP2k4476t8CgwW0otSxFFh-DqSWWrgo7dygAd8slhZLyQh1nGzjImw%3D%3D?uid=22194168&filename=Qst3_docker-nano_3.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=442657&hid=deabf7feb52ac0727b480a4ca4f3ddc2&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=f1c8d52deb0256a67dd247b1343f6708)

#### п.10
Проброс портов (`-p 127.0.0.1:8080:80`) настраивается при запуске контейнера и не меняется автоматически при изменении конфигурации внутри контейнера. 
Мы изменили порт внутри контейнера (listen 81), но проброска портов осталась прежней. Хост слушает 80-й порт контейнера, а он теперь выключен. Поэтому curl возвращает ошибку.

**Проверка проброса портов:**

```bash
# docker port custom-nginx-t2
80/tcp -> 127.0.0.1:8080
```
Docker создаёт правило в брандмауэре хоста: «Все запросы на 127.0.0.1:8080 перенаправлять в контейнер на порт 80».
Хост получает запрос, видит правило проброса и передаёт его контейнеру на порт 80. Nginx внутри контейнера отвечает, и ответ возвращается клиенту.

```bash
# ss -tlpn | grep 127.0.0.1:8080
LISTEN 0      4096       127.0.0.1:8080      0.0.0.0:*    users:(("docker-proxy",pid=46581,fd=8))  
# curl http://127.0.0.1:8080
curl: (56) Recv failure: Connection reset by peer
```

Команда `nginx -s reload` не меняет проброс портов Docker — она только перезагружает конфигурацию Nginx внутри контейнера.

---

![docker_4](https://4.downloader.disk.yandex.ru/disk/d21c8903954e60827fd284af0c8521b6a3bc0c6d6b5b71b374cc89656415060d/6a1a4226/iFwHyHfHYV6LpWmkyGg1uOX2L-ufKHPMNaedLNs60kQknAdoaI26Yb7FRj_sXitgCM1s4mlhR_icp2sTph08Pw%3D%3D?uid=22194168&filename=Qst3_docker_4.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=511278&hid=196c37a72115d67a3e2ea1994e4aa8cf&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=d357f51736c5c786a02db30bd2c0662a)

![docker_5](https://2.downloader.disk.yandex.ru/disk/f3f0dcb59f976091dc39a255f4961efb14d5b3a272f3a4322a6a451a0bf94bc5/6a1a428b/iFwHyHfHYV6LpWmkyGg1uMkotrUvpSnYSz9jDqaoZD4S8xASfjA7bsCylVEvgD64YJQcguRkCL93B3uXyTkygA%3D%3D?uid=22194168&filename=Qst3_docker_5.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=611688&hid=f4454b87b2106dfcdad4360a07b87e7f&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=01d69aef9d33cb08b8e6dd57f9c6d6c6)

![docker_6](https://1.downloader.disk.yandex.ru/disk/ff1c96d4c1a872d6687d036108053f7914bdb940abaa5ff9f7eddcb93ccb82e0/6a1a42b8/iFwHyHfHYV6LpWmkyGg1uMkotrUvpSnYSz9jDqaoZD4S8xASfjA7bsCylVEvgD64YJQcguRkCL93B3uXyTkygA%3D%3D?uid=22194168&filename=Qst3_docker_6.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=611688&hid=f4454b87b2106dfcdad4360a07b87e7f&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=01d69aef9d33cb08b8e6dd57f9c6d6c6)

<details>
  <summary> Ход выполнения </summary>

``` ruby
$ docker logs -f custom-nginx-t2
```
(Флаг -f — follow, следит за новыми строками)

**Ctrl+C завершило подключение к потоку логирования, но не остановило сам контейнер.**

```ruby
# docker ps -a
CONTAINER ID   IMAGE                       COMMAND                  CREATED       STATUS       PORTS                    NAMES
5e058e2ed4c7   yudzhi/custom-nginx:1.0.0   "/docker-entrypoint.…"   3 hours ago   Up 3 hours   127.0.0.1:8080->80/tcp   custom-nginx-t2
# docker stop custom-nginx-t2 
custom-nginx-t2
# docker ps -a
CONTAINER ID   IMAGE                       COMMAND                  CREATED       STATUS                     PORTS     NAMES
5e058e2ed4c7   yudzhi/custom-nginx:1.0.0   "/docker-entrypoint.…"   3 hours ago   Exited (0) 4 seconds ago             custom-nginx-t2
```

Перезапуск

```
# docker start custom-nginx-t2
custom-nginx-t2
```

Вход в интерактивный терминал

```bash
# docker exec -it custom-nginx-t2 bash
```

Установка редактора и изменение конфига - замена `listen 80` на `listen 81`

```bash
root@5e058e2ed4c7:/# apt-get update
root@5e058e2ed4c7:/# apt-get install -y nano
root@5e058e2ed4c7:/# nano /etc/nginx/conf.d/default.conf
```

Перезагрузка и проверка, выход

```bash
# nginx -s reload
2026/05/29 19:18:46 [notice] 178#178: signal process started
root@5e058e2ed4c7:/# curl http://127.0.0.1:80
curl: (7) Failed to connect to 127.0.0.1 port 80 after 0 ms: Couldn't connect to server
root@5e058e2ed4c7:/# curl http://127.0.0.1:81
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I will be DevOps Engineer!</h1>
</body>
</html>
root@5e058e2ed4c7:/# exit
exit
```

Анализ проблемы с внешним портом

```bash
ss -tlpn | grep 127.0.0.1:8080
LISTEN 0      4096       127.0.0.1:8080      0.0.0.0:*    users:(("docker-proxy",pid=46581,fd=8))  
# docker port custom-nginx-t2
80/tcp -> 127.0.0.1:8080
# curl http://127.0.0.1:8080
curl: (56) Recv failure: Connection reset by peer
```

Удаление контейнера: (Флаг -f принудительно останавливает и удаляет, даже если контейнер запущен).
```bash
docker rm -f custom-nginx-t2
```

</details>
