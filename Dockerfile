# Stage 1: Build Rclone
FROM rclone/rclone:latest AS rclone

# Stage 2: Create final image.
FROM alpine:3.16

LABEL maintainer="github.com/adnanjaw"

# Install cron, jq (for JSON), yq (for YAML), and bash
RUN apk add --no-cache bash curl jq yq

# Copy Rclone binary from the first stage
COPY --from=rclone /usr/local/bin/rclone /usr/local/bin/rclone

# Copy the startup.sh script to the container
COPY ./startup.sh /startup.sh

# Ensure the startup script is executable
RUN chmod +x /startup.sh

# Start the cron jobs using the startup.sh script
CMD ["/startup.sh"]
