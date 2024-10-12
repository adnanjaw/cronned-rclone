#!/bin/bash
set -x  # Enable debugging output

# Define paths
CONFIG_PATH="/config/crontab-config.json"
CRON_FILE="/etc/cron.d/rclone-cron"
LOG_FILE="/var/log/cron.log"

# Clean up previous cron jobs file
rm -f $CRON_FILE

# Create the cron file if it doesn't exist
touch $CRON_FILE

# Initialize a flag to check for validation errors
VALIDATION_ERRORS=0

# Function to validate cron schedule syntax
validate_cron_schedule() {
    local schedule=$1
    # Split the schedule into an array
    IFS=' ' read -r minute hour day month week <<< "$schedule"

    # Validate each field separately
#    validate_field() {
##        local field="$1"
##        local type="$2"
##
##        # Each field can contain:
##        # - * (every value)
##        # - <number>
##        # - <number>-<number> (range)
##        # - <number>,<number>,... (list)
##        # - <number>/<number> (step)
##        # - * / <number> (step)
##
##        case $type in
##            minute)
##                if ! [[ "$field" =~ ^(\*|([0-5]?[0-9](,[0-5]?[0-9])*)|([0-5]?[0-9]-[0-5]?[0-9])|([0-5]?[0-9]/[1-9][0-9]*|([0-5]?[0-9])$ ]]; then
##                    return 1
##                fi
##                ;;
##            hour)
##                if ! [[ "$field" =~ ^(\*|([01]?[0-9]|2[0-3](,[01]?[0-9]|2[0-3])*)|([01]?[0-9]|2[0-3])-[0-2][0-3]|([01]?[0-9]|2[0-3]/[1-9][0-9]*)$ ]]; then
##                    return 1
##                fi
##                ;;
##            day)
##                if ! [[ "$field" =~ ^(\*|([1-9]|[12][0-9]|3[01](,[1-9]|[12][0-9]|3[01])*)|([1-9]|[12][0-9]|3[01])-[1-9]|[12][0-9]|3[01]|([1-9]|[12][0-9]|3[01]/[1-9][0-9]*)$ ]]; then
##                    return 1
##                fi
##                ;;
##            month)
##                if ! [[ "$field" =~ ^(\*|((0?[1-9]|1[0-2])(,(0?[1-9]|1[0-2]))*)|((0?[1-9]|1[0-2])-(0?[1-9]|1[0-2])|([0-1]?[0-9]|1[0-2]/[1-9][0-9]*))$ ]]; then
##                    return 1
##                fi
##                ;;
##            week)
##                if ! [[ "$field" =~ ^(\*|([0-6](,[0-6])*)|([0-6]-[0-6]|([0-6]/[1-9][0-9]*)$ ]]; then
##                    return 1
##                fi
##                ;;
##            *)
##                return 1  # Unknown field type
##                ;;
##        esac
##        return 0  # Valid field
#    }
#
#    # Validate each field
#    validate_field "$minute" minute || { echo "Invalid minute field: $minute" | tee -a $LOG_FILE; VALIDATION_ERRORS=1; return; }
#    validate_field "$hour" hour || { echo "Invalid hour field: $hour" | tee -a $LOG_FILE; VALIDATION_ERRORS=1; return; }
#    validate_field "$day" day || { echo "Invalid day field: $day" | tee -a $LOG_FILE; VALIDATION_ERRORS=1; return; }
#    validate_field "$month" month || { echo "Invalid month field: $month" | tee -a $LOG_FILE; VALIDATION_ERRORS=1; return; }
#    validate_field "$week" week || { echo "Invalid week field: $week" | tee -a $LOG_FILE; VALIDATION_ERRORS=1; return; }
}


# Parse crontab-config.json
if [ -f "$CONFIG_PATH" ]; then
    echo "Processing crontab-config.json..." | tee -a $LOG_FILE
    # Read and validate each cron job from JSON
    jq -c '.cron_jobs[]' $CONFIG_PATH | while read -r job; do
        SCHEDULE=$(echo "$job" | jq -r '.schedule')
        TASK=$(echo "$job" | jq -r '.task')

        # Validate schedule
        validate_cron_schedule "$SCHEDULE"

        # Log the cron job with the actual command to run
        if [ "$VALIDATION_ERRORS" -eq 0 ]; then
            echo "$SCHEDULE $TASK >> $LOG_FILE 2>&1" >> $CRON_FILE
            echo "Cron job added: $SCHEDULE $TASK" | tee -a $LOG_FILE
        fi
    done
else
    echo "No valid configuration file found!" | tee -a $LOG_FILE
    exit 1
fi

# If validation passed, apply the cron jobs
if [ "$VALIDATION_ERRORS" -eq 0 ]; then
    # Set cron file permissions and apply cron jobs
    chmod 0644 $CRON_FILE
    crontab $CRON_FILE
    echo "Cron jobs applied successfully." | tee -a $LOG_FILE
else
    echo "Errors in configuration. No cron jobs applied." | tee -a $LOG_FILE
    exit 1
fi

# Start cron in the foreground
crond -f
