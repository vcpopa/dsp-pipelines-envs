# Use an official Python runtime based on Debian 11 (Bullseye)
# Noting the base image is still Buster as in your original file but mentioned Bullseye. Adjust as necessary.
FROM --platform=linux/amd64 python:3.12.0b3-slim

# UPGRADE pip3
RUN pip3 install --upgrade pip

# SQL driver dependencies
RUN apt-get update && apt-get install -y \
    gnupg2 \
    curl \
    apt-transport-https \
    jq && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev

# Copy requirements.txt to the container
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt