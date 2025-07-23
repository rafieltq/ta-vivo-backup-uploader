include .env

# Build the Node.js container for backup operations
build-node-container:
	@echo "🏗️ Building Node.js container..."
	@docker build -f Dockerfile.node -t ta-vivo-backup-uploader-node .
	@echo "✅ Node.js container built successfully"

# Build all containers
build-all: build-node-container
	@echo "✅ All containers built successfully"

create-backup:
ifeq ($(strip $(DATABASE_EXCLUDE_TABLES_DATA)),)
	@echo "Creating backup of all tables data"
	@docker exec -t ${CONTAINER_NAME} pg_dump -c --user ${DATABASE_USER} --dbname=${DATABASE_NAME} > src/file/dump.sql && cd src/file && tar -czvf dump.sql.tar.gz dump.sql && rm dump.sql

else
	@docker exec -t ${CONTAINER_NAME} pg_dump -c --user ${DATABASE_USER} --dbname=${DATABASE_NAME} --exclude-table-data=${DATABASE_EXCLUDE_TABLES_DATA} > src/file/dump.sql && tar -czvf src/file/dump.sql.tar.gz src/file/dump.sql && rm src/file/dump.sql
endif
	@echo "Backup created, now upload it to S3"
	@docker run --rm --env-file .env -v "${PWD}/src/file:/app/src/file" ta-vivo-backup-uploader-node node src/daily.js
	@echo "Backup uploaded to S3, all jobs done."

upload-daily:
	@echo "📤 Uploading daily backup..."
	@docker run --rm --env-file .env -v "${PWD}/src/file:/app/src/file" ta-vivo-backup-uploader-node node src/daily.js

upload-weekly:
	@echo "📤 Uploading weekly backup..."
	@docker run --rm --env-file .env -v "${PWD}/src/file:/app/src/file" ta-vivo-backup-uploader-node node src/weekly.js

cleanup-daily:
	@echo "🧹 Cleaning up daily backups..."
	@docker run --rm --env-file .env ta-vivo-backup-uploader-node node src/cleanup.js

# Cron-related targets
setup-cron:
	@echo "🚀 Setting up crontab configuration..."
	@./scripts/setup-cron.sh

test-cron-daily:
	@echo "🧪 Testing daily cron script..."
	@./scripts/cron-daily.sh

test-cron-weekly:
	@echo "🧪 Testing weekly cron script..."
	@./scripts/cron-weekly.sh

test-cron-cleanup:
	@echo "🧪 Testing cleanup cron script..."
	@./scripts/cron-cleanup.sh

test-cron-full:
	@echo "🧪 Testing full backup cron script..."
	@./scripts/cron-full-backup.sh

show-logs:
	@echo "📋 Recent log files:"
	@ls -la logs/ 2>/dev/null || echo "No logs directory found"

clean-logs:
	@echo "🧹 Cleaning old log files..."
	@find logs -name "*.log" -mtime +30 -delete 2>/dev/null || true
	@echo "✅ Old logs cleaned"

	