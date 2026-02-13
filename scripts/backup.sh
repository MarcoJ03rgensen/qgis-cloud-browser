#!/bin/bash

# Backup script for QGIS Cloud Browser

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="qgis-backup-$DATE.tar.gz"

mkdir -p $BACKUP_DIR

echo "Creating backup..."

tar -czf $BACKUP_DIR/$BACKUP_FILE \
    data/ \
    qgis-projects/ \
    qgis-plugins/ \
    .env

echo "Backup created: $BACKUP_DIR/$BACKUP_FILE"
echo "Size: $(du -h $BACKUP_DIR/$BACKUP_FILE | cut -f1)"

# Keep only last 5 backups
ls -t $BACKUP_DIR/qgis-backup-*.tar.gz | tail -n +6 | xargs rm -f 2>/dev/null || true

echo "Old backups cleaned up."