### 1. Подготовка приложения
Создадим простое веб-приложение на Python с использованием Flask.
Файл `app.py`
```
from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def index():
    return f"Hello from container {os.getenv('CONTAINER_ID', 'unknown')}!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

Создадим `Dockerfile`
```
# Используем базовый образ Python
FROM python:3.9-slim

# Устанавливаем зависимости
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

# Копируем приложение
COPY app.py .

# Устанавливаем переменную окружения
ENV CONTAINER_ID ${HOSTNAME}

# Запускаем приложение
CMD ["python", "app.py"]
```
Файл с зависимостями `requirements.txt`
```
flask
```

Соберем образ контейнера
```
docker build -t flask-app .
```

### 2. Настойка Nginx
Создадим конфигурацию Nginx, чтобы он распределял запросы между контейнерами.
Файл `nginx.conf`
```
events {}

http {
    upstream backend {
        server flask-app1:5000;
        server flask-app2:5000;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
```

### 3. Docker-compose
Для удобства управления контейнерами используем Docker Compose.
Файл `docker-compose.yml`
```
version: '3.8'

services:
  flask-app1:
    build:
      context: .
    container_name: flask-app1
    ports:
      - "5001:5000"

  flask-app2:
    build:
      context: .
    container_name: flask-app2
    ports:
      - "5002:5000"

  nginx:
    image: nginx:latest
    container_name: nginx
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - flask-app1
      - flask-app2
```

Запустим контейнеры
```
docker-compose up --build
```

После запуска:
- Nginx будет доступен на порту 80.
- Запросы к Nginx будут распределяться между контейнерами `flask-app1`  и `flask-app2`.

### 4. Проверка
Откроем в браузере ссылку `http://localhost/`.
Можно увидеть, что при обновлении страницы ответы чередуются между `flask-app1` и `flask-app2`.
