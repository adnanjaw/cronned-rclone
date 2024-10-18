# Cronned-rclone [![Test cronned-rclone](https://github.com/adnanjaw/cronned-rclone/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/adnanjaw/cronned-rclone/actions/workflows/test.yml) | [![Release cronned-rclone](https://github.com/adnanjaw/cronned-rclone/actions/workflows/release.yml/badge.svg)](https://github.com/adnanjaw/cronned-rclone/actions/workflows/release.yml)

A lightweight container tool that wraps Rclone with cron jobs using Ofelia. Easily schedule Rclone commands with
flexible cron expressions via INI-style configurations or Docker labels, while utilizing all standard Rclone commands.

## Features

- **Rclone Integration**: Leverage the powerful [Rclone](https://rclone.org/) for cloud operations (sync, copy, move,
  etc.).
- **Ofelia Scheduler**: Schedule tasks easily with [Ofelia](https://github.com/mcuadros/ofelia) and cron jobs.

---

## Prerequisites

Before you begin, ensure you have the following installed on your system:

- [Docker](https://docs.docker.com/get-docker/)
- A basic understanding of [Rclone](https://rclone.org/) and cron job scheduling
  using [Ofelia](https://github.com/mcuadros/ofelia).

---

## Usage

### 1. Create a Configuration File

Define your cron jobs using a configuration file (e.g., `config.ini`). Refer to
the [Ofelia documentation](https://github.com/mcuadros/ofelia) for more details on available parameters.

#### Example `config.ini`:

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

### 2. Run the Container

After preparing your configuration file, run the `cronned-rclone` Docker container. Ensure your config file is
accessible at the root of your project (e.g., `/project`).

```bash
docker run --name cronned-rclone \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /path/to/ofelia/config.ini:/config/ofelia.ini \
  -v /path/to/your/rclone/config:/config/rclone \
  -v /path/to/your/rclone/logs:/logs \
  -v /path/to/your/rclone/data:/data \
  adnanjaw/cronned-rclone:latest
  daemon --config=/config/ofelia.ini
```

Incase you are using Ofelia labels you can add this command at the end of your docker run or in docker compose `command`

```bash
 daemon --docker
```

#### Run with Docker Compose

To run the container using Docker Compose, create a `docker-compose.yml` file:

```yaml
services:
  cronned-rclone:
    image: 'adnanjaw/cronned-rclone:latest'
    command: daemon --config=/config/ofelia.ini
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /path/to/ofelia/config.ini:/config/ofelia.ini
      - /path/to/your/rclone/data:/data
      - /path/to/your/rclone/logs:/logs
      - /path/to/your/rclone/config:/config/rclone
    container_name: cronned-rclone
```

### 3. Verify Cron Jobs

The cron jobs will execute according to the schedule specified in your configuration file. Logs will be saved in the
respective log files you specify in the configuration, or you can receive notifications via Slack or email based on your
setup.

---

## Building the Image Locally

If you want to modify the Docker image or build it locally, follow these steps:

1. Clone this repository:
   ```bash
   git clone git@github.com:adnanjaw/cronned-rclone.git
   ```

2. Build and run the Docker image using Taskfile:
   ```bash
   docker run --name cronned-rclone \
      -v /var/run/docker.sock:/var/run/docker.sock:ro \
      -v ./config.ini:/config/ofelia.ini \
      -v ./config.conf:/config/rclone \
      cronned-rclone daemon --config=/config/ofelia.ini
   ```

---

## Contributing

We welcome contributions! Here’s how you can help:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -m 'Add new feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Open a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

## Credits

- [Rclone](https://rclone.org/) for the amazing tool to manage cloud storage.
- [Ofelia](https://github.com/mcuadros/ofelia) for cron job scheduling.
