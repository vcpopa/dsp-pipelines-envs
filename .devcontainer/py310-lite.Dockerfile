# Use an official Python runtime based on Debian 11 (Bullseye)
FROM --platform=linux/amd64 python:3.10-slim-buster

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

# Install specific versions of common data science packages
RUN pip install --no-cache-dir \
    notebook \
    nbconvert \
    numpy \
    pandas \
    matplotlib \
    scikit-learn \
    sqlalchemy \
    pyodbc \
    azure-core \
    azure-storage-blob \
    prophet \
    tqdm \
    chardet \
    imbox \
    pyyaml \
    azure-keyvault-secrets \
    azure-identity \
    azure-storage-file-share \
    openpyxl \
    adal

# Install git
RUN apt-get update && \
    apt-get install -y git
RUN pip install git+https://github.com/vcpopa/dsptools.git