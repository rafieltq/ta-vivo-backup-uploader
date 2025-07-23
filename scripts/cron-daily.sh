#!/bin/bash

# Crontab-friendly wrapper for daily backup upload
# Usage: ./scripts/cron-daily.sh

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to project directory
cd "$PROJECT_DIR"

# Create logs directory if it doesn't exist
mkdir -p logs

# Log file with timestamp
LOG_FILE="logs/daily-$(date +%Y%m%d-%H%M%S).log"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting daily backup upload..."
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

# Check if backup file exists
if [ ! -f "src/file/dump.sql.tar.gz" ]; then
    log "ERROR: Backup file not found at src/file/dump.sql.tar.gz"
    exit 1
fi

# Check if docker image exists
if ! docker image inspect ta-vivo-backup-uploader-node &> /dev/null; then
    log "WARNING: Docker image ta-vivo-backup-uploader-node not found, building..."
    make build-node-container >> "$LOG_FILE" 2>&1
fi

# Execute the upload
log "Executing daily upload..."
if make upload-daily >> "$LOG_FILE" 2>&1; then
    log "Daily backup upload completed successfully"
    # Keep only last 7 days of logs
    find logs -name "daily-*.log" -mtime +7 -delete 2>/dev/null || true
    exit 0
else
    log "ERROR: Daily backup upload failed"
    exit 1
fi
