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
