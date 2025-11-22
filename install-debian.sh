#!/bin/bash

# LnkSns Debian Server Installation Script
# This script automates the installation of all dependencies

set -e  # Exit on any error

echo "=== LnkSns Debian Server Installation ==="
echo "This script will install PHP, MySQL, Nginx, and other dependencies"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}This script should not be run as root for security reasons.${NC}"
   echo "Please run as a regular user with sudo privileges."
   exit 1
fi

# Update system
echo -e "${YELLOW}Updating system packages...${NC}"
sudo apt update && sudo apt upgrade -y

# Install basic dependencies
echo -e "${YELLOW}Installing basic dependencies...${NC}"
sudo apt install -y curl wget unzip git software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Install PHP 8.2 and extensions
echo -e "${YELLOW}Installing PHP 8.2 and required extensions...${NC}"
sudo apt install -y php8.2 php8.2-fpm php8.2-mysql php8.2-curl php8.2-xml php8.2-mbstring php8.2-zip php8.2-gd php8.2-json php8.2-intl php8.2-bcmath php8.2-imap php8.2-soap

# Install Composer
echo -e "${YELLOW}Installing Composer...${NC}"
if ! command -v composer &> /dev/null; then
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    sudo chmod +x /usr/local/bin/composer
    echo -e "${GREEN}Composer installed successfully${NC}"
else
    echo -e "${GREEN}Composer already installed${NC}"
fi

# Install Nginx
echo -e "${YELLOW}Installing Nginx...${NC}"
sudo apt install -y nginx

# Install MySQL Server
echo -e "${YELLOW}Installing MySQL Server...${NC}"
echo "mysql-server mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | sudo debconf-set-selections
sudo apt install -y mysql-server

# Install additional tools
echo -e "${YELLOW}Installing additional tools...${NC}"
sudo apt install -y supervisor redis-server fail2ban ufw htop nano vim

# Enable and start services
echo -e "${YELLOW}Enabling and starting services...${NC}"
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl enable mysql
sudo systemctl start mysql
sudo systemctl enable php8.2-fpm
sudo systemctl start php8.2-fpm
sudo systemctl enable supervisor
sudo systemctl start supervisor

# Configure PHP for production
echo -e "${YELLOW}Configuring PHP for production...${NC}"
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php/8.2/fpm/php.ini
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/8.2/fpm/php.ini
sudo sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php/8.2/fpm/php.ini
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php/8.2/fpm/php.ini
sudo sed -i 's/memory_limit = 128M/memory_limit = 512M/' /etc/php/8.2/fpm/php.ini

# Enable OPcache
echo -e "${YELLOW}Enabling OPcache...${NC}"
sudo sed -i 's/;opcache.enable=1/opcache.enable=1/' /etc/php/8.2/fpm/php.ini
sudo sed -i 's/;opcache.memory_consumption=128/opcache.memory_consumption=256/' /etc/php/8.2/fpm/php.ini
sudo sed -i 's/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=20000/' /etc/php/8.2/fpm/php.ini
sudo sed -i 's/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/' /etc/php/8.2/fpm/php.ini

# Restart PHP-FPM
sudo systemctl restart php8.2-fpm

# Configure firewall
echo -e "${YELLOW}Configuring firewall...${NC}"
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

echo ""
echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Secure MySQL: sudo mysql_secure_installation"
echo "2. Create database: see database setup script"
echo "3. Upload application files to /var/www/lnksns"
echo "4. Configure environment: cp .example.env .env"
echo "5. Run: ./deploy-to-server.sh"
echo ""
echo -e "${GREEN}Services installed:${NC}"
echo "- PHP 8.2 with FPM"
echo "- Nginx web server"
echo "- MySQL database server"
echo "- Composer package manager"
echo "- Supervisor process manager"
echo "- Redis (for caching)"
echo "- Firewall (UFW) configured"
echo ""
echo -e "${YELLOW}Service status:${NC}"
sudo systemctl status nginx --no-pager -l
sudo systemctl status mysql --no-pager -l
sudo systemctl status php8.2-fpm --no-pager -l