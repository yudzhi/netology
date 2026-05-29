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
