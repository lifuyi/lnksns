#!/bin/bash

# LnkSns Database Setup Script
# This script sets up MySQL database for the application

set -e

echo "=== LnkSns Database Setup ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Database configuration
DB_NAME="lnksns"
DB_USER="lnksns_user"
DB_HOST="localhost"
DB_PORT="3306"

echo -e "${YELLOW}Please provide MySQL root password${NC}"
echo ""

# Function to test MySQL connection
test_mysql_connection() {
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1;" &>/dev/null
}

# Get MySQL root password
while true; do
    read -s -p "Enter MySQL root password: " MYSQL_ROOT_PASSWORD
    echo ""
    if test_mysql_connection; then
        echo -e "${GREEN}MySQL connection successful!${NC}"
        break
    else
        echo -e "${RED}Failed to connect to MySQL. Please check the password.${NC}"
    fi
done

# Function to execute SQL
execute_sql() {
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "$1"
}

# Check if database exists
if mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "USE $DB_NAME;" &>/dev/null; then
    echo -e "${YELLOW}Database $DB_NAME already exists.${NC}"
    read -p "Do you want to drop and recreate it? (y/N): " RECREATE_DB
    if [[ $RECREATE_DB =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Dropping existing database...${NC}"
        execute_sql "DROP DATABASE IF EXISTS $DB_NAME;"
    else
        echo -e "${GREEN}Using existing database.${NC}"
        exit 0
    fi
fi

# Generate a secure password for application user
DB_USER_PASSWORD=$(openssl rand -base64 32)

echo -e "${YELLOW}Creating database and user...${NC}"

# Create database
execute_sql "CREATE DATABASE $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Create user and grant privileges
execute_sql "CREATE USER '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_USER_PASSWORD';"
execute_sql "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'$DB_HOST';"
execute_sql "FLUSH PRIVILEGES;"

echo -e "${GREEN}Database setup completed successfully!${NC}"
echo ""
echo -e "${YELLOW}Database Configuration:${NC}"
echo "Database Name: $DB_NAME"
echo "Username: $DB_USER"
echo "Password: $DB_USER_PASSWORD"
echo "Host: $DB_HOST"
echo "Port: $DB_PORT"
echo ""
echo -e "${YELLOW}Environment variables to add to your .env file:${NC}"
echo ""
echo "[DATABASE]"
echo "TYPE = mysql"
echo "HOSTNAME = $DB_HOST"
echo "DATABASE = $DB_NAME"
echo "USERNAME = $DB_USER"
echo "PASSWORD = $DB_USER_PASSWORD"
echo "HOSTPORT = $DB_PORT"
echo "CHARSET = utf8mb4"
echo "DEBUG = false"
echo "PREFIX = lite_"
echo ""
echo -e "${GREEN}IMPORTANT: Save these credentials securely!${NC}"
echo -e "${GREEN}You can now run your application migrations:${NC}"
echo "php think migrate:run"
echo ""

# Test the new connection
echo -e "${YELLOW}Testing database connection...${NC}"
if mysql -u "$DB_USER" -p"$DB_USER_PASSWORD" -e "USE $DB_NAME; SELECT 'Connection successful' as test;"; then
    echo -e "${GREEN}Database connection test passed!${NC}"
else
    echo -e "${RED}Database connection test failed!${NC}"
    exit 1
fi

# Save credentials to a file (optional, for backup)
read -p "Do you want to save credentials to a secure file? (y/N): " SAVE_CREDS
if [[ $SAVE_CREDS =~ ^[Yy]$ ]]; then
    CRED_FILE="$HOME/lnksns-db-credentials.txt"
    cat > "$CRED_FILE" << EOF
LnkSns Database Credentials
===========================
Generated on: $(date)

Database: $DB_NAME
Username: $DB_USER  
Password: $DB_USER_PASSWORD
Host: $DB_HOST
Port: $DB_PORT

Environment Configuration:
[DATABASE]
TYPE = mysql
HOSTNAME = $DB_HOST
DATABASE = $DB_NAME
USERNAME = $DB_USER
PASSWORD = $DB_USER_PASSWORD
HOSTPORT = $DB_PORT
CHARSET = utf8mb4
DEBUG = false
PREFIX = lite_
EOF

    chmod 600 "$CRED_FILE"
    echo -e "${GREEN}Credentials saved to: $CRED_FILE${NC}"
    echo -e "${YELLOW}Remember to delete this file after configuring your application!${NC}"
fi

echo -e "${GREEN}Database setup complete!${NC}"