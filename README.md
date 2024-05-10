# Google Drive Exporter

A Docker image for exporting files to Google Drive.

## Quick reference
 * Docker Hub repository [here](https://hub.docker.com/repository/docker/adnanjaw/google-drive-file-exporter/general).

## Usage with Docker command

```bash
docker run -d \
    --name google-drive-file-exporter \
    -e GOOGLE_FOLDER_ID="1dyUEebJaFnWa3Z4n0BFMVAXQ" \
    -e KEEP_CONTAINER_RUNNING=true \
    -v $(pwd)/files:/archive \
    -v $(pwd)/service-account-credentials.json:/service-account-credentials.json:ro \
    adnanjaw/google-drive-file-exporter:latest
```

## Usage in Docker Compose:

```yaml
google-drive-file-exporter:
   image: adnanjaw/google-drive-file-exporter:latest
   container_name: google-drive-file-exporter
   environment:
      GOOGLE_FOLDER_ID: "1dyUEebJaFnWa3Z4n0BFMVAXQ"
      KEEP_CONTAINER_RUNNING: true
   restart: unless-stopped
   volumes:
      - ./files:/archive
      - ./service-account-credentials.json:/service-account-credentials.json:ro
```

Ensure that you mount the service account credentials file (service-account-credentials.json) as read-only (:ro) to maintain security.

---

## Development

### Installation

Before you begin, make sure you have the following prerequisites:

- Docker (for local development)
- Docker compose (for local development)
- Taskfile.dev (optional)

Follow these steps to set up your development environment:

1. **Clone this Repository**:

   ```bash
   git clone git@github.com:adnanjaw/google-drive-file-exporter.git google-drive-exporter
   cd google-drive-exporter
   ```

2. **Create secrets**:

   1. `cp .env.example .env`
   2. Create a Google service account and generate a key in JSON format.
   3. `touch service-account-credentials.json` and paste the JSON key into the created file.

3. **Start Docker Containers and Initialize the Application**:

   ```bash
   task up
   ```