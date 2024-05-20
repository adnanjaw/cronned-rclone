FROM python:3.9-slim AS google-drive-file-exporter

LABEL maintainer="Adnan Al Jawabra"

WORKDIR /app

COPY . /app

RUN chmod +x /app/google-drive-file-exporter.py

# Install dependencies
RUN pip install -r requirements.txt

# Install cron
RUN apt-get update && apt-get install -y cron

# Copy the startup script
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Run the startup script to set up cron and keep the container running
CMD ["/usr/local/bin/startup.sh"]
