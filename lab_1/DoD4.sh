#!/bin/bash

# Информация об ОС
echo "Операционная система:"
echo "$(lsb_release -d | cut -f2)"
echo "$(lsb_release -r | cut -f2)"

# Информация о ядре
echo "Ядро Linux:"
echo "$(uname -r)"
echo "$(uname -m)"

# Информация о процессоре
echo "Процессор:"
echo "$(cat /proc/cpuinfo | grep 'model name' | head -n 1 | cut -f2 -d':')"
echo "$(cat /proc/cpuinfo | grep 'cpu MHz' | head -n 1 | cut -f2 -d':')"
echo "$(cat /proc/cpuinfo | grep 'cpu cores' | head -n 1 | cut -f2 -d':')"
echo "$(cat /proc/cpuinfo | grep 'cache size' | head -n 1 | cut -f2 -d':')"

# Информация об оперативной памяти
echo "Оперативная память:"
echo "Доступно: $(free -h | grep Mem | awk '{print $4}')"
echo "Всего: $(free -h | grep Mem | awk '{print $2}')"
echo "Использовано: $(free -h | grep Mem | awk '{print $3}')"

# Информация о сетевых интерфейсах
echo "Сетевые интерфейсы:"
for interface in $(ip link show | grep -o -E 'eth[0-9]+|enp[0-9]+s[0-9]+|wlan[0-9]+'); do
    echo "$interface:"
    echo "  IP: $(ip addr show $interface | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)"
    echo "  MAC: $(ip addr show $interface | grep 'link/ether' | awk '{print $2}')"
    echo "  Скорость: $(ethtool $interface | grep 'Speed:' | awk '{print $2,$3}')"
done

# Информация о системных разделах
echo "Системные разделы:"
df -h | awk '{print "  Точка монтирования: " $6, "\n  Размер: " $2, "\n  Занято: " $3, "\n  Свободно: " $4}'
