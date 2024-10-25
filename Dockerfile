FROM mcuadros/ofelia:latest AS ofelia

FROM rclone/rclone:latest AS rclone

FROM alpine:latest

LABEL maintainer="github.com/adnanjaw"

# this label is required to identify container with ofelia running
LABEL ofelia.service=true
LABEL ofelia.enabled=true

COPY --from=ofelia /usr/bin/ofelia /usr/local/bin/ofelia

COPY --from=rclone /usr/local/bin/rclone /usr/local/bin/rclone

RUN mkdir -p /config/rclone

ENV RCLONE_CONFIG=/config/rclone/rclone.conf

ENTRYPOINT ["/usr/local/bin/ofelia"]
