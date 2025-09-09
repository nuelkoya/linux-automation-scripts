#!/bin/bash
# ===========================================================================
# Log Management Automation Script
# Author: Adetola Olukoya
# Description: Compress old log files after X days and move archived log to a backup folder

log_dir=$1

log_arch="/home/adetola/Desktop/log_archives"
echo "$log_arch"

# Check if directory exists
if [ ! -d "$log_dir" ] 
then
	echo "Error: Directory $log_dir does not exist."
	exit 1
fi


# Ser reference date (7 days ago)
lapsed_date=$( date --date='7 days ago' +%s)



find "$log_dir" -type f -name "*.log*" | while IFS= read -r filename dirname
do
	echo "$filename"
	last_modified=$( stat -c %Y "$filename" | awk '{print $1}' )

	if (( $last_modified > $lapsed_date ))
	then
		relative_path=${filename#$log_dir}
		arch_file="$relative_path.tar.gz"
		arch_path="$log_arch$arch_file"
		echo "$arch_path"

		#if [ ! -f "$arch_file" ]
		#then
		#	touch "$arch_file"
		#	tar -czf "$filename" "$arch_file"
		#else
		#	echo "File exist: $arch_file"
		#fi
	fi	
done
