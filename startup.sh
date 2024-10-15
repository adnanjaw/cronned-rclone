#!/bin/bash

set -euo pipefail

# Ensure the script is run as root (cron jobs typically require root privileges)
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Configuration
LOG_FILE="/var/log/cron_setup.log"
CONFIG_DIR="/config"
YAML_CONFIG="${CONFIG_DIR}/crontab-config.yml"
JSON_CONFIG="${CONFIG_DIR}/crontab-config.json"
LOCK_FILE="/var/run/cron_setup.lock"

# Function to log messages
log_message() {
    local log_type="$1"
    local log_message="$2"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $log_type: $log_message" | tee -a "$LOG_FILE"
}

# Function to add a cron job to crontab
add_cron_job() {
    local schedule="$1"
    local command="$2"
    local log_file="$3"

    # Validate input
    if [[ -z "$schedule" || -z "$command" || -z "$log_file" ]]; then
        log_message "ERROR" "One of the fields (schedule, command, or log_file) is empty."
        return 1
    fi

    # Validate cron schedule format (basic check)
    if ! echo "$schedule" | grep -qE '^(\*|[0-9]+|\*/[0-9]+)\s+(\*|[0-9]+|\*/[0-9]+)\s+(\*|[0-9]+|\*/[0-9]+)\s+(\*|[0-9]+|\*/[0-9]+)\s+(\*|[0-9]+|\*/[0-9]+)$'; then
        log_message "ERROR" "Invalid cron schedule format: $schedule"
        return 1
    fi

    # Add the cron job
    if ! (crontab -l 2>/dev/null; echo "$schedule $command >> $log_file 2>&1") | crontab -; then
        log_message "ERROR" "Failed to add cron job: $schedule $command >> $log_file"
        return 1
    fi

    log_message "INFO" "Cron job added successfully: $schedule $command >> $log_file"
}

# Function to process YAML config
process_yaml_config() {
    local config_file="$1"
    log_message "INFO" "Processing YAML configuration file: $config_file"

    if ! command -v yq &> /dev/null; then
        log_message "ERROR" "yq is not installed. Please install yq to process YAML files."
        exit 1
    fi

    yq eval '.cronjobs[]' "$config_file" | while read -r job; do
        local schedule=$(echo "$job" | yq eval '.schedule' -)
        local command=$(echo "$job" | yq eval '.command' -)
        local log_file=$(echo "$job" | yq eval '.log_file' -)

        add_cron_job "$schedule" "$command" "$log_file"
    done
}

# Function to process JSON config
process_json_config() {
    local config_file="$1"
    log_message "INFO" "Processing JSON configuration file: $config_file"

    if ! command -v jq &> /dev/null; then
        log_message "ERROR" "jq is not installed. Please install jq to process JSON files."
        exit 1
    fi

    jq -c '.cronjobs[]' "$config_file" | while read -r job; do
        local schedule=$(echo "$job" | jq -r '.schedule')
        local command=$(echo "$job" | jq -r '.command')
        local log_file=$(echo "$job" | jq -r '.log_file')

        add_cron_job "$schedule" "$command" "$log_file"
    done
}

# Function to check and create lock file
create_lock() {
    if [ -e "$LOCK_FILE" ]; then
        log_message "ERROR" "Another instance is running. Exiting."
        exit 1
    fi
    touch "$LOCK_FILE"
}

# Function to remove lock file
remove_lock() {
    rm -f "$LOCK_FILE"
}

# Main script logic
main() {
    create_lock
    trap remove_lock EXIT

    if [[ -f "$YAML_CONFIG" ]]; then
        process_yaml_config "$YAML_CONFIG"
    elif [[ -f "$JSON_CONFIG" ]]; then
        process_json_config "$JSON_CONFIG"
    else
        log_message "ERROR" "No valid configuration file found! Please mount either a .yml or .json file to $YAML_CONFIG or $JSON_CONFIG."
        exit 1
    fi

    if ! pgrep crond >/dev/null; then
        log_message "INFO" "Starting cron service..."
        if ! crond -f; then
            log_message "ERROR" "Failed to start cron service."
            exit 1
        fi
    else
        log_message "INFO" "Cron service is already running."
    fi
}

# Execute the main function
main