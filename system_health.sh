#!/bin/bash
# System Health Monitoring Script
#
#
# Thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=90
#
#
# Log file
LOG_FILE="./system_health.log"
touch "$LOG_FILE"

log () {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}

# 1. CPU Check
cpu_usage=$( top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' )
idle=$( top -bn1 | grep "Cpu(s)" | awk '{ print $8 }' )


if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) ))
then
	log "cpu usage is high:  $cpu_usage% (Threshold: $CPU_THRESHOLD%)"
else
	log "The CPU usage: $cpu_usage% |  idle: $idle%"
fi



# 2. Memory Usage
read total used free <<< $(free -m | awk 'NR==2 {printf "%s %s %s", $2,$3,$4}')
mem_usage=$( echo "scale=2; $used/$total*100" | bc )

if (( $( echo "$mem_usage > $MEM_THRESHOLD" | bc -l) ))
then
	log "mem usage is high:  $mem_usage% (Threshold: $MEM_THRESHOLD%)"
else
	log "mem usage is normal: $mem_usage%"
fi



# 3. Disk Usage
df -h | awk 'NR > 1 {print $1 " " $5}' | while read -r filename usage
do
	usage=${usage%\%}
	
	if [ $usage -gt $DISK_THRESHOLD ]
	then
		log "Disk usage is high: $filename($usage%)"
	else
		log "Disk usage is normal: $filename($usage%)"
	fi
done



# 4. Running Processes
total_high_usage=0
while read -r PID CPU MEM COMMAND
do
	if (( $( echo "$MEM > $MEM_THRESHOLD || $CPU > $CPU_THRESHOLD" | bc -l) ))
	then
		(( total_high_usage++ ))
		log "High usage Process: $PID | CPU: $CPU% | MEM: $MEM%	| COMMAND: $COMMAND"
	fi
done < <(ps aux | awk 'NR>1 {print $2 " " $3 " " $4 " " $11}')

log "==================================================================================="
log "The total high usage processes: $total_high_usage"
log "==================================================================================="


# Exit code
if [ $total_high_usage -gt 0 ]
then
	exit 1
else
	exit 0
fi













