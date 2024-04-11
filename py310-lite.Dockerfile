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
<<<<<<< HEAD:envs/py310-lite.Dockerfile

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
=======
 
# Copy requirements.txt to the container
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt
>>>>>>> 4ef17503040693a658c59912f78aa0cf709d7fa7:py310-lite.Dockerfile

# Install git
RUN apt-get update && \
    apt-get install -y git
RUN pip install git+https://github.com/vcpopa/dsptools.git

# Copy the Bash script and IP mappings file into the container.
# Make sure you have these files in your Docker context
COPY process_notebook.sh /usr/local/bin/

# Make the script executable
RUN chmod +x /usr/local/bin/process_notebook.sh

# The CMD runs the script with the IP mappings and notebook file.
CMD /usr/local/bin/process_notebook.sh "$NOTEBOOK_PATH" "$OUTPUT_PATH" && echo 'Notebook processing completed.'