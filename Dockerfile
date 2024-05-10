FROM python:3.9-slim AS google-drive-file-exporter

LABEL maintainer="Adnan Al Jawabra"

WORKDIR /app

RUN pip install google-api-python-client google-auth-httplib2 google-auth-oauthlib python-dotenv

COPY google-drive-file-exporter.py /app/google-drive-file-exporter.py