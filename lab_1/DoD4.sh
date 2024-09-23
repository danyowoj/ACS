#!/bin/bash

# Информация об ОС
echo "The operating system:"
# lsb_release используется для получения информации об используемом дистрибутиве Linux
echo "$(lsb_release -d)" # -d для вывода названия дистрибутива
echo "$(lsb_release -r)" # -r для вывода номера релиза дистрибутива
echo

# Информация о ядре
echo "The Linux kernel:"
# uname - получает название ядра и информацию о нем 
echo "Kernel release: $(uname -r)" # -r выводит информацию о выпуске ядра
echo "Machine:        $(uname -m)" # -m выводит тип оборудования машины
echo

# Информация о процессоре
echo "CPU:"
echo "Model name:    $(cat /proc/cpuinfo | grep 'model name' | head -n 1 | cut -f2 -d':')"
echo "CPU MHz:       $(cat /proc/cpuinfo | grep 'cpu MHz' | head -n 1 | cut -f2 -d':')"
echo "CPU cores:     $(cat /proc/cpuinfo | grep 'cpu cores' | head -n 1 | cut -f2 -d':')"
echo "Cache size:    $(cat /proc/cpuinfo | grep 'cache size' | head -n 1 | cut -f2 -d':')"
echo

# Информация об оперативной памяти
echo "RAM:"
echo "Available:      $(free -h | grep Mem | awk '{print $4}')"
echo "Total:          $(free -h | grep Mem | awk '{print $2}')"
echo "Used:           $(free -h | grep Mem | awk '{print $3}')"
echo

# Информация о сетевых интерфейсах
echo "Network interfaces:"
# do - Начинает цикл для перебора всех сетевых интерфейсов
# ip link show выводит информацию о сетевых устройствах
# grep -o -E 'eth[0-9]+|enp[0-9]+s[0-9]+|wlan[0-9]+' 
# выделяет из этого вывода названия сетевых интерфейсов, соответствующих шаблонам eth0, enp0s1, wlan0 и т.д
for interface in $(ip link show | grep -o -E 'eth[0-9]+|enp[0-9]+s[0-9]+|wlan[0-9]+'); do
    # Для каждого найденного интерфейса выводит его название.
    echo "$interface:"
    
    # Получает IP-адрес интерфейса с помощью команды ip addr show, фильтрует строки, содержащие слово inet, 
    # извлекает второе поле (IP-адрес) и удаляет маску подсети.
    echo "  IP: $(ip addr show $interface | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)"
    
    # Получает MAC-адрес интерфейса также с помощью ip addr show, фильтруя строки с link/ether и извлекая второе поле (MAC-адрес).
    echo "  MAC: $(ip addr show $interface | grep 'link/ether' | awk '{print $2}')"
    
    # Получает информацию о скорости интерфейса с помощью команды ethtool, фильтрует строки с Speed: и выводит значение скорости.
    echo "  Speed: $(ethtool $interface | grep 'Speed:' | awk '{print $2,$3}')"
# Завершает цикл перебора сетевых интерфейсов.
done
echo

# Информация о системных разделах
echo "System partitions:"

# Получает информацию о системных разделах с помощью команды df -h (выводящей информацию о файловых системах в человекочитаемом формате), 
# и с помощью awk форматирует вывод, распечатывая для каждого раздела точку монтирования, размер, занятое и свободное пространство.
df -h | awk '{print "  Точка монтирования: " $6, "\n  Размер: " $2, "\n  Занято: " $3, "\n  Свободно: " $4}'
echo
