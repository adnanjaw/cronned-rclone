#!/bin/bash

# Function to add a cron job to crontab
add_cron_job() {
    local schedule="$1"
    local command="$2"
    local log_file="$3"

    # Add the cron job to the crontab file for root
    echo "$schedule $command >> $log_file 2>&1" >> /etc/crontabs/root
}

# Check if the user has mounted a valid configuration file
if [[ -f /config/crontab-config.yml ]]; then
    config_file="/config/crontab-config.yml"
    file_type="yaml"
elif [[ -f /config/crontab-config.json ]]; then
    config_file="/config/crontab-config.json"
    file_type="json"
else
    echo "No valid configuration file found! Please mount either a .yml or .json file to /config/crontab-config.yml or /config/crontab-config.json."
    exit 1
fi

# Process the configuration file based on file type
if [[ "$file_type" == "yaml" ]]; then
    echo "Processing YAML configuration file: $config_file"

    # Extract cron jobs from the YAML file using yq
    cronjobs=$(yq eval '.cronjobs' "$config_file")

    # Loop through cronjobs in YAML
    index=0
    while true; do
        schedule=$(yq eval ".cronjobs[$index].schedule" "$config_file")
        rclone_command=$(yq eval ".cronjobs[$index].commandcommand" "$config_file")
        log_file=$(yq eval ".cronjobs[$index].log_file" "$config_file")

        if [[ -z "$schedule" ]]; then
            break
        fi

        # Add the cron job
        add_cron_job "$schedule" "$rclone_command" "$log_file"

        # Move to the next job
        index=$((index + 1))
    done

elif [[ "$file_type" == "json" ]]; then
    echo "Processing JSON configuration file: $config_file"

    # Extract cron jobs from the JSON file using jq
    cronjobs=$(jq -c '.cronjobs[]' "$config_file")

    # Loop through cronjobs in JSON
    for job in $cronjobs; do
        schedule=$(echo $job | jq -r '.schedule')
        rclone_command=$(echo $job | jq -r '.command')
        log_file=$(echo $job | jq -r '.log_file')

        # Add the cron job
        add_cron_job "$schedule" "$rclone_command" "$log_file"
    done
fi

# Ensure correct permissions for the crontab file
chmod 0644 /etc/crontabs/root

# Start the cron service
crond -f
