include .env

create-backup:
ifeq ($(strip $(DATABASE_EXCLUDE_TABLES_DATA)),)
	@echo "Creating backup of all tables data"
	@podman exec -t ${CONTAINER_NAME} pg_dump -c --user ${DATABASE_USER} --dbname=${DATABASE_NAME} > src/file/dump.sql && cd src/file && tar -czvf dump.sql.tar.gz dump.sql && rm dump.sql

else
	@podman exec -t ${CONTAINER_NAME} pg_dump -c --user ${DATABASE_USER} --dbname=${DATABASE_NAME} --exclude-table-data=${DATABASE_EXCLUDE_TABLES_DATA} > src/file/dump.sql && tar -czvf src/file/dump.sql.tar.gz src/file/dump.sql && rm src/file/dump.sql
endif
	@echo "Backup created, now upload it to S3"
	@podman run --rm -v "${PWD}:/app" -w /app node:23.11.0 /bin/bash -c "yarn install; node src/daily.js"
	@echo "Backup uploaded to S3, all jobs done."

upload-daily:
	@echo "📤 Uploading daily backup..."
	@podman run --rm -v "${PWD}:/app" -w /app node:23.11.0 /bin/bash -c "yarn install; node src/daily.js"

upload-weekly:
	@echo "📤 Uploading weekly backup..."
	@podman run --rm -v "${PWD}:/app" -w /app node:23.11.0 /bin/bash -c "yarn install; node src/weekly.js"

cleanup-daily:
	@echo "🧹 Cleaning up daily backups..."
	@podman run --rm -v "${PWD}:/app" -w /app node:23.11.0 /bin/bash -c "yarn install; node src/cleanup.js"

	