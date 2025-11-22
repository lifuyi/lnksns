#!/bin/bash

# LnkSns Backup Script
# Creates automated backups of database and application files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_DIR="/var/www/lnksns"
BACKUP_DIR="/var/backups/lnksns"
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$BACKUP_DIR/backup.log"

# Create backup directory
mkdir -p $BACKUP_DIR

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# Function to check if .env exists and source database config
load_db_config() {
    if [ -f "$APP_DIR/.env" ]; then
        # Source environment variables
        source <(grep -E '^(DB_|DATABASE_|MYSQL_)' $APP_DIR/.env 2>/dev/null | sed 's/^/export /')
        
        # Fallback to common variable names
        DB_NAME="${DATABASE:-${DB_DATABASE:-lnksns}}"
        DB_USER="${USERNAME:-${DB_USERNAME:-lnksns_user}}"
        DB_PASS="${PASSWORD:-${DB_PASSWORD}}"
        DB_HOST="${HOSTNAME:-${DB_HOST:-localhost}}"
        
        if [ -z "$DB_PASS" ]; then
            log "${YELLOW}Database password not found in .env, please enter manually${NC}"
            read -s -p "Enter database password: " DB_PASS
            echo
        fi
    else
        log "${RED}.env file not found at $APP_DIR/.env${NC}"
        exit 1
    fi
}

# Function to create database backup
backup_database() {
    log "${YELLOW}Starting database backup...${NC}"
    
    if mysqldump -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASS" --single-transaction --routines --triggers "$DB_NAME" > "$BACKUP_DIR/db_$DATE.sql"; then
        log "${GREEN}Database backup completed: db_$DATE.sql${NC}"
        
        # Compress the backup
        gzip "$BACKUP_DIR/db_$DATE.sql"
        log "${GREEN}Database backup compressed${NC}"
    else
        log "${RED}Database backup failed${NC}"
        return 1
    fi
}

# Function to backup application files
backup_application() {
    log "${YELLOW}Starting application files backup...${NC}"
    
    # Create excludes file for unnecessary directories
    EXCLUDES_FILE="$BACKUP_DIR/excludes.txt"
    cat > $EXCLUDES_FILE << EOF
$APP_DIR/vendor/*
$APP_DIR/node_modules/*
$APP_DIR/.git/*
$APP_DIR/runtime/log/*
$APP_DIR/runtime/cache/*
$APP_DIR/public/static/uploads/*
EOF
    
    if tar -czf "$BACKUP_DIR/app_$DATE.tar.gz" \
         -C "$APP_DIR" \
         --exclude-from="$EXCLUDES_FILE" \
         .; then
        log "${GREEN}Application backup completed: app_$DATE.tar.gz${NC}"
        rm -f $EXCLUDES_FILE
    else
        log "${RED}Application backup failed${NC}"
        rm -f $EXCLUDES_FILE
        return 1
    fi
}

# Function to cleanup old backups
cleanup_old_backups() {
    log "${YELLOW}Cleaning up old backups (keeping last 7 days)...${NC}"
    
    # Find and remove backups older than 7 days
    find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete 2>/dev/null || true
    find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete 2>/dev/null || true
    find $BACKUP_DIR -name "backup.log" -mtime +30 -delete 2>/dev/null || true
    
    log "${GREEN}Cleanup completed${NC}"
}

# Function to verify backups
verify_backups() {
    log "${YELLOW}Verifying backups...${NC}"
    
    local failed=0
    
    # Check database backup
    if [ -f "$BACKUP_DIR/db_$DATE.sql.gz" ]; then
        if gzip -t "$BACKUP_DIR/db_$DATE.sql.gz" 2>/dev/null; then
            log "${GREEN}Database backup verification passed${NC}"
        else
            log "${RED}Database backup verification failed${NC}"
            failed=1
        fi
    else
        log "${RED}Database backup file not found${NC}"
        failed=1
    fi
    
    # Check application backup
    if [ -f "$BACKUP_DIR/app_$DATE.tar.gz" ]; then
        if tar -tzf "$BACKUP_DIR/app_$DATE.tar.gz" >/dev/null 2>&1; then
            log "${GREEN}Application backup verification passed${NC}"
        else
            log "${RED}Application backup verification failed${NC}"
            failed=1
        fi
    else
        log "${RED}Application backup file not found${NC}"
        failed=1
    fi
    
    return $failed
}

# Function to show backup status
show_backup_status() {
    log "${YELLOW}Backup Summary for $DATE${NC}"
    
    local db_size=$(du -h "$BACKUP_DIR/db_$DATE.sql.gz" 2>/dev/null | cut -f1 || echo "N/A")
    local app_size=$(du -h "$BACKUP_DIR/app_$DATE.tar.gz" 2>/dev/null | cut -f1 || echo "N/A")
    
    log "Database backup: $BACKUP_DIR/db_$DATE.sql.gz ($db_size)"
    log "Application backup: $BACKUP_DIR/app_$DATE.tar.gz ($app_size)"
    
    local total_size=$(du -sh $BACKUP_DIR | cut -f1)
    log "Total backup directory size: $total_size"
}

# Main execution
main() {
    log "${GREEN}=== Starting LnkSns Backup Process ===${NC}"
    
    # Load database configuration
    load_db_config
    
    # Create backups
    if backup_database && backup_application; then
        
        # Verify backups
        if verify_backups; then
            
            # Show status
            show_backup_status
            
            # Cleanup old backups
            cleanup_old_backups
            
            log "${GREEN}=== Backup Process Completed Successfully ===${NC}"
            
            # Send notification email if configured (optional)
            if command -v mail >/dev/null 2>&1; then
                echo "LnkSns backup completed successfully on $(date)" | mail -s "LnkSns Backup Success" root 2>/dev/null || true
            fi
        else
            log "${RED}Backup verification failed${NC}"
            exit 1
        fi
    else
        log "${RED}Backup process failed${NC}"
        
        # Send failure notification
        if command -v mail >/dev/null 2>&1; then
            echo "LnkSns backup failed on $(date)" | mail -s "LnkSns Backup Failed" root 2>/dev/null || true
        fi
        exit 1
    fi
}

# Handle command line arguments
case "${1:-full}" in
    "db")
        load_db_config
        backup_database
        ;;
    "app")
        backup_application
        ;;
    "cleanup")
        cleanup_old_backups
        ;;
    "full"|*)
        main
        ;;
esac

exit 0