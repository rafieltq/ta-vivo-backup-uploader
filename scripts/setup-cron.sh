#!/bin/bash

# Setup script for crontab implementation
# Usage: ./scripts/setup-cron.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Setting up ta-vivo-backup-uploader for crontab usage..."
echo "Project directory: $PROJECT_DIR"

# Change to project directory
cd "$PROJECT_DIR"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ ERROR: .env file not found"
    echo "Please create a .env file with the required environment variables:"
    echo "  - AWS_REGION"
    echo "  - S3_BUCKET_NAME"
    echo "  - DATABASE_USER"
    echo "  - DATABASE_NAME"
    echo "  - CONTAINER_NAME"
    echo "  - DATABASE_EXCLUDE_TABLES_DATA (optional)"
    exit 1
fi

echo "✅ Environment file found"

# Check if docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ ERROR: Docker is not available"
    echo "Please install Docker first"
    exit 1
fi

echo "✅ Docker is available"

# Create logs directory
mkdir -p logs
echo "✅ Created logs directory"

# Build containers
echo "🏗️ Building Docker containers..."
make build-all

echo "✅ Docker containers built successfully"

# Show crontab example
echo ""
echo "📋 Crontab setup:"
echo "1. Edit your crontab with: crontab -e"
echo "2. Add the following lines (adjust PROJECT_DIR path):"
echo ""
echo "# PATH for cron jobs"
echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
echo ""
echo "# Full backup daily at 2:00 AM"
echo "0 2 * * * cd $PROJECT_DIR && ./scripts/cron-full-backup.sh"
echo ""
echo "# Weekly backup every Sunday at 3:00 AM"
echo "0 3 * * 0 cd $PROJECT_DIR && ./scripts/cron-weekly.sh"
echo ""
echo "# Cleanup every day at 4:00 AM"
echo "0 4 * * * cd $PROJECT_DIR && ./scripts/cron-cleanup.sh"
echo ""
echo "📄 More examples available in: crontab.example"
echo ""
echo "🔍 To monitor cron jobs:"
echo "  - Check logs in: $PROJECT_DIR/logs/"
echo "  - View cron log: sudo tail -f /var/log/cron"
echo "  - Test scripts manually: ./scripts/cron-daily.sh"
echo ""
echo "✅ Setup completed!"
