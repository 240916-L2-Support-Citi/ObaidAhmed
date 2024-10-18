#!/bin/bash

LOGFILE="/var/log/app.log"
DB="log_monitoring"
USER="obaidahmed"

# Loop reads the log file line by line
while IFS= read -r line; do
    # Checks if the line contains the string "ERROR" or "FATAL" 
    if [[ "$line" == *"ERROR"* || "$line" == *"FATAL"* ]]; then
	
	# Extract the timestamp, level, message from the log line
        TIMESTAMP=$(echo $line | awk '{print $1, $2}')  
        LEVEL=$(echo $line | awk '{print $3}')  
        MESSAGE=$(echo $line | cut -d' ' -f4-)  
	
	#Checks if the log exists already in the database
	EXISTS=$(/opt/homebrew/bin/psql -d $DB -U $USER -tAc "SELECT COUNT(*) FROM log_entries WHERE timestamp='$TIMESTAMP' AND log_level='$LEVEL' AND message='$MESSAGE'")
	
	# If it exists, insert it into the database
	if [ "$EXISTS" -eq 0 ]; then
            echo "Inserting new log entry: TIMESTAMP='$TIMESTAMP', LEVEL='$LEVEL', MESSAGE='$MESSAGE'"
            /opt/homebrew/bin/psql -d $DB -U $USER -c "INSERT INTO log_entries (timestamp, log_level, message) VALUES ('$TIMESTAMP', '$LEVEL', '$MESSAGE')"
        else
            echo "Log entry already exists: TIMESTAMP='$TIMESTAMP', LEVEL='$LEVEL', MESSAGE='$MESSAGE'"
        fi
    fi
done < "$LOGFILE"
