FROM mcuadros/ofelia:latest AS ofelia

FROM rclone/rclone:latest AS rclone

FROM alpine:latest

LABEL maintainer="github.com/adnanjaw"

COPY --from=ofelia /usr/bin/ofelia /usr/local/bin/ofelia

COPY --from=rclone /usr/local/bin/rclone /usr/local/bin/rclone

# Run Ofelia daemon to handle job scheduling
CMD ["ofelia", "daemon", "--config=/config/ofelia.ini"]
