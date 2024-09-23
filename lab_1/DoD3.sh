#!/bin/bash

# Получение информации об операционной системе
os_name=$(lsb_release -s -d)
os_version=$(lsb_release -s -r)

# Получение информации о ядре
kernel_version=$(uname -r)
kernel_arch=$(uname -m)

# Получение информации о процессоре
cpu_model=$(cat /proc/cpuinfo | grep "model name" | head -n 1 | cut -d ":" -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//')
cpu_freq=$(cat /proc/cpuinfo | grep "cpu MHz" | head -n 1 | cut -d ":" -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//')
cpu_cores=$(cat /proc/cpuinfo | grep "cpu cores" | head -n 1 | cut -d ":" -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//')
cpu_cache=$(cat /proc/cpuinfo | grep "cache size" | head -n 1 | cut -d ":" -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//')

# Получение информации об оперативной памяти
mem_total=$(free -h | grep "Mem:" | awk '{print $2}')
mem_used=$(free -h | grep "Mem:" | awk '{print $3}')
mem_available=$(free -h | grep "Mem:" | awk '{print $7}')

# Вывод информации
echo "Operating System: $os_name ($os_version)"
echo "Kernel Version: $kernel_version ($kernel_arch)"
echo "CPU Model: $cpu_model"
echo "CPU Frequency: $cpu_freq MHz"
echo "CPU Cores: $cpu_cores"
echo "CPU Cache: $cpu_cache"
echo "Total Memory: $mem_total"
echo "Used Memory: $mem_used"
echo "Available Memory: $mem_available"
