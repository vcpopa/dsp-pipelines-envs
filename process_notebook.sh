#!/bin/bash

# Define a log function for convenience
log() {
    echo "$(date +%Y-%m-%d\ %H:%M:%S) - $1"
}

# Check for correct usage
if [ "$#" -ne 2 ]; then
    log "Usage: $0 notebook.ipynb output_path"
    exit 1
fi

NOTEBOOK=$1
OUTPUT_PATH=$2

export AZURE_CLIENT_ID=${AZURE_CLIENT_ID}
export AZURE_CLIENT_SECRET=${AZURE_CLIENT_SECRET}
export AZURE_TENANT_ID=${AZURE_TENANT_ID}

# Determine the directory from NOTEBOOK_PATH
LOG_DIR=$(dirname "$NOTEBOOK")

# Create a working directory in the container to hold temporary files
WORKDIR=$(mktemp -d) || { log "Failed to create temporary working directory"; exit 1; }
log "Created temporary working directory $WORKDIR"

# Conditional logic based on presence of 'Uploads' in OUTPUT_PATH
if [[ "$OUTPUT_PATH" == */Uploads* ]]; then
    # If OUTPUT_PATH contains 'Uploads', copy all contents of LOG_DIR
    cp -r "$LOG_DIR/"* "$WORKDIR" || { log "Failed to copy contents of $LOG_DIR to $WORKDIR"; exit 1; }
    log "Copied contents of $LOG_DIR to $WORKDIR"
else
    # If OUTPUT_PATH doesn't contain 'Uploads', copy only the notebook file
    cp "$NOTEBOOK" "$WORKDIR" || { log "Failed to copy $NOTEBOOK to $WORKDIR"; exit 1; }
    log "Copied $NOTEBOOK to $WORKDIR"
fi

# Update NOTEBOOK_COPY path to reflect the new location of the notebook in WORKDIR
NOTEBOOK_COPY="$WORKDIR/$(basename "$NOTEBOOK")"

# Function to replace -tailscale- with -public- in the notebook copy
replace_tailscale_with_public() {
    local temp_file=$(mktemp)

    if ! jq '
    (.. | select(type == "string") | select(test("tailscale"))) |= gsub("tailscale"; "public")
    ' "$NOTEBOOK_COPY" > "$temp_file"; then
        log "jq operation failed"
        exit 1
    fi

    mv "$temp_file" "$NOTEBOOK_COPY" || { log "Failed to move temporary file after replacement"; exit 1; }
}

log "Starting string replacements..."
replace_tailscale_with_public
log "String replacements done."

# Before converting, ensure the notebook copy exists and is not empty
if [ ! -s "$NOTEBOOK_COPY" ]; then
    log "Notebook copy does not exist or is empty after replacements"
    exit 1
fi

log "Starting notebook conversion..."

# Convert the notebook copy
OUTPUT_HTML="$WORKDIR/$(basename "$OUTPUT_PATH").html"
if ! jupyter nbconvert --to html --execute "$NOTEBOOK_COPY" --output "$OUTPUT_HTML" &> "$WORKDIR/nbconvert.log"; then
    log "Failed to convert notebook. See $WORKDIR/nbconvert.log for details."
    log "Copying log file to $LOG_DIR..."
    cp "$WORKDIR/nbconvert.log" "$LOG_DIR/nbconvert.log" || log "Failed to copy log file to $LOG_DIR."
    exit 1
fi

if [ -s "$OUTPUT_HTML" ]; then
    log "Verification passed: Output HTML exists and is not empty."
else
    log "Verification failed: Output HTML does not exist or is empty."
    log "Copying log file to $LOG_DIR..."
    cp "$WORKDIR/nbconvert.log" "$LOG_DIR/nbconvert.log" || log "Failed to copy log file to $LOG_DIR."
    exit 1
fi

log "Notebook conversion successful."

# Now, copy the resulting HTML back to the original output path
cp "$OUTPUT_HTML" "$OUTPUT_PATH" || { log "Failed to copy converted notebook HTML to $OUTPUT_PATH"; exit 1; }
log "Converted notebook HTML copied to $OUTPUT_PATH"

# Cleanup the working directory
rm -rf "$WORKDIR"
log "Cleaned up temporary working directory $WORKDIR"

# Keep the container running
tail -f /dev/null
