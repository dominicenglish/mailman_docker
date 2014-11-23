#!/usr/bin/env bash

# Backup data from the mailman data container.

# Set abort on error:
set -e

BACK_DIR="backup_temp"

mkdir -p ./${BACK_DIR}

# Backup the data, lists and archives mailman directories
# by copying them to backup_temp directory on the host:
# Note: The p flag for cp preserves ownership.
docker run --name mailman_data_backup_cont \
	--volumes-from mailman_data_cont \
	-v $(readlink -f $BACK_DIR):/backup \
        mailman_data \
	sh -c "\
        cp -Rp /var/lib/mailman/data /backup && \
        cp -Rp /var/lib/mailman/lists /backup && \
        cp -Rp /var/lib/mailman/archives /backup"

# Clean up docker container:
docker rm -f mailman_data_backup_cont

# We are going to save into ./backups directory:
mkdir -p ./backups

# Create a tar archive (With the current date):
now=$(date +%m_%d_%Y_%H_%M_%S)
tar -cvf ./backups/backup_${now}.tar $BACK_DIR

# Remove the temporary backups folder:
rm -R $BACK_DIR

# Unset abort on error:
set +e