FROM mcuadros/ofelia:latest AS ofelia

FROM rclone/rclone:latest AS rclone

FROM alpine:latest

LABEL maintainer="github.com/adnanjaw"

# Copy Ofelia binary from the ofelia image
COPY --from=ofelia /usr/bin/ofelia /usr/local/bin/ofelia

# Copy Rclone binary from the rclone image
COPY --from=rclone /usr/local/bin/rclone /usr/local/bin/rclone

COPY config.ini /etc/ofelia.ini

# Run Ofelia daemon to handle job scheduling
CMD ["ofelia", "daemon", "--config=/etc/ofelia.ini"]
