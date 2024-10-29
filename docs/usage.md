# Usage

## 1. Create a Configuration File

Define your cron jobs using a configuration file (e.g., `config.ini`). Refer to
the [Ofelia documentation](https://github.com/mcuadros/ofelia) for more details on available parameters.

### - Example `config.ini`

```ini
### Jobs Reference Documentation: https://github.com/mcuadros/ofelia/blob/master/docs/jobs.md ###
[job-exec "job-executed-on-running-container"]
schedule = @hourly
container = my-container
command = touch /tmp/example

[job-run "job-executed-on-new-container"]
schedule = @hourly
image = ubuntu:latest
command = touch /tmp/example

[job-local "job-executed-on-current-host"]
schedule = @hourly
command = touch /tmp/example

[job-service-run "service-executed-on-new-container"]
schedule = 0,20,40 * * * *
image = ubuntu
network = swarm_network
command = touch /tmp/example

[global]
### Logging Settings ###
save-folder = /logs
save-only-on-error = false

### Email Settings ###
smtp-host = smtp.example.com
smtp-port = 587
smtp-user = username
smtp-password = password
email-to = recipient@example.com
email-from = sender@example.com
mail-only-on-error = true

### Slack Notifications ###
slack-webhook = https://hooks.slack.com/services/your/webhook/url
slack-only-on-error = true
```

## 2. Run the Container

After preparing your configuration file, run the `cronned-rclone` Docker container.

```bash
docker run --name cronned-rclone \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v ${PWD}/ofelia/config.ini:/config/ofelia.ini \
  -v ${PWD}/rclone/rclone.conf:/config/rclone/rclone.conf \
  -v ${PWD}/rclone/logs:/logs \
  -v ${PWD}/rclone/data:/data \
  adnanjaw/cronned-rclone:latest daemon --config=/config/ofelia.ini
```

### - Labels

In case you are using Ofelia labels, you can add this command at the end of your Docker run or Docker Compose command.

```bash
docker run --name cronned-rclone \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v ${PWD}/rclone/rclone.conf:/config/rclone/rclone.conf \
  -v ${PWD}/rclone/logs:/logs \
  -v ${PWD}/rclone/data:/data \
  -v ${PWD}/test.txt:/tmp/test.txt \
  --label ofelia.enabled=true \
  --label ofelia.job-local.upload-file.schedule="@every 60s" \
  --label ofelia.job-local.upload-file.command="rclone copy /tmp/test.txt s3:/bucket/directory" \
  adnanjaw/cronned-rclone:latest daemon --docker
```

### - Run with Docker Compose

To run the container using Docker Compose, create a `compose.yaml` file:

```yaml
services:
  cronned-rclone:
    image: adnanjaw/cronned-rclone:latest
    command: daemon --config=/config/ofelia.ini
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./ofelia/config.ini:/config/ofelia.ini
      - ./rclone/data:/data
      - ./rclone/logs:/logs
      - ./rclone/config:/config/rclone
```

### - Labels

```yaml
services:
  cronned-rclone:
    image: adnanjaw/cronned-rclone:latest
    command: daemon --docker
    labels:
      ofelia.enabled: true
      ofelia.job-local.upload-file.schedule: "@every 60s"
      ofelia.job-local.upload-file.command: "rclone copy /tmp/test.txt s3:/bucket/directory"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./rclone/data:/data
      - ./rclone/logs:/logs
      - ./rclone/config:/config/rclone
      - ./test.txt:/tmp/test.txt
```

## 3. Verify Cron Jobs

The cron jobs will execute according to the schedule specified in your configuration file. Logs will be saved in the
respective log files you specify in the configuration, or you can receive notifications via Slack or email based on your
setup.