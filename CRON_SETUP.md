# Crontab Implementation Guide

This guide explains how to set up automated backups using crontab on your server.

## Quick Setup

1. **Run the setup script:**
   ```bash
   make setup-cron
   ```

2. **Edit your crontab:**
   ```bash
   crontab -e
   ```

3. **Add the cron jobs** (adjust the PROJECT_DIR path):
   ```bash
   # PATH for cron jobs
   PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
   
   # Full backup daily at 2:00 AM
   0 2 * * * cd /path/to/your/ta-vivo-backup-uploader && ./scripts/cron-full-backup.sh
   
   # Weekly backup every Sunday at 3:00 AM
   0 3 * * 0 cd /path/to/your/ta-vivo-backup-uploader && ./scripts/cron-weekly.sh
   
   # Cleanup every day at 4:00 AM
   0 4 * * * cd /path/to/your/ta-vivo-backup-uploader && ./scripts/cron-cleanup.sh
   ```

## Available Scripts

### Cron Scripts (in `scripts/` directory)
- `cron-full-backup.sh` - Creates database backup and uploads to S3
- `cron-daily.sh` - Uploads existing backup file as daily backup
- `cron-weekly.sh` - Uploads existing backup file as weekly backup
- `cron-cleanup.sh` - Removes old backups from S3
- `setup-cron.sh` - Initial setup for cron environment

### Makefile Targets
- `make setup-cron` - Run initial cron setup
- `make test-cron-daily` - Test daily cron script
- `make test-cron-weekly` - Test weekly cron script
- `make test-cron-cleanup` - Test cleanup cron script
- `make test-cron-full` - Test full backup cron script
- `make show-logs` - Display recent log files
- `make clean-logs` - Remove old log files

## Features

### Logging
- All cron jobs create detailed logs in the `logs/` directory
- Logs include timestamps and execution details
- Automatic log rotation (old logs are automatically deleted)

### Error Handling
- Scripts check for required dependencies (Docker, .env file)
- Validate backup files exist before uploading
- Automatic container building if images don't exist
- Proper exit codes for cron monitoring

### Monitoring
- Check logs: `ls -la logs/`
- View recent activity: `tail -f logs/daily-*.log`
- System cron log: `sudo tail -f /var/log/cron`

## Schedule Examples

### Basic Schedule
```bash
# Daily full backup at 2 AM
0 2 * * * cd /path/to/project && ./scripts/cron-full-backup.sh

# Weekly backup on Sunday at 3 AM
0 3 * * 0 cd /path/to/project && ./scripts/cron-weekly.sh

# Daily cleanup at 4 AM
0 4 * * * cd /path/to/project && ./scripts/cron-cleanup.sh
```

### High-Frequency Schedule
```bash
# Full backup every 12 hours
0 */12 * * * cd /path/to/project && ./scripts/cron-full-backup.sh

# Daily backup every 6 hours
0 */6 * * * cd /path/to/project && ./scripts/cron-daily.sh

# Weekly backup twice per week
0 3 * * 0,3 cd /path/to/project && ./scripts/cron-weekly.sh
```

## Troubleshooting

### Common Issues

1. **Permission denied**
   ```bash
   chmod +x scripts/*.sh
   ```

2. **Docker not found in cron**
   - Add Docker path to crontab PATH variable
   - Verify: `which docker`

3. **Environment variables not loaded**
   - Ensure `.env` file exists in project root
   - Check file permissions: `ls -la .env`

4. **Container not found**
   - Run: `make build-all`
   - Or let the script auto-build

### Log Analysis
```bash
# View latest logs
make show-logs

# Follow live logs
tail -f logs/daily-$(date +%Y%m%d)*.log

# Check for errors
grep -i error logs/*.log
```

### Testing
Before setting up cron, test each script manually:
```bash
make test-cron-full
make test-cron-daily
make test-cron-weekly
make test-cron-cleanup
```

## Security Notes

- Store sensitive credentials in `.env` file
- Set appropriate file permissions: `chmod 600 .env`
- Logs may contain sensitive information - secure the `logs/` directory
- Regular log cleanup prevents disk space issues
