
# Croned-rclone

Is a lightweight containerized tool that wraps [Rclone](https://rclone.org/) with cron jobs. It allows users to schedule Rclone commands using cron jobs defined in a JSON or YAML configuration file. Users can keep using Rclone commands and refer to its documentation while managing schedules through a simple configuration.

## Features
- Uses Rclone for powerful cloud storage operations like sync, copy, move, etc.
- Schedules Rclone operations using cron jobs.
- Supports both JSON and YAML configuration files.
- Allows flexible scheduling with customizable cron expressions.

---

## Prerequisites
- [Docker](https://docs.docker.com/get-docker/) installed on your system.
- A basic understanding of [Rclone](https://rclone.org/) and cron job scheduling.

---

## Usage

### 1. Create a Configuration File
You can use either a JSON or YAML configuration file to define your cron jobs.

#### JSON Example (`crontab-config.json`):
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

#### YAML Example (`crontab-config.yml`):
```yaml
cronjobs:
  - schedule: "0 2 * * *"
    command: "rclone sync /local/directory remote:backup"
    log_file: "/var/log/rclone_backup.log"

  - schedule: "30 3 * * *"
    command: "rclone copy /local/photos remote:photos-backup"
    log_file: "/var/log/rclone_photos.log"
```

- **schedule**: The cron schedule expression.
- **command**: The Rclone command to run (sync, copy, etc.).
- **log_file**: Path to the log file where the command's output will be logged.

### 2. Run the Container
Once your configuration file is ready, you can run the `croned-rclone` Docker container. Be sure to mount your configuration file to the `/config/` directory inside the container.

#### Run with JSON:
```bash
docker run -v /path/to/your/crontab-config.json:/config/crontab-config.json croned-rclone
```

#### Run with YAML:
```bash
docker run -v /path/to/your/crontab-config.yml:/config/crontab-config.yml croned-rclone
```

### 3. Verify Cron Jobs
The cron jobs will run according to the schedule specified in your configuration file. Logs will be saved in the respective log files you specify in the configuration.

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
Logs for each Rclone command will be saved in the files specified under `log_file` in your configuration file. Ensure the paths you provide for log files exist in the container and are writable.

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