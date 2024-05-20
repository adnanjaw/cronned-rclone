#!/bin/bash

validate_cron() {
  local cron_exp="$1"
  # Updated regex for standard cron expression validation
  local cron_regex="^(\*|([0-5]?[0-9])) (\*|([01]?[0-9]|2[0-3])) (\*|([01]?[0-9]|2[0-3]|3[01])) (\*|([1-9]|1[0-2])) (\*|([0-6]))$"

  if [[ $cron_exp =~ $cron_regex ]]; then
    return 0
  else
    return 1
  fi
}

# Ensure the cron schedule is provided
if [ -z "$CRON_EXPRESSION" ]; then
  echo "CRON_EXPRESSION environment variable is not set."
  # Keep the container running if KEEP_CONTAINER_RUNNING is set
  if [ -n "$KEEP_CONTAINER_RUNNING" ]; then
    echo "KEEP_CONTAINER_RUNNING is set, Keeping the container running."
    tail -f /dev/null
  else
    echo "CRON_EXPRESSION is not set, Exiting."
    exit 1
  fi
fi

# Validate the cron schedule
if ! validate_cron "$CRON_EXPRESSION"; then
  echo "CRON_EXPRESSION has an invalid value, Exiting."
  exit 1
fi

# Create a cron job file
echo "$CRON_EXPRESSION /usr/local/bin/python /app/google-drive-file-exporter.py >> /var/log/cron.log 2>&1" > /etc/cron.d/google_exporter_cron_tab

# Apply the cron job file
crontab /etc/cron.d/google_exporter_cron_tab

# Give execution rights on the cron job file
chmod 0744 /etc/cron.d/google_exporter_cron_tab

# Create the log file to be able to run tail
touch /var/log/cron.log

# Start cron
cron

# Keep the container running
tail -f /var/log/cron.log