# Croned-rclone

A lightweight container tool that wraps Rclone with cron jobs.
Schedule Rclone commands using a simple JSON or YAML configuration file while still using all standard Rclone commands
and documentation.

## Features

- Uses [Rclone](https://rclone.org/) for cloud operations (sync, copy, move, etc.).
- Schedules tasks with cron jobs.
- Supports JSON and YAML config files.
- Flexible scheduling with custom cron expressions.

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed on your system.
- A basic understanding of [Rclone](https://rclone.org/) and cron job scheduling.

---

## Usage

### 1. Create a Configuration File

Define your cron jobs using either a JSON or YAML config file. You can name it whatever you want, but make sure to mount
it to `/config/crontab-config.(json|yml)`. See .dist files in the repository for more details.

#### JSON Example:

```json
{
  "cronjobs": [
    {
      "schedule": "0 2 * * *",
      "command": "rclone sync /local/directory remote:backup",
      "log_file": "/var/log/rclone_backup.log"
    },
    {
      "schedule": "30 3 * * *",
      "command": "rclone copy /local/photos remote:photos-backup",
      "log_file": "/var/log/rclone_photos.log"
    }
  ]
}
```

#### YAML Example:

```yaml
cronjobs:
  - schedule: "0 2 * * *"
    command: "rclone sync /local/directory remote:backup"
    log_file: "/var/log/rclone_backup.log"

  - schedule: "30 3 * * *"
    command: "rclone copy /local/photos remote:photos-backup"
    log_file: "/var/log/rclone_photos.log"
```

- **schedule**: Cron expression for scheduling.
- **command**: Rclone command (sync, copy, echo etc.).
- **log_file**: Log file path for output.

### 2. Run the Container

After preparing your configuration file, run the `croned-rclone` Docker container. Ensure your config file is mounted to
the `/config/` directory inside the container.

#### Run with JSON:
```bash
docker run --name croned-rclone \ 
  -v /path/to/your/crontab-config.json:/config/crontab-config.json \
  -v /path/to/your/rclone/config:/config/rclone
  -v /path/to/your/rclone/logs:/logs
  -v /path/to/your/rclone/data:/data
  adnanjaw/croned-rclone:latest
```

#### Run with YAML:

```bash
docker run --name croned-rclone \ 
  -v /path/to/your/crontab-config.yml:/config/crontab-config.yml \
  -v /path/to/your/rclone/config:/config/rclone
  -v /path/to/your/rclone/logs:/logs
  -v /path/to/your/rclone/data:/data
  adnanjaw/croned-rclone:latest
```
#### Run with Docker compose:
```bash
version: '3.9'
services:
    croned-rclone:
        image: 'adnanjaw/croned-rclone:latest'
        volumes:
            - '/path/to/your/rclone/data:/data'
            - '/path/to/your/rclone/logs:/logs'
            - '/path/to/your/rclone/config:/config/rclone'
            - '/path/to/your/crontab-config.json:/config/crontab-config.json'
        container_name: croned-rclone
```
### 3. Verify Cron Jobs

The cron jobs will run according to the schedule specified in your configuration file. Logs will be saved in the
respective log files you specify in the configuration.

---

## Cron Job Scheduling

The cron schedule format follows the typical syntax:

```
* * * * * <command>
| | | | |
| | | | ----- Day of the week (0 - 7) (Sunday is both 0 and 7)
| | | ------- Month (1 - 12)
| | --------- Day of the month (1 - 31)
| ----------- Hour (0 - 23)
------------- Minute (0 - 59)
```

For example:

- `0 2 * * *` means "every day at 2:00 AM."
- `30 3 * * *` means "every day at 3:30 AM."

You can use [crontab.guru](https://crontab.guru/) to easily create and validate cron expressions.

---

## Logs

Logs for each Rclone command will be saved in the files specified under `log_file` in your configuration file. Ensure
the paths you provide for log files exist in the container and are writable.

---

## Example Commands

- **Sync directory to remote backup**:
  ```bash
  rclone sync /local/directory remote:backup
  ```

- **Copy files to remote backup**:
  ```bash
  rclone copy /local/photos remote:photos-backup
  ```

Refer to the [Rclone Documentation](https://rclone.org/docs/) for more command examples.

---

## Building the Image Locally

If you want to modify the Docker image or build it locally:

1. Clone this repository:
   ```bash
   git clone git@github.com:adnanjaw/croned-rclone.git
   ```

2. Build and run the Docker image:
    ```text
    hint: make user of Taskfile.yml
    ```

   ```bash
   task up -- -v /path/to/your/crontab-config.json:/config/crontab-config.json
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
hint: make user of Taskfile.yml
```

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

---

## Credits

- [Rclone](https://rclone.org/) for the amazing tool to manage cloud storage.
- Docker and Alpine for lightweight containerization.