# Contributing

We welcome contributions! Here’s how you can help:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -m 'Add new feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Open a pull request.

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

