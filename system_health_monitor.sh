#!/bin/bash

CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=80

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
if [ $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc) -eq 1 ]; then
  echo "ALERT: CPU usage is ${CPU_USAGE}% > ${CPU_THRESHOLD}%" | tee -a /var/log/system_health.log
fi

MEM_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
if [ $(echo "$MEM_USAGE > $MEM_THRESHOLD" | bc) -eq 1 ]; then
  echo "ALERT: Memory usage is ${MEM_USAGE}% > ${MEM_THRESHOLD}%" | tee -a /var/log/system_health.log
fi

DISK_USAGE=$(df / | grep / | awk '{ print $5}' | sed 's/%//g')
if [ $DISK_USAGE -gt $DISK_THRESHOLD ]; then
  echo "ALERT: Disk usage is ${DISK_USAGE}% > ${DISK_THRESHOLD}%" | tee -a /var/log/system_health.log
fi

PROC_COUNT=$(ps aux | wc -l)
echo "Running processes: $PROC_COUNT" | tee -a /var/log/system_health.log