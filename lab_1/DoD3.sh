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
echo "Cache:         "         $(lscpu | grep 'cache')
#echo "Cache size:    $(cat /proc/cpuinfo | grep 'cache size' | head -n 1 | cut -f2 -d':')"
echo

# Информация об оперативной памяти
echo "RAM:"
echo "Available:      $(free -h | grep Mem | awk '{print $4}')"
echo "Total:          $(free -h | grep Mem | awk '{print $2}')"
echo "Used:           $(free -h | grep Mem | awk '{print $3}')"
echo