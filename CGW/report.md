На 4: Запуск jenkins и разработка сценариев CD
DoD:

Интерфейс доступен по https (jenkins)

В jenkins создан пайплайн/задача/таск, работающий с репозиторием gitlab/github
При изменении в репозитории автоматически запускается задача обновления docker-контейнера с содержимым репозитория (Либо сборка образа с новым приложением и обновление контейнера)

Оформить как docker-compose.yml

При пересоздании проекта, все настройки jenkins должны сохраниться


Создаем ssl для домена, на котором будет находиться jenkins
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
- Включаем *Опрашивать SCM об изменениях*
- В расписании указываем
```

H/15 * * * *
```
для опроса каждые 15 минут
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
