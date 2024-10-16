# Cronned-rclone

A lightweight container tool that wraps Rclone with cron jobs using Ofelia.
Easily schedule Rclone commands with flexible cron expressions via INI-style configurations or Docker labels, while still utilizing all standard Rclone commands.

## Features

- Uses [Rclone](https://rclone.org/) for cloud operations (sync, copy, move, etc.).
- Uses [Ofelia](https://github.com/mcuadros/ofelia) Scheduling tasks with cron jobs.

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your system.
- A basic understanding of [Rclone](https://rclone.org/) and cron job scheduling using [Ofelia](https://github.com/mcuadros/ofelia).

---

## Usage

### 1. Create a Configuration File

Define your cron jobs using either a config.ini file. You can refer to [Ofelia](https://github.com/mcuadros/ofelia) documentation for more details.

#### Example:

```ini
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
command =  touch /tmp/example
```

### 2. Run the Container

After preparing your configuration file, run the `cronned-rclone` Docker container. Ensure your config file is available at root of your project `/project`.

```bash
docker run --name cronned-rclone \
  -v /var/run/docker.sock:/var/run/docker.sock:ro
  -v /path/to/your/rclone/config:/config/rclone \
  -v /path/to/your/rclone/logs:/logs \
  -v /path/to/your/rclone/data:/data \
  adnanjaw/cronned-rclone:latest
```

#### Run with Docker Compose:
```yaml
version: '3.9'
services:
  cronned-rclone:
    image: 'adnanjaw/cronned-rclone:latest'
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - '/path/to/your/rclone/data:/data'
      - '/path/to/your/rclone/logs:/logs'
      - '/path/to/your/rclone/config:/config/rclone'
    container_name: cronned-rclone
```

### 3. Verify Cron Jobs

The cron jobs will run according to the schedule specified in your configuration file. Logs will be saved in the respective log files you specify in the configuration.

---

## Building the Image Locally

If you want to modify the Docker image or build it locally:

1. Clone this repository:
   ```bash
   git clone git@github.com:adnanjaw/cronned-rclone.git
   ```

2. Build and run the Docker image:
   ```text
   hint: make use of Taskfile.yml
   ```

   ```bash
   task up
   ```
---

## Contributing

If you want to contribute to the project:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -m 'Add new feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Open a pull request.

```text
hint: make use of Taskfile.yml
```

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

## Credits

- [Rclone](https://rclone.org/) for the amazing tool to manage cloud storage.
- [Ofelia](https://github.com/mcuadros/ofelia) for cron job scheduling.
