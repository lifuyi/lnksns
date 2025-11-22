# LnkSns Debian Deployment - Quick Start Guide

## Overview
Complete deployment solution for moving your LnkSns backend service to a Debian server with MySQL.

## Quick Deployment Steps

### 1. **Server Preparation (Run on Debian Server)**
```bash
# Upload scripts to your server
scp install-debian.sh user@your-server:/tmp/
scp setup-database.sh user@your-server:/tmp/
scp deploy-to-server.sh user@your-server:/tmp/
scp backup.sh user@your-server:/tmp/

# SSH to server and run
ssh user@your-server
cd /tmp
chmod +x *.sh

# Install dependencies
./install-debian.sh

# Setup database (will prompt for MySQL root password)
./setup-database.sh

# Deploy application (specify path to your app source)
./deploy-to-server.sh /path/to/your/lnksns/source
```

### 2. **SSL Certificate (Optional but Recommended)**
```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### 3. **Backup Setup**
```bash
# Setup automated backups
sudo cp backup.sh /usr/local/bin/lnksns-backup
sudo chmod +x /usr/local/bin/lnksns-backup

# Setup daily cron job
sudo crontab -e
# Add: 0 2 * * * /usr/local/bin/lnksns-backup
```

## Files Created

| File | Purpose |
|------|---------|
| `install-debian.sh` | Installs PHP, MySQL, Nginx, and dependencies |
| `setup-database.sh` | Creates MySQL database and user with secure credentials |
| `deploy-to-server.sh` | Deploys application with proper permissions and Nginx config |
| `backup.sh` | Automated backup script for database and files |
| `DEPLOY_DEBIAN.md` | Comprehensive deployment documentation |
| `.env.production.template` | Production environment configuration template |
| `nginx-production.conf` | Production-ready Nginx configuration |

## Configuration Files

### Environment Configuration
- Copy `.env.production.template` to `.env`
- Update database credentials from setup-database.sh output
- Configure other services (WeChat, email, etc.) as needed

### Nginx Configuration
- Production config: `nginx-production.conf`
- Automatically configured by deploy-to-server.sh
- SSL enabled with security headers

## Key Features

### ✅ **Automated Installation**
- PHP 8.2 with all required extensions
- MySQL server with secure setup
- Nginx web server
- Composer package manager
- Redis for caching
- Supervisor for process management
- Firewall configuration

### ✅ **Security Features**
- SSL/TLS support
- Security headers (HSTS, XSS Protection, etc.)
- Rate limiting configuration
- File upload security
- Permission hardening

### ✅ **Performance Optimization**
- OPcache enabled
- Gzip compression
- Static file caching
- PHP-FPM tuning

### ✅ **Monitoring & Backup**
- Automated daily backups
- Log rotation
- Health check endpoint
- Service monitoring

### ✅ **Production Ready**
- Environment-specific configs
- Error handling
- Security best practices
- Scalable architecture

## Directory Structure on Server
```
/var/www/lnksns/          # Application root
├── public/               # Web accessible files
├── app/                  # Application code
├── runtime/              # Logs, cache, temp files
├── vendor/               # PHP dependencies
└── .env                  # Environment configuration

/var/backups/lnksns/      # Backup directory
/var/log/nginx/           # Nginx logs
/var/log/mysql/           # MySQL logs
```

## Next Steps After Deployment

1. **Configure Environment**
   ```bash
   cd /var/www/lnksns
   nano .env  # Update with your settings
   ```

2. **Run Migrations**
   ```bash
   php think migrate:run
   php think seed:run
   ```

3. **Test Application**
   - Visit your domain
   - Check all functionality
   - Review logs

4. **Monitor Services**
   ```bash
   sudo systemctl status nginx mysql php8.2-fpm
   sudo supervisorctl status
   ```

## Common Commands

### Service Management
```bash
# Restart services
sudo systemctl restart nginx php8.2-fpm

# Check status
sudo systemctl status nginx mysql php8.2-fpm
sudo supervisorctl status

# View logs
sudo tail -f /var/www/lnksns/runtime/log/app.log
sudo tail -f /var/log/nginx/access.log
```

### Database Management
```bash
# Connect to database
mysql -u lnksns_user -p lnksns

# Backup database
mysqldump -u lnksns_user -p lnksns > backup.sql

# Restore database
mysql -u lnksns_user -p lnksns < backup.sql
```

### Application Management
```bash
# Clear cache
php think clear

# Update dependencies
composer install --no-dev

# Run queue workers
php think queue:work
```

## Troubleshooting

### Common Issues
1. **Permission errors**: Check `/var/www/lnksns` ownership
2. **Database connection**: Verify `.env` credentials
3. **SSL issues**: Check certificate configuration
4. **Performance**: Monitor PHP-FPM and database

### Health Check
```bash
# Test application
curl -I http://your-domain.com

# Test database connection
mysql -u lnksns_user -p lnksns -e "SELECT 1;"
```

## Security Checklist

- [ ] SSL certificate installed
- [ ] Firewall configured (ports 22, 80, 443)
- [ ] Strong database password
- [ ] APP_DEBUG = false
- [ ] Regular backups enabled
- [ ] Monitoring setup
- [ ] Security headers enabled
- [ ] File permissions secure

Your LnkSns application is now ready for production deployment on Debian!