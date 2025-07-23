#!/bin/bash

# Complete backup creation and upload script for crontab
# This script combines backup creation and upload in one step
# Usage: ./scripts/cron-full-backup.sh

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to project directory
cd "$PROJECT_DIR"

# Create logs directory if it doesn't exist
mkdir -p logs

# Log file with timestamp
LOG_FILE="logs/full-backup-$(date +%Y%m%d-%H%M%S).log"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting full backup creation and upload..."
log "Project directory: $PROJECT_DIR"
log "Log file: $LOG_FILE"

# Check if docker is available
if ! command -v docker &> /dev/null; then
    log "ERROR: Docker is not available"
    exit 1
fi

# Check if .env file exists
if [ ! -f ".env" ]; then
    log "ERROR: .env file not found"
    exit 1
fi

# Source environment variables
source .env

# Check if required containers are running
if ! docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}" | grep -q "${CONTAINER_NAME}"; then
    log "ERROR: Database container ${CONTAINER_NAME} is not running"
    exit 1
fi

# Check if docker image exists
if ! docker image inspect ta-vivo-backup-uploader-node &> /dev/null; then
    log "WARNING: Docker image ta-vivo-backup-uploader-node not found, building..."
    make build-node-container >> "$LOG_FILE" 2>&1
fi

# Execute the full backup process
log "Executing full backup creation and upload..."
if make create-backup >> "$LOG_FILE" 2>&1; then
    log "Full backup creation and upload completed successfully"
    # Keep only last 7 days of full backup logs
    find logs -name "full-backup-*.log" -mtime +7 -delete 2>/dev/null || true
    exit 0
else
    log "ERROR: Full backup creation and upload failed"
    exit 1
fi
