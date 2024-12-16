### Создаем ssl для домена, на котором будет находиться jenkins
```
sudo apt install mkcert
mkcert -install
mkcert jenkins.local 127.0.0.1
```
Команда mkcert jenkins.local 127.0.0.1 создаст сертификаты для
localhost, она создаст необходимые сертификаты и файлы , которые
в дальнейшем будут использоваться в конфигурации нашего Docker
Compose.

Содержимое docker-compose.yml:
```
services:
  nginx:
    image: nginx:latest
    container_name: nginx-proxy
    ports:
      - "443:443"
    volumes:
      - ./jenkins.local+1-key.pem:/etc/nginx/certs/jenkins.local+1-key.pem
      - ./jenkins.local+1.pem:/etc/nginx/certs/jenkins.local+1.pem
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - jenkins

  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    user: root
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - JENKINS_OPTS=--httpPort=8080

    privileged: true

volumes:
  jenkins_home:
    driver: local
```
Содержимое nginx.conf:
```
server {
    listen 443 ssl;
    server_name jenkins.local;

    ssl_certificate /etc/nginx/certs/jenkins.local+1.pem;
    ssl_certificate_key /etc/nginx/certs/jenkins.local+1-key.pem;

    location / {
        proxy_pass http://jenkins:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
    }
}
```
Также необходимо добавить соответствующую записать в файл
/etc/hosts:
```
127.0.0.1 jenkins.local
```
Запускаем контейнеры и убеждаемся, что они запущены:
```
docker-compose up -d
docker ps
```
Заходим в jenkins обращаясь по адресу https://jenkins.local/ в
браузере, регистрируем пользователя и скачиваем все
необходимые плагины для работы с pipeline и гитом

Создаем pipeline:
- В *GitHub project* указываем URL репозитория
- Включаем *GitHub hook trigger for GITScm polling*
- В части *Pipeline -> Definition* выбираем *Pipeline script from SCM*
- В *SCM* выбираем *Git*
- В *Repository URL* вставляем URL репозитория
- В *Branches to build* вводим */main

Сохраняем pipeline и переходим в репозиторий, URL которого мы указывали при создании pipeline.

Создаем внутри репозитория файл JenkinsFile:
```
pipeline {
    agent any
    stages {
        stage('Hello') {
            steps {
                echo 'Hello RGZ AVS'
            }
        }
    }
}
```
Натсроим webhook при помощи ngrok. Его необходимо установить на нашу хост машину, делается это командой:
```
curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | \
sudo gpg --dearmor -o /etc/apt/keyrings/ngrok.gpg && \
echo "deb [signed-by=/etc/apt/keyrings/ngrok.gpg]
https://ngrok-agent.s3.amazonaws.com buster main" | \
sudo tee /etc/apt/sources.list.d/ngrok.list && \
sudo apt update && sudo apt install ngrok
```
Также необходимо зарегистрировать аккаунт на сайте и
скопировать содержимое токена в личном кабинете, после чего
выполнить команду:
```
ngrok config add-authtoken <TOKEN>
```
Создаем постоянное подключение с нашим nginx для дальнейшей
ретрансляции трафика в jenkins с помощью следующей команды:
```
ngrok http 443
```
Теперь мы можем настроить webhooks на нашем репозитории github
вставив URL, который сгенерировал ngrok.

- В *Payload URL* вставляем URL, который сгенерировал ngrok, добавив */github-webhook/* в конце строки
- В *Content type* выбираем *application/x-www-form-urlencoded*
- Ставим галочку в поле *Active*

