#!/bin/bash

# LnkSns Database Setup Script
# This script sets up the LnkSns database from schema

set -e

echo "=== LnkSns Database Setup ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Database configuration
DB_NAME="lnksns"
DB_USER="lnksns_user"
DB_HOST="localhost"
DB_PORT="3306"

echo -e "${BLUE}LnkSns Database Setup Script${NC}"
echo "This script will create the complete LnkSns database schema."
echo ""

# Check if MySQL is available
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}MySQL client not found. Please install MySQL client first.${NC}"
    exit 1
fi

# Function to test MySQL connection
test_mysql_connection() {
    if [ -n "$MYSQL_PASSWORD" ]; then
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" &>/dev/null
    else
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -e "SELECT 1;" &>/dev/null
    fi
}

# Get MySQL credentials
echo -e "${YELLOW}Please provide MySQL credentials${NC}"
echo ""

# Get database user
read -p "Enter MySQL username [$DB_USER]: " INPUT_USER
if [ -n "$INPUT_USER" ]; then
    DB_USER="$INPUT_USER"
fi

# Get database password
read -s -p "Enter MySQL password: " MYSQL_PASSWORD
echo ""

# Get database name
read -p "Enter database name [$DB_NAME]: " INPUT_DB
if [ -n "$INPUT_DB" ]; then
    DB_NAME="$INPUT_DB"
fi

# Get host
read -p "Enter MySQL host [$DB_HOST]: " INPUT_HOST
if [ -n "$INPUT_HOST" ]; then
    DB_HOST="$INPUT_HOST"
fi

# Get port
read -p "Enter MySQL port [$DB_PORT]: " INPUT_PORT
if [ -n "$INPUT_PORT" ]; then
    DB_PORT="$INPUT_PORT"
fi

echo ""
echo -e "${YELLOW}Testing database connection...${NC}"

# Test connection
if test_mysql_connection; then
    echo -e "${GREEN}Database connection successful!${NC}"
else
    echo -e "${RED}Failed to connect to MySQL. Please check your credentials.${NC}"
    exit 1
fi

# Check if database exists
if mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$MYSQL_PASSWORD" -e "USE $DB_NAME;" &>/dev/null; then
    echo -e "${YELLOW}Database $DB_NAME already exists.${NC}"
    read -p "Do you want to drop and recreate it? (y/N): " RECREATE_DB
    if [[ $RECREATE_DB =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Dropping existing database...${NC}"
        if [ -n "$MYSQL_PASSWORD" ]; then
            mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$MYSQL_PASSWORD" -e "DROP DATABASE IF EXISTS $DB_NAME;"
        else
            mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -e "DROP DATABASE IF EXISTS $DB_NAME;"
        fi
    else
        echo -e "${GREEN}Using existing database.${NC}"
    fi
fi

# Create database if it doesn't exist
if ! mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$MYSQL_PASSWORD" -e "USE $DB_NAME;" &>/dev/null; then
    echo -e "${YELLOW}Creating database $DB_NAME...${NC}"
    if [ -n "$MYSQL_PASSWORD" ]; then
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$MYSQL_PASSWORD" -e "CREATE DATABASE $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    else
        mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -e "CREATE DATABASE $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    fi
fi

# Check if schema file exists
SCHEMA_FILE="lnksns_database_schema.sql"
if [ ! -f "$SCHEMA_FILE" ]; then
    echo -e "${RED}Schema file $SCHEMA_FILE not found!${NC}"
    echo "Please ensure the lnksns_database_schema.sql file is in the current directory."
    exit 1
fi

# Get table prefix
read -p "Enter table prefix [lite_]: " TABLE_PREFIX
if [ -z "$TABLE_PREFIX" ]; then
    TABLE_PREFIX="lite_"
fi

echo ""
echo -e "${YELLOW}Setting up database schema...${NC}"
echo "Database: $DB_NAME"
echo "User: $DB_USER"
echo "Host: $DB_HOST"
echo "Port: $DB_PORT"
echo "Prefix: $TABLE_PREFIX"
echo ""

# Create temporary schema file with replaced prefix
TEMP_SCHEMA="temp_lnksns_schema.sql"
sed "s/__PREFIX__/$TABLE_PREFIX/g" "$SCHEMA_FILE" > "$TEMP_SCHEMA"

# Import schema
echo -e "${YELLOW}Importing database schema...${NC}"
if [ -n "$MYSQL_PASSWORD" ]; then
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" < "$TEMP_SCHEMA"
else
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" "$DB_NAME" < "$TEMP_SCHEMA"
fi

# Clean up temporary file
rm -f "$TEMP_SCHEMA"

# Verify tables were created
echo -e "${YELLOW}Verifying database setup...${NC}"
if [ -n "$MYSQL_PASSWORD" ]; then
    TABLE_COUNT=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$MYSQL_PASSWORD" -D"$DB_NAME" -se "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME' AND table_name LIKE '${TABLE_PREFIX}%';")
else
    TABLE_COUNT=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -D"$DB_NAME" -se "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME' AND table_name LIKE '${TABLE_PREFIX}%';")
fi

if [ "$TABLE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}Database setup completed successfully!${NC}"
    echo -e "${GREEN}Created $TABLE_COUNT tables${NC}"
else
    echo -e "${RED}Database setup failed! No tables were created.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}=== Database Setup Summary ===${NC}"
echo "Database Name: $DB_NAME"
echo "Table Prefix: $TABLE_PREFIX"
echo "Total Tables: $TABLE_COUNT"
echo ""

# Display created tables
echo -e "${YELLOW}Created tables:${NC}"
if [ -n "$MYSQL_PASSWORD" ]; then
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$MYSQL_PASSWORD" -D"$DB_NAME" -se "SELECT table_name FROM information_schema.tables WHERE table_schema = '$DB_NAME' AND table_name LIKE '${TABLE_PREFIX}%' ORDER BY table_name;" | while read table; do
        echo "  ✓ $table"
    done
else
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -D"$DB_NAME" -se "SELECT table_name FROM information_schema.tables WHERE table_schema = '$DB_NAME' AND table_name LIKE '${TABLE_PREFIX}%' ORDER BY table_name;" | while read table; do
        echo "  ✓ $table"
    done
fi

echo ""
echo -e "${YELLOW}=== Next Steps ===${NC}"
echo "1. Update your .env file with the database configuration:"
echo "   [DATABASE]"
echo "   TYPE = mysql"
echo "   HOSTNAME = $DB_HOST"
echo "   DATABASE = $DB_NAME"
echo "   USERNAME = $DB_USER"
echo "   PASSWORD = $MYSQL_PASSWORD"
echo "   HOSTPORT = $DB_PORT"
echo "   PREFIX = $TABLE_PREFIX"
echo ""
echo "2. Test the database connection:"
echo "   php think migrate:status"
echo ""
echo "3. Run migrations if needed:"
echo "   php think migrate:run"
echo ""

echo -e "${GREEN}LnkSns database setup completed!${NC}"