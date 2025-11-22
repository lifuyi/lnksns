#!/bin/bash

# LnkSns Deployment Script
# This script deploys the application to the server

set -e

echo "=== LnkSns Application Deployment ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_DIR="/var/www/lnksns"
NGINX_CONFIG="/etc/nginx/sites-available/lnksns"
SUPERVISOR_CONFIG="/etc/supervisor/conf.d/lnksns-worker.conf"
BACKUP_DIR="/var/backups/lnksns"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}This script should not be run as root for security reasons.${NC}"
   echo "Please run as a regular user with sudo privileges."
   exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command_exists composer; then
    echo -e "${RED}Composer is not installed. Please run install-debian.sh first.${NC}"
    exit 1
fi

if ! command_exists php; then
    echo -e "${RED}PHP is not installed. Please run install-debian.sh first.${NC}"
    exit 1
fi

# Get application directory (assume current directory if not specified)
if [ -z "$1" ]; then
    APP_SOURCE_DIR=$(pwd)
else
    APP_SOURCE_DIR=$(realpath "$1")
fi

if [ ! -f "$APP_SOURCE_DIR/composer.json" ]; then
    echo -e "${RED}composer.json not found in $APP_SOURCE_DIR${NC}"
    echo "Please specify the application directory as an argument:"
    echo "  $0 /path/to/lnksns"
    exit 1
fi

echo -e "${GREEN}Source directory: $APP_SOURCE_DIR${NC}"

# Create application directory
echo -e "${YELLOW}Creating application directory...${NC}"
sudo mkdir -p $APP_DIR

# Copy application files
echo -e "${YELLOW}Copying application files...${NC}"
if [ "$APP_SOURCE_DIR" != "$APP_DIR" ]; then
    sudo cp -r $APP_SOURCE_DIR/* $APP_DIR/
    sudo cp -r $APP_SOURCE_DIR/.[!.]* $APP_DIR/ 2>/dev/null || true
fi

# Set ownership and permissions
echo -e "${YELLOW}Setting permissions...${NC}"
sudo chown -R www-data:www-data $APP_DIR
sudo chmod -R 755 $APP_DIR
sudo chmod -R 775 $APP_DIR/runtime 2>/dev/null || sudo mkdir -p $APP_DIR/runtime && sudo chown -R www-data:www-data $APP_DIR/runtime && sudo chmod -R 775 $APP_DIR/runtime
sudo chmod -R 775 $APP_DIR/public/static 2>/dev/null || sudo mkdir -p $APP_DIR/public/static && sudo chown -R www-data:www-data $APP_DIR/public/static && sudo chmod -R 775 $APP_DIR/public/static

# Install dependencies
echo -e "${YELLOW}Installing PHP dependencies...${NC}"
cd $APP_DIR
sudo -u www-data composer install --no-dev --optimize-autoloader --no-interaction

# Create environment file
if [ ! -f "$APP_DIR/.env" ]; then
    echo -e "${YELLOW}Creating environment file...${NC}"
    if [ -f "$APP_DIR/.example.env" ]; then
        sudo -u www-data cp $APP_DIR/.example.env $APP_DIR/.env
        echo -e "${GREEN}Environment file created from example. Please configure .env file.${NC}"
    else
        echo -e "${RED}.example.env not found. Please create .env file manually.${NC}"
    fi
fi

# Check if .env file needs configuration
if [ -f "$APP_DIR/.env" ]; then
    echo -e "${YELLOW}Checking .env configuration...${NC}"
    
    # Check if database is configured
    if grep -q "TYPE = sqlite" $APP_DIR/.env; then
        echo -e "${RED}Database is still configured for SQLite.${NC}"
        echo -e "${YELLOW}Please run setup-database.sh to configure MySQL, then update .env file.${NC}"
        echo -e "${YELLOW}Then re-run this deployment script.${NC}"
        exit 1
    fi
    
    if grep -q "DATABASE = " $APP_DIR/.env && grep -q "USERNAME = " $APP_DIR/.env && grep -q "PASSWORD = " $APP_DIR/.env; then
        echo -e "${GREEN}Database configuration found in .env${NC}"
    else
        echo -e "${YELLOW}Database configuration incomplete. Please configure .env file.${NC}"
    fi
fi

# Configure Nginx
echo -e "${YELLOW}Configuring Nginx...${NC}"
read -p "Enter your domain name (or press Enter for localhost): " DOMAIN_NAME
if [ -z "$DOMAIN_NAME" ]; then
    DOMAIN_NAME="localhost"
fi

sudo tee $NGINX_CONFIG > /dev/null << EOF
server {
    listen 80;
    server_name $DOMAIN_NAME;
    root $APP_DIR/public;
    index index.php index.html index.htm;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        
        # Increase timeout for large requests
        fastcgi_read_timeout 300;
        fastcgi_send_timeout 300;
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }

    # Cache static files
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;
}
EOF

# Enable site
sudo ln -sf $NGINX_CONFIG /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
if sudo nginx -t; then
    echo -e "${GREEN}Nginx configuration is valid${NC}"
    sudo systemctl reload nginx
else
    echo -e "${RED}Nginx configuration is invalid${NC}"
    exit 1
fi

# Configure Supervisor
echo -e "${YELLOW}Configuring Supervisor for queue workers...${NC}"
sudo tee $SUPERVISOR_CONFIG > /dev/null << EOF
[program:lnksns-worker]
command=php $APP_DIR/think queue:work --daemon
directory=$APP_DIR
user=www-data
autostart=true
autorestart=true
stderr_logfile=$APP_DIR/runtime/log/worker.err.log
stdout_logfile=$APP_DIR/runtime/log/worker.out.log
redirect_stderr=true
stdout_logfile_maxbytes=10MB
stdout_logfile_backups=5
EOF

# Create log directories
sudo mkdir -p $APP_DIR/runtime/log
sudo chown -R www-data:www-data $APP_DIR/runtime/log

# Update Supervisor
sudo supervisorctl reread
sudo supervisorctl update

# Create backup directory
sudo mkdir -p $BACKUP_DIR
sudo chown $USER:$USER $BACKUP_DIR

echo -e "${GREEN}Deployment completed successfully!${NC}"
echo ""
echo -e "${BLUE}=== Summary ===${NC}"
echo "Application directory: $APP_DIR"
echo "Domain: $DOMAIN_NAME"
echo "Nginx configuration: $NGINX_CONFIG"
echo "Supervisor config: $SUPERVISOR_CONFIG"
echo "Backup directory: $BACKUP_DIR"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Configure your .env file with database credentials"
echo "2. Run database migrations: php think migrate:run"
echo "3. Test the application in browser"
echo "4. (Optional) Set up SSL certificate with certbot"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo "View application logs: sudo tail -f $APP_DIR/runtime/log/*.log"
echo "Restart services: sudo systemctl restart nginx php8.2-fpm"
echo "Check supervisor status: sudo supervisorctl status"
echo "Create backup: ./backup.sh"
echo ""

# Test if application is accessible
echo -e "${YELLOW}Testing application...${NC}"
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200\|302"; then
    echo -e "${GREEN}Application is responding!${NC}"
else
    echo -e "${YELLOW}Application may not be fully configured yet. Check .env file and run migrations.${NC}"
fi

echo -e "${GREEN}Deployment script completed!${NC}"