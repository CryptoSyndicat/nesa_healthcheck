#!/bin/bash

# Функция для проверки использования памяти
check_memory_usage() {
    # Получение общего объема памяти в килобайтах
    TOTAL_MEM=$(grep MemTotal /proc/meminfo | awk '{print $2}')

    # Получение использования памяти процессом uvicorn в килобайтах
    USED_MEM=$(ps -o rss= -p $(pgrep -f 'uvicorn') | awk '{s+=$1} END {print s}')

#    # Если нет использования памяти, вернуть 0
#    if [[ -z "$USED_MEM" || "$TOTAL_MEM" -le 0 ]]; then
#        echo "0"
#        return
#    fi

    # Преобразуем использование памяти в мегабайты
    USED_MEM_MB=$((USED_MEM / 1024))
    TOTAL_MEM_MB=$((TOTAL_MEM / 1024))

    # Вычисление процентного использования памяти
    PERCENTAGE=$(awk "BEGIN {print ($USED_MEM_MB / $TOTAL_MEM_MB) * 100}")
    echo "$PERCENTAGE"
}

while check_memory_usage
do

# Получение текущего процентного использования памяти
USAGE=$(check_memory_usage)
#echo $(date +"%d %b %H:%M:%S") Memory usage: $USAGE% >> /root/nesa.log

# Проверка, если использование памяти более 25%
if (( $(echo "$USAGE > 80" | bc -l) )); then
    echo $(date +"%d %b %H:%M:%S") "(Warning) Memory usage by uvicorn is above 50%. Restarting orchestrator!" >> /root/nesa.log
    echo $(date +"%d %b %H:%M:%S") "Warning!!!"
    docker restart orchestrator
else
#    echo $(date +"%d %b %H:%M:%S") Memory usage: $USAGE%
    sleep 30	
fi
done
