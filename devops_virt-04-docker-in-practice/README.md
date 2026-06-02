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
