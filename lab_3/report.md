Создаем Dockerfile для создания образов контейнеров:
```
FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    openssh-server \
    python3 \
    python3-pip \
    sudo

RUN useradd -m -s /bin/bash user && echo "user:password" | chpasswd \
    && mkdir /home/user/.ssh && chmod 700 /home/user/.ssh \
    && usermod -aG sudo user

COPY id_rsa.pub /home/user/.ssh/authorized_keys
RUN chmod 600 /home/user/.ssh/authorized_keys \
    && chown -R user:user /home/user/.ssh

RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "PermitRootLogin no" >> /etc/ssh/sshd_config \
    && echo "AllowUsers user" >> /etc/ssh/sshd_config

RUN mkdir /var/run/sshd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
```

Собираем образ контейнеров:
```
docker build -t my_ssh_container .
```

И запускаем два контейнера:
```
docker run -d -p 2222:22 --name container1 my_ssh_container
docker run -d -p 2223:22 --name container2 my_ssh_container
```

Проверяем подключение по ssh:
```
ssh user@localhost -p 2222
ssh user@localhost -p 2223
```

Создаем файл ansible.cfg в директории */ansible*:
```
[defaults]
inventory = inventory/hosts
roles_path = roles
remote_user = root
become = true
```

Создаем конфигурацию для подключения к контейнерам в директории /*ansible/inventory*:
```
[containers]
container1 ansible_host=localhost ansible_port=2222 ansible_user=user ansible_ssh_private_key_file=/home/danyowoj/.ssh/id_rsa
container2 ansible_host=localhost ansible_port=2223 ansible_user=user ansible_ssh_private_key_file=/home/danyowoj/.ssh/id_rsa
```

При использовании WSL необходимо явно указать путь к файлу конфигурации:
```
export ANSIBLE_CONFIG=/mnt/c/Users/latsu/GitHub_projects/ACS/lab_3/ansible/ansible.cfg
```

Проверяем доступ:
```
ansible -m ping all
```

Выводим команды hostname:
```
ansible -m shell -a hostname container1,container2
```
