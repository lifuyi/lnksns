# LnkSns Database Schema Investigation & Reconstruction

## Overview
Complete database schema investigation and reconstruction for the LnkSns application, creating a comprehensive SQL file that can rebuild the entire database structure.

## Investigation Summary

### Database Structure Analysis
I thoroughly investigated the LnkSns database schema by examining:

1. **Existing SQL Schema**: `/app/install/install.sql` - Complete existing database with sample data
2. **Model Files**: Analyzed all model classes to understand table relationships and structure
3. **Table Naming Convention**: Uses `__PREFIX__` placeholder system for flexible table prefixes

### Database Tables Identified

The LnkSns application uses **17 tables** across two main areas:

#### System Administration Tables (7 tables)
| Table | Purpose | Key Features |
|-------|---------|-------------|
| `__PREFIX__admin` | Admin users | User management, roles, authentication |
| `__PREFIX__admin_role` | Admin roles | Role-based permissions |
| `__PREFIX__config` | System configuration | Application settings storage |
| `__PREFIX__file` | File management | Uploaded files, images, documents |
| `__PREFIX__file_group` | File organization | File categorization |
| `__PREFIX__permissions` | Menu permissions | Frontend navigation control |
| `__PREFIX__page` | Custom pages | Dynamic page content |

#### LnkSns Application Tables (10 tables)
| Table | Purpose | Key Features |
|-------|---------|-------------|
| `__PREFIX__free_user` | User accounts | WeChat integration, profiles, location |
| `__PREFIX__free_circle` | Circles/Groups | Design categories, community groups |
| `__PREFIX__free_circle_fans` | Circle membership | User-circle relationships |
| `__PREFIX__free_dynamic` | Posts/Content | User-generated content, multimedia |
| `__PREFIX__free_dynamic_img` | Post images | Image attachments for posts |
| `__PREFIX__free_dynamic_comment` | Comments | Nested comment system |
| `__PREFIX__free_user_follow` | User relationships | Follow/follower system |
| `__PREFIX__free_user_like_dynamic` | Likes | Like/unlike functionality |
| `__PREFIX__free_message` | Notifications | In-app messaging system |
| `__PREFIX__free_clause` | Legal terms | Terms of service, privacy policy |

## Files Created

### 1. `lnksns_database_schema.sql` 
**Complete database schema file**
- Clean schema without sample data
- 17 tables with proper indexes and constraints
- UTF8MB4 character set support
- Commented foreign key relationships
- Optional performance indexes
- Table prefix support (`__PREFIX__` replacement)

### 2. `setup-database-schema.sh`
**Automated database setup script**
- Interactive database configuration
- Automatic prefix replacement
- Database creation and verification
- Connection testing
- Summary reporting

## Key Database Features

### Character Set & Collation
- **Character Set**: `utf8mb4` (full Unicode support including emojis)
- **Collation**: `utf8mb4_unicode_ci` (case-insensitive Unicode sorting)

### Data Types Used
- `VARCHAR` with appropriate lengths for text fields
- `TEXT` and `MEDIUMTEXT` for long content
- `INT` and `BIGINT` for numeric identifiers
- `TINYINT` for boolean flags and enums
- `TIMESTAMP` for created/updated time tracking

### Indexes & Performance
- Primary keys on all tables
- Foreign key indexes for relationships
- Unique constraints for business logic
- Full-text search index on dynamic content
- Composite indexes for common query patterns

### Special Features
- **Location Support**: Latitude/longitude fields for geo-based features
- **WeChat Integration**: OpenID storage for social login
- **Multimedia Support**: Image dimensions, file sizes, MIME types
- **Audit Trail**: Created/updated timestamps on all tables
- **Soft Delete**: Status fields instead of hard deletes

## Usage Instructions

### Quick Setup
```bash
# Make script executable
chmod +x setup-database-schema.sh

# Run database setup
./setup-database-schema.sh
```

### Manual Setup
```bash
# 1. Create database
mysql -u root -p -e "CREATE DATABASE lnksns CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 2. Replace prefix and import schema
sed 's/__PREFIX__/lite_/g' lnksns_database_schema.sql | mysql -u root -p lnksns

# 3. Verify setup
mysql -u root -p -e "USE lnksns; SHOW TABLES;"
```

### Environment Configuration
Update your `.env` file with database settings:
```ini
[DATABASE]
TYPE = mysql
HOSTNAME = localhost
DATABASE = lnksns
USERNAME = your_username
PASSWORD = your_password
HOSTPORT = 3306
CHARSET = utf8mb4
PREFIX = lite_
DEBUG = false
```

## Schema Highlights

### User Management
- **Flexible User Profiles**: Name, avatar, gender, age group, career
- **Location Support**: Country, province, city, district with coordinates
- **Social Integration**: WeChat OpenID for easy login
- **Privacy Controls**: Status flags and visibility settings

### Content System
- **Rich Media Posts**: Text content with multiple image attachments
- **Categorization**: Circle-based content organization
- **Social Features**: Follow relationships, likes, comments
- **Location Tagging**: Posts can include geographic information

### Community Features
- **Circles/Groups**: Themed communities (UI Design, Illustration, etc.)
- **Membership Management**: User-circle relationships with approval workflow
- **Content Moderation**: Status flags for content visibility control
- **Engagement Tracking**: View counts, like counts, comment counts

### Administrative Features
- **Role-Based Access**: Admin roles with granular permissions
- **File Management**: Uploaded asset organization and storage
- **System Configuration**: Flexible key-value configuration system
- **Legal Compliance**: Terms of service and privacy policy storage

## Migration Considerations

### From SQLite to MySQL
The original system used SQLite, but the schema is optimized for MySQL with:
- Proper indexing strategies for MySQL query optimizer
- InnoDB engine for transaction support
- UTF8MB4 for full Unicode compliance
- Foreign key constraints (optional but recommended)

### Data Migration
For existing SQLite data migration:
1. Export SQLite data using appropriate tools
2. Transform data types to match MySQL schema
3. Handle special characters and encoding conversion
4. Test foreign key relationships after import

## Performance Optimization

### Recommended Additional Indexes
```sql
-- For better search performance
CREATE INDEX idx_dynamic_content_status ON `lite_free_dynamic` (`content`(100), `status`);
CREATE INDEX idx_user_name_status ON `lite_free_user` (`name`, `status`);
CREATE INDEX idx_message_user_read ON `lite_free_message` (`user_id`, `read`, `create_time`);
CREATE INDEX idx_comment_dynamic_time ON `lite_free_dynamic_comment` (`dynamic_id`, `create_time`);
```

### Query Optimization Tips
- Use `LIMIT` clauses for paginated results
- Implement caching for frequently accessed data
- Consider partitioning for large tables (dynamic, comments)
- Monitor slow query log for optimization opportunities

## Security Considerations

### Data Protection
- Password hashing with salt (implement in application layer)
- Input validation and sanitization (application responsibility)
- File upload restrictions and validation
- SQL injection prevention (use prepared statements)

### Access Control
- Admin role permissions are stored as comma-separated values
- User privacy through status flags
- Content moderation through approval workflows

## Backup Strategy

### Recommended Backup Approach
```bash
# Daily automated backup
mysqldump -u username -p --single-transaction --routines --triggers lnksns > backup_$(date +%Y%m%d).sql

# Include schema and data
mysqldump -u username -p --data --schema lnksns > full_backup_$(date +%Y%m%d).sql
```

### Restoration Process
```bash
# Restore from backup
mysql -u username -p lnksns < backup_20231122.sql

# Verify restoration
mysql -u username -p -e "USE lnksns; SELECT COUNT(*) FROM lite_free_user;"
```

## Conclusion

The LnkSns database schema is well-designed for a social design community platform, supporting:
- **User Management**: Flexible profiles with social integration
- **Content Creation**: Rich media posts with community organization
- **Social Features**: Follows, likes, comments, and messaging
- **Administration**: Comprehensive admin panel with role-based access
- **Scalability**: Proper indexing and optimization for growth

The provided SQL schema file and setup script enable easy database reconstruction on any MySQL-compatible server, making deployment and migration straightforward.