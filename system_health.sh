#!/bin/bash
# System Health Monitoring Script
#
#
# Thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=90


# 1. CPU Check
cpu_usage=$( top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' )
idle=$( top -bn1 | grep "Cpu(s)" | awk '{ print $8 }' )


if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) ))
then
	echo "cpu usage is high:  $cpu_usage% (Threshold: {$CPU_THRESHOLD})"
else
	echo The CPU usage: $cpu_usage%
	echo The CPU idle: $idle%	
fi



# 2. Memory Usage
read total used free <<< $(free -m | awk 'NR==2 {printf "%s %s %s", $2,$3,$4}')
mem_usage=$( echo "scale=2; $used/$total*100" | bc )

if (( $( echo "$mem_usage > $MEM_THRESHOLD" | bc -l) ))
then
	echo "mem usage is high:  $mem_usage% (Threshold: {$MEM_THRESHOLD})"
else
	echo mem usage is normal: $mem_usage%
fi



# 3. Disk Usage
df -h | awk 'NR > 1 {print $1 " " $5}' | while read -r filename usage
do
	usage=${usage%\%}
	
	if [ $usage -gt $DISK_THRESHOLD ]
	then
		echo "Disk usage is high: $filename($usage%)"
	else
		echo "Disk usage is normal: $filename($usage%)"
	fi
done


total_high_usage=0
count=0
# 4. Running Processes.
ps aux | awk 'NR>1 {print $2 " " $3 " " $4 " " $11}' | while read -r PID CPU MEM COMMAND
do
	count=$(( count + 1 ))
	if (( $( echo "$MEM > $MEM_THRESHOLD || $CPU > $CPU_THRESHOLD" | bc -l) ))
	then
		(( total_high_usage++ ))
		echo "High CPU/MEM Usage Detected
			Process: $PID | CPU: $CPU% | MEM: $MEM%	| COMMAND: $COMMAND
		"
	fi
done

echo "The total high usage processes: $total_high_usage"
echo "$count"















