### 1. Подготовка

Запускаем кластер Minikube:
```
minikube start
```
И проверяем его статус:
```
minikube status
```

### 2. Включение Ingress в Minikube
Ingress в Minikube доступен как аддон. Активируем его:
```
minikube addons enable ingress
```
Проверим, что Ingress запущен:
```
kubectl get pods -n kube-system
```
В выводе должен появится pod с именем `ingress-nginx-controller`.

### 3. Создание Deployment
Deployment управляет репликами Pod'ов. Создадим YAML-манифест nginx-deployment.yaml:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```
Применим манифест:
```
kubectl apply -f nginx-deployment.yaml
```
И проверим состояние Deployment:
```
kubectl get deployments
kubectl get pods
```

### 4. Создание Service
Для экспонирования Pods создадим Service. YAML-манифест nginx-service.yaml:
```
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```
Применим манифест:
```
kubectl apply -f nginx-service.yaml
```
Убедимся, что Service создан:
```
kubectl get svc
```

### 5. Настройка Ingress
Ingress позволяет направлять HTTP-трафик в Service. YAML-манифест nginx-ingress.yaml:
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  rules:
  - host: nginx.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
```
Применим манифест:
```
kubectl apply -f nginx-ingress.yaml
```
Проверим статус Ingress:
```
kubectl get ingress
```

### 6. Обновление файла hosts
Откроет файл /etc/hosts и добавим в него строчку:
```
192.168.49.2 nginx.local
```

### 7. Доступ к приложению
Проверим доступ к приложению, перейдя по адресу `http://nginx.local`

### 8. Демонстрация работы
Проверим Pods, которые управляются Deployment и ReplicaSet:
```
kubectl get pods -o wide
kubectl describe deployment nginx-deployment
kubectl describe replicaset
```