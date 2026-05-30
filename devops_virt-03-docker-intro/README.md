# Домашнее задание к занятию 4 «Оркестрация группой Docker контейнеров на примере Docker Compose»
## Задача 1
### Ответ: 
[https://hub.docker.com/repository/docker/yudzhi/custom-ngninx/general](https://hub.docker.com/repository/docker/yudzhi/custom-nginx/general)
<details>
  <summary>Ход выполнения</summary>
             
```bash
# docker compose version
```
*Docker Compose version v5.1.4*
```bash
# docker -v
```
*Docker version 29.5.2, build 79eb04c*
```bash
# docker login -u yudzhi
```
*Password: 
Login Succeeded*
```bash
# mkdir custom-nginx-project
# cd custom-nginx-project/
# sudo docker pull nginx:1.29.0
```
*Status: Downloaded newer image for nginx:1.29.0
docker.io/library/nginx:1.29.0*
```bash
# nano index.html
# nano Dockerfile
# sudo docker build -t yudzhi/custom-nginx:1.0.0 .
# sudo docker login
# sudo docker push yudzhi/custom-nginx:1.0.0
```
*The push refers to repository [docker.io/yudzhi/custom-nginx]
1.0.0: digest: sha256:64036ce20b86c93be3e6b97f46ed880e0cd44ca6ec25b5760be8a0cc34afc7b3 size: 856*
</details>

## Задача 2
### Ответ:
<details>
  <summary>Скриншоты</summary>

![Qst2 screenshot #1](https://downloader.disk.yandex.ru/disk/98680c9e21b6955a6f49e0d1f064cbfb7fc3632e1c950e5ff6d3e0f85b56e650/6a19a04d/iFwHyHfHYV6LpWmkyGg1uGYMlolVBhEweByo3RwwXLNcEKfkNeZQUVGbP-nZxqZyHZb1tozJ_sHun0DOvY4qFg%3D%3D?uid=0&filename=Qst2_docker-run-nginx_1.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=0&fsize=539283&hid=209557afa97150064214fb4b60654321&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=c47e2719843541a7e583a990c6099f7a)

![Qst2 screenshot #2](https://3.downloader.disk.yandex.ru/disk/2996bfc1f6a9fb38f8ca71085f6f235ee2aa9095c63953aed202c9652b4e3fe2/6a19a114/iFwHyHfHYV6LpWmkyGg1uPEXmM24G-FC7bt-ZiFSwgLFh5x3tj9_dbAh302HoKgYosti9_eNBkK2NNBEgrYs2g%3D%3D?uid=22194168&filename=Qst2_docker-run-nginx_2.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=548531&hid=df7c971cd6183dd29130e10a9133e89a&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=d762f577b91823f616607626952b020c)
</details>

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
<details>
  <summary>Скриншоты</summary>

![Ctrl+C didn't stop the container](https://2.downloader.disk.yandex.ru/disk/c989b6aff9a34b63f8e76c3a2ed43873c004ebd5b132b90f7207c1f0f3033239/6a19a70d/iFwHyHfHYV6LpWmkyGg1uBh9y0YJxvThP9ChkW_cwWDfwvYdhMX1d3AzkFdXOboIgfip9EgN_wpfYtIEy9n0FQ%3D%3D?uid=22194168&filename=Qst3_docker-logs_1.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=581529&hid=fe533f8b5e3c8640426dab70f11996d1&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=46f65e02aa95805843347f990c958146)
</details>

**Объяснение:** Ctrl+C посылает сигнал прерывания процессу в контейнере, завершая главный процесс (Nginx), что приводит к остановке контейнера.

**Нюанс**
Ctrl+C завершило подключение к потоку логирования, но не остановило сам контейнер.

**Версия:**
запущен контейнер был в одном терминале командой `# docker run -d -p 127.0.0.1:8080:80 --name "DzhebrailovaYN-custom-nginx-t2" yudzhi/custom-nginx:1.0.0 `, а процесс логирования был запущен в другом терминале командой `# docker logs -f custom-nginx-t2`. Hажатие `Ctrl+C` в терминале с `docker logs -f` не остановило контейнер. Была прервана сама команда `docker logs -f`, контейнер продолжил работать в фоне — его главный процесс (Nginx) даже не получил сигнала.
Я просто вернулась в командную строку терминала.

   > «Контейнер был остановлен командой `docker stop`, которая отправила сигнал `SIGTERM` основному процессу (Nginx). Процесс завершил работу, и контейнер перешёл в статус `Exited`».

<details>
  <summary>Скриншоты</summary>

![Docker stop and bash](https://3.downloader.disk.yandex.ru/disk/2ab5e58541dcb420fc4b4197c27a76a38ba556bff71ef4e271321005145af88e/6a1a20e2/iFwHyHfHYV6LpWmkyGg1uNFFbXlT-byx3fEqY50jQ3zKYJVtAS69XXcArDIUl7Vp6GAQiGxC2yHWjWp5hgFNOA%3D%3D?uid=22194168&filename=Qst3_docker-logs_2.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=511217&hid=b9adea12896f427d90530e6393f8c630&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=369fdcd41cdef261dd4c8e36a9b92553)

![Nano installed and port 80->>81](https://2.downloader.disk.yandex.ru/disk/95a4288b345f3218b6434d1853a230def379b5a1a4d71459b49463067911b2dc/6a1a217d/iFwHyHfHYV6LpWmkyGg1uM-n2cEuCdTVOP2k4476t8CgwW0otSxFFh-DqSWWrgo7dygAd8slhZLyQh1nGzjImw%3D%3D?uid=22194168&filename=Qst3_docker-nano_3.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=442657&hid=deabf7feb52ac0727b480a4ca4f3ddc2&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=f1c8d52deb0256a67dd247b1343f6708)
</details>

---

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

<details>
  <summary>Скриншоты</summary>

![docker_4](https://4.downloader.disk.yandex.ru/disk/d21c8903954e60827fd284af0c8521b6a3bc0c6d6b5b71b374cc89656415060d/6a1a4226/iFwHyHfHYV6LpWmkyGg1uOX2L-ufKHPMNaedLNs60kQknAdoaI26Yb7FRj_sXitgCM1s4mlhR_icp2sTph08Pw%3D%3D?uid=22194168&filename=Qst3_docker_4.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=511278&hid=196c37a72115d67a3e2ea1994e4aa8cf&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=d357f51736c5c786a02db30bd2c0662a)

![docker_5](https://2.downloader.disk.yandex.ru/disk/f3f0dcb59f976091dc39a255f4961efb14d5b3a272f3a4322a6a451a0bf94bc5/6a1a428b/iFwHyHfHYV6LpWmkyGg1uMkotrUvpSnYSz9jDqaoZD4S8xASfjA7bsCylVEvgD64YJQcguRkCL93B3uXyTkygA%3D%3D?uid=22194168&filename=Qst3_docker_5.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=611688&hid=f4454b87b2106dfcdad4360a07b87e7f&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=01d69aef9d33cb08b8e6dd57f9c6d6c6)

![docker_6](https://1.downloader.disk.yandex.ru/disk/ff1c96d4c1a872d6687d036108053f7914bdb940abaa5ff9f7eddcb93ccb82e0/6a1a42b8/iFwHyHfHYV6LpWmkyGg1uMkotrUvpSnYSz9jDqaoZD4S8xASfjA7bsCylVEvgD64YJQcguRkCL93B3uXyTkygA%3D%3D?uid=22194168&filename=Qst3_docker_6.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=611688&hid=f4454b87b2106dfcdad4360a07b87e7f&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=01d69aef9d33cb08b8e6dd57f9c6d6c6)

</details>

---

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

## Задача 4

### Ответ:
**Запуск контейнера centos с монтированием папки**

```bash
# docker run -d --name centos-container -v $(pwd):/data centos:latest

Error response from daemon: failed to resolve reference "docker.io/library/centos:latest": docker.io/library/centos:latest: not found
```

Официальный образ CentOS был удалён из Docker Hub в 2023 году. Компания Red Hat (владелец CentOS) прекратила поддержку дистрибутива и рекомендовала перейти на CentOS Stream или другие дистрибутивы.

Был использован официальный рекомендуемый CentOS Stream, доступный на quay.io. 
`tail -f /dev/null` — команда, которая выполняется бесконечно, не давая контейнеру завершиться.

```bash
# docker pull quay.io/centos/centos:stream9
# docker run -d --name centos-container -v $(pwd):/data quay.io/centos/centos:stream9 tail -f /dev/null
```
<details>
  <summary>Скриншоты</summary>

![CentOS_1](https://2.downloader.disk.yandex.ru/disk/c30a5b607b0ebf5d16d26ef6c23371947840673b23fdb8c80a346e6c7362d6d1/6a1b169c/iFwHyHfHYV6LpWmkyGg1uKKYzHbGsGkQCnyxWTHCjDpZo8eC4U-ryn2tle3vOTcMRj_DgFZLOO_tVobcZ9fETg%3D%3D?uid=22194168&filename=Qst4_centos_1.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=492453&hid=0d44f3bc5f32c841c5df5188baef6652&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=47098d96a1e0d2a5bc01af25b387d22b)

![CentOS_2](https://3.downloader.disk.yandex.ru/disk/ebef1b753f2a03411380188d1db0daec1d25107ba74e3224b720081e81c8c332/6a1b171c/iFwHyHfHYV6LpWmkyGg1uM9SnYT9xLJ2qTuSE7vCXGvkOQnv-WuRB388hAaL3zJY1CtWxqidLN6jpp2_ZooWIg%3D%3D?uid=22194168&filename=Qst4_centos_2.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=460025&hid=31d48c5e349aaff0f568236fbe2abbd4&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=25274f93d8772ad994595dfa07881e03)

![CentOS_3](https://3.downloader.disk.yandex.ru/disk/c373bcc084c63628674b39d1d706ae6a94c20099647c0ebb1e09e86349267c02/6a1b1742/iFwHyHfHYV6LpWmkyGg1uAsRozFq_BJldZXPgZDSzQyLEK1HLxYWolPKteOfLDk35rBZrDqGOBo1XkfS0Z3qFw%3D%3D?uid=22194168&filename=Qst4_centos_3.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=507026&hid=0a5f3972945844d6a81067e5db95f985&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=91be23097efe1d510ba8607e437601ab)

![Data_1](https://1.downloader.disk.yandex.ru/disk/87d0d6bcd17bb481f61b51e2ab9739d83f51d76e1e4002dc473f09be584bc830/6a1b313d/iFwHyHfHYV6LpWmkyGg1uJ2ueSAEcBnHRiIcVEx61d0bLTwF3gvWstxIK4MVUqXhcIy_SHvBkAbN4VA7DtOriA%3D%3D?uid=22194168&filename=Qst4_data_1.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=491867&hid=d5471c8282a6a84238f10bee51c2efd8&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=5765024b215c59abe3f644a758a49907)

![Data_2](https://3.downloader.disk.yandex.ru/disk/6bd7be85c1970a75f554356c457d0369dd94990481243099a0c651cde4aed697/6a1b317e/iFwHyHfHYV6LpWmkyGg1uMUMtw6eiGXpAwTK0vMyltcHLcApQyUwIgjS2Q952l5nzsumIqkys32h_f7VJwRxPQ%3D%3D?uid=22194168&filename=Qst4_data_2.png&disposition=inline&hash=&limit=0&content_type=image%2Fpng&owner_uid=22194168&fsize=455820&hid=709faa34885e530663865a1fab30814b&media_type=image&tknv=v3&is_direct_zip_experiment=1&etag=c2ebf0f9e796318769946da7b430cdb5)

</details>

---

<details>
  <summary>Ход выполнения</summary>

**Запуск контейнера Debian с монтированием той же папки**

```bash
# docker run -d --name debian-container -v $(pwd):/data debian:latest tail -f /dev/null
# docker ps

CONTAINER ID   IMAGE                           COMMAND               CREATED             STATUS             PORTS     NAMES
fae082f0acf3   debian:latest                   "tail -f /dev/null"   About an hour ago   Up About an hour             debian-container
590fb4dca215   quay.io/centos/centos:stream9   "tail -f /dev/null"   2 hours ago         Up 2 hours                   centos-container
```

**Создание файла в контейнере Centos Stream**

```bash
# docker exec -it centos-container bash
bash-5.1# echo "Это файл, созданный в контейнере CentOS Stream" > /data/file_from_centos.txt
bash-5.1# ls -la /data/
total 40
drwx------ 6 root root 4096 May 30 14:36 .
drwxr-xr-x 1 root root 4096 May 30 12:41 ..
-rw------- 1 root root 1747 May 30 09:56 .bash_history
-rw-r--r-- 1 root root 3106 Oct 15  2021 .bashrc
drwx------ 3 root root 4096 May 28 19:58 .cache
drwx------ 3 root root 4096 May 29 02:46 .docker
drwxr-xr-x 3 root root 4096 May 24 19:49 .local
-rw-r--r-- 1 root root  161 Jul  9  2019 .profile
-rw-r--r-- 1 root root   74 May 30 14:36 file_from_centos.txt
drwx------ 6 root root 4096 May 24 19:00 snap
bash-5.1# cat /data/file_from_centos.txt
Это файл, созданный в контейнере CentOS Stream
bash-5.1# exit
```

**Добавление файла на хостовой машине**

```bash
# echo "Этот файл создан на хосте" > $(pwd)/file_from_host.txt
# ls -la $(pwd)
total 44
drwx------  6 root root 4096 мая 30 17:40 .
drwxr-xr-x 20 root root 4096 мая 24 00:14 ..
-rw-------  1 root root 1747 мая 30 12:56 .bash_history
-rw-r--r--  1 root root 3106 окт 15  2021 .bashrc
drwx------  3 root root 4096 мая 28 22:58 .cache
drwx------  3 root root 4096 мая 29 05:46 .docker
-rw-r--r--  1 root root   74 мая 30 17:36 file_from_centos.txt
-rw-r--r--  1 root root   47 мая 30 17:40 file_from_host.txt
drwxr-xr-x  3 root root 4096 мая 24 22:49 .local
-rw-r--r--  1 root root  161 июл  9  2019 .profile
drwx------  6 root root 4096 мая 24 22:00 snap
```

**Проверка содержимого в контейнере Debian**

```bash
# docker exec -it debian-container bash
root@fae082f0acf3:/# ls -la /data/
total 44
drwx------ 6 root root 4096 May 30 14:40 .
drwxr-xr-x 1 root root 4096 May 30 13:03 ..
-rw------- 1 root root 1747 May 30 09:56 .bash_history
-rw-r--r-- 1 root root 3106 Oct 15  2021 .bashrc
drwx------ 3 root root 4096 May 28 19:58 .cache
drwx------ 3 root root 4096 May 29 02:46 .docker
drwxr-xr-x 3 root root 4096 May 24 19:49 .local
-rw-r--r-- 1 root root  161 Jul  9  2019 .profile
-rw-r--r-- 1 root root   74 May 30 14:36 file_from_centos.txt
-rw-r--r-- 1 root root   47 May 30 14:40 file_from_host.txt
drwx------ 6 root root 4096 May 24 19:00 snap
root@fae082f0acf3:/# cat /data/file_from_centos.txt
Это файл, созданный в контейнере CentOS Stream
root@fae082f0acf3:/# cat /data/file_from_host.txt
Этот файл создан на хосте
root@fae082f0acf3:/# exit
exit
```

</details>
