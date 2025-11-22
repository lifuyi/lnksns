# Debian Server Deployment Guide

This guide will help you deploy the lnksns backend service to a Debian server with MySQL.

## Prerequisites

- Debian 11 (Bullseye) or later
- Root access or sudo privileges
- Basic knowledge of Linux commands

## Step 1: Server Preparation

### Update System
```bash
sudo apt update && sudo apt upgrade -y
```

### Install Required Packages
```bash
# Install basic dependencies
sudo apt install -y curl wget unzip git supervisor

# Install PHP and required extensions
sudo apt install -y php8.2 php8.2-fpm php8.2-mysql php8.2-curl php8.2-xml php8.2-mbstring php8.2-zip php8.2-gd php8.2-json

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install Nginx (recommended) or Apache
sudo apt install -y nginx

# Install MySQL Server
sudo apt install -y mysql-server
```

## Step 2: MySQL Setup

### Secure MySQL Installation
```bash
sudo mysql_secure_installation
```

### Create Database and User
```sql
-- Connect to MySQL
sudo mysql -u root -p

-- Create database
CREATE DATABASE lnksns CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user (replace 'your_password' with a secure password)
CREATE USER 'lnksns_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON lnksns.* TO 'lnksns_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

## Step 3: Application Deployment

### Upload Application Files
```bash
# Create application directory
sudo mkdir -p /var/www/lnksns
sudo chown $USER:$USER /var/www/lnksns

# Upload your application files to /var/www/lnksns
# You can use rsync, scp, or git clone
```

### Install Dependencies
```bash
cd /var/www/lnksns
composer install --no-dev --optimize-autoloader
```

### Set Permissions
```bash
sudo chown -R www-data:www-data /var/www/lnksns
sudo chmod -R 755 /var/www/lnksns
sudo chmod -R 775 /var/www/lnksns/runtime
sudo chmod -R 775 /var/www/lnksns/public/static
```

## Step 4: Environment Configuration

### Copy and Configure Environment File
```bash
cp .example.env .env
```

Edit the `.env` file with your production settings:
```ini
APP_DEBUG = false

[APP]
DEFAULT_TIMEZONE = Asia/Shanghai

[DATABASE]
TYPE = mysql
HOSTNAME = localhost
DATABASE = lnksns
USERNAME = lnksns_user
PASSWORD = your_password
HOSTPORT = 3306
CHARSET = utf8mb4
DEBUG = false
PREFIX = lite_

[LANG]
default_lang = zh-cn
```

## Step 5: Web Server Configuration

### Nginx Configuration
```bash
sudo nano /etc/nginx/sites-available/lnksns
```

Add the following configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/lnksns/public;
    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    # Static files
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### Enable Site
```bash
sudo ln -s /etc/nginx/sites-available/lnksns /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## Step 6: SSL Certificate (Recommended)

### Install Certbot
```bash
sudo apt install -y certbot python3-certbot-nginx
```

### Get SSL Certificate
```bash
sudo certbot --nginx -d your-domain.com
```

## Step 7: Process Management

### Create Supervisor Configuration
```bash
sudo nano /etc/supervisor/conf.d/lnksns-worker.conf
```

Add:
```ini
[program:lnksns-worker]
command=php /var/www/lnksns/think queue:work
directory=/var/www/lnksns
user=www-data
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/www/lnksns/runtime/log/worker.log
```

### Update Supervisor
```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start lnksns-worker
```

## Step 8: Firewall Configuration

```bash
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

## Step 9: Database Migration

```bash
cd /var/www/lnksns
php think migrate:run
php think seed:run
```

## Step 10: Monitoring and Maintenance

### Log Files
- Application logs: `/var/www/lnksns/runtime/log/`
- Nginx logs: `/var/log/nginx/`
- MySQL logs: `/var/log/mysql/`
- Supervisor logs: `/var/www/lnksns/runtime/log/worker.log`

### Health Check
```bash
# Check service status
sudo systemctl status nginx mysql php8.2-fpm
sudo supervisorctl status
```

### Backup Script
```bash
#!/bin/bash
# Create backup script
sudo nano /usr/local/bin/lnksns-backup.sh

#!/bin/bash
BACKUP_DIR="/var/backups/lnksns"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Database backup
mysqldump -u lnksns_user -pyour_password lnksns > $BACKUP_DIR/db_$DATE.sql

# Application files backup
tar -czf $BACKUP_DIR/app_$DATE.tar.gz /var/www/lnksns

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
```

Make it executable:
```bash
sudo chmod +x /usr/local/bin/lnksns-backup.sh
```

### Cron Job for Daily Backups
```bash
sudo crontab -e

# Add this line for daily backup at 2 AM
0 2 * * * /usr/local/bin/lnksns-backup.sh
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   sudo chown -R www-data:www-data /var/www/lnksns
   sudo chmod -R 755 /var/www/lnksns
   ```

2. **MySQL Connection Failed**
   - Check MySQL service: `sudo systemctl status mysql`
   - Verify credentials in `.env`
   - Test connection: `mysql -u lnksns_user -p lnksns`

3. **PHP Extensions Missing**
   ```bash
   sudo apt install php8.2-mysql php8.2-curl php8.2-xml php8.2-mbstring
   sudo systemctl restart php8.2-fpm
   ```

4. **Nginx Configuration Error**
   ```bash
   sudo nginx -t
   sudo systemctl restart nginx
   ```

## Security Considerations

1. Change default MySQL root password
2. Use strong passwords for database user
3. Enable firewall
4. Keep system updated: `sudo apt update && sudo apt upgrade`
5. Use HTTPS with SSL certificates
6. Regular backups
7. Monitor logs regularly

## Performance Optimization

1. Enable PHP OPcache
2. Configure MySQL query cache
3. Use Redis for caching (optional)
4. Enable gzip compression in Nginx
5. Set up CDN for static files (optional)

Your lnksns application should now be running successfully on your Debian server!