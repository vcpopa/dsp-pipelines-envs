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
  
# Copy the Bash script and IP mappings file into the container.
# Make sure you have these files in your Docker context
COPY process_notebook.sh /usr/local/bin/
 
# Make the script executable
RUN chmod +x /usr/local/bin/process_notebook.sh
 
# The CMD runs the script with the IP mappings and notebook file.
CMD /usr/local/bin/process_notebook.sh "$NOTEBOOK_PATH" "$OUTPUT_PATH" && echo 'Notebook processing completed.'