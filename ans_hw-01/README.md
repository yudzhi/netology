# Домашнее задание к занятию 1 «Введение в Ansible»
## Подготовка к выполнению

1. Установите Ansible версии 2.10 или выше.

```bash
pip3 install ansible
ansible --version

ansible [core 2.21.6]
```

2. Создайте свой публичный репозиторий на GitHub с произвольным именем. 

[netology/ans_hw-01](https://github.com/yudzhi/netology/tree/main/ans_hw-01)

3. Скачайте Playbook из репозитория с домашним заданием и перенесите его в свой репозиторий.

```bash
git clone https://github.com/netology-code/08-ansible-01-base_02.25.git

git checkout -b master
git add .
git commit -m "Complete ansible homework (branch master)"
git push -u origin master
```

## 1. Попробуйте запустить playbook на окружении из test.yml, зафиксируйте значение, которое имеет факт some_fact для указанного хоста при выполнении playbook.

