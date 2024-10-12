# Cronjobbed Rclone

This project provides a Docker container that uses Rclone and cron jobs for automated tasks, all configured through a simple JSON file. The container includes a built-in cron service that is managed by a `startup.sh` script.

## Features
- **Rclone** for cloud storage sync and management.
- **Cron jobs** are dynamically set up from a JSON configuration file (`crontab-config.json`).
- Logs are stored within the container and can be exposed for easy monitoring.
- Easily configurable with Docker and Docker Compose.

## How to Use

### Prerequisites
Make sure you have Docker installed on your system. You can install it from [here](https://docs.docker.com/get-docker/).

### 1. Pull the Docker Image

You can build or pull the Docker image as follows:

#### Build the image locally:

```bash
docker build -t cronjobbed-rclone .

Pull from Docker Hub (if available):

docker pull yourusername/cronjobbed-rclone:latest

2. Configuration

Before running the container, you need to provide a JSON file (crontab-config.json) that defines the cron jobs you want to run. This file must be mounted into the container for the cron service to read and execute jobs.

Example crontab-config.json:

{
  "cron_jobs": [
    {
      "schedule": "* * * * *",
      "task": "echo 'Task 1 running!'"
    },
    {
      "schedule": "0 0 * * *",
      "task": "rclone sync /local/path remote:path"
    }
  ]
}

	•	schedule: Defines the cron schedule using standard cron syntax.
	•	task: The command to be executed at the specified schedule. This can be an Rclone command or any shell command.

3. Run the Container

Basic docker run Command

You can run the container with the following docker run command:

docker run -d \
    --name cronjobbed-rclone \
    -v /path/to/local/crontab-config.json:/config/crontab-config.json \
    -v /path/to/local/your-files:/data \
    cronjobbed-rclone

	•	-v /path/to/local/crontab-config.json:/config/crontab-config.json: Mounts the JSON file into the container.
	•	-v /path/to/local/your-files:/data: Mounts your local data directory into the container for Rclone to access.

Logs and Debugging

Logs are stored in /var/log/cron.log inside the container. You can check the logs using:

docker logs cronjobbed-rclone

If you need to enter the running container:

docker exec -it cronjobbed-rclone /bin/bash

4. Using Docker Compose

For a more streamlined setup, you can use Docker Compose to manage your container.

Create a docker-compose.yml file as follows:

version: '3.7'

services:
  cronjobbed-rclone:
    image: cronjobbed-rclone
    container_name: cronjobbed-rclone
    volumes:
      - ./crontab-config.json:/config/crontab-config.json
      - ./your-data:/data
    restart: always

Start the Service

To start the service with Docker Compose, simply run:

docker-compose up -d

This will run the container in detached mode (-d), and it will automatically restart in case of failure (restart: always).

5. Directory Structure Example

Here’s an example of how your project directory could be structured:

├── Dockerfile
├── docker-compose.yml
├── crontab-config.json
└── your-data/
    └── (Files to be synced by Rclone)

6. Stopping and Removing the Container

To stop and remove the container when it is no longer needed, use:

docker stop cronjobbed-rclone
docker rm cronjobbed-rclone

If using Docker Compose, you can shut it down using:

docker-compose down

7. Troubleshooting

If the container stops immediately after running:

	•	Ensure the crontab-config.json file is mounted correctly.
	•	Check the logs for any errors using docker logs cronjobbed-rclone.

If the cron jobs are not running:

	•	Validate the cron job syntax in the JSON configuration file.
	•	Make sure the correct volume paths are mounted for data access and configuration.

Contributions

Feel free to open issues or contribute by submitting a pull request on the GitHub repository.

License

This project is licensed under the MIT License - see the LICENSE file for details.
