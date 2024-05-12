FROM python:3.9-slim AS google-drive-file-exporter

LABEL maintainer="Adnan Al Jawabra"

WORKDIR /app

COPY . /app

RUN pip install -r requirements.txt

