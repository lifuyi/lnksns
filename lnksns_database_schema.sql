-- LnkSns Database Schema
-- Complete database structure for LnkSns application
-- Compatible with MySQL 5.7+ and MariaDB 10.2+
-- Generated: 2025-11-22

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ================================================
-- SYSTEM ADMIN TABLES
-- ================================================

-- ----------------------------
-- Table structure for __PREFIX__admin
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__admin`;
CREATE TABLE `__PREFIX__admin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NOT NULL DEFAULT '0' COMMENT 'Role ID',
  `username` varchar(60) NOT NULL DEFAULT '' COMMENT 'Username',
  `nickname` varchar(60) NOT NULL DEFAULT '' COMMENT 'Nickname',
  `mobile` varchar(20) DEFAULT NULL COMMENT 'Mobile phone',
  `password` varchar(60) NOT NULL DEFAULT '' COMMENT 'Password (hashed)',
  `salt` varchar(30) NOT NULL DEFAULT '' COMMENT 'Password salt',
  `avatar` varchar(255) NOT NULL DEFAULT '' COMMENT 'Avatar URL',
  `email` varchar(60) DEFAULT NULL COMMENT 'Email',
  `login_fail` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'Login failure count',
  `login_time` int(11) DEFAULT NULL COMMENT 'Last login time',
  `login_ip` varchar(20) DEFAULT NULL COMMENT 'Last login IP',
  `is_super` enum('1','0') NOT NULL DEFAULT '0' COMMENT 'Is super admin',
  `status` enum('normal','disabled') NOT NULL DEFAULT 'normal' COMMENT 'Status',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`),
  UNIQUE KEY `account` (`username`),
  UNIQUE KEY `mobile` (`mobile`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='Admin users table';

-- ----------------------------
-- Table structure for __PREFIX__admin_role
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__admin_role`;
CREATE TABLE `__PREFIX__admin_role` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) NOT NULL DEFAULT '0' COMMENT 'Parent role ID',
  `name` varchar(60) NOT NULL DEFAULT '' COMMENT 'Role name',
  `code` varchar(60) NOT NULL DEFAULT '' COMMENT 'Role code',
  `description` varchar(255) DEFAULT NULL COMMENT 'Description',
  `rules` varchar(2500) NOT NULL DEFAULT '' COMMENT 'Permission rules',
  `status` enum('normal','disabled') NOT NULL DEFAULT 'normal' COMMENT 'Status',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='Admin roles table';

-- ----------------------------
-- Table structure for __PREFIX__config
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__config`;
CREATE TABLE `__PREFIX__config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(100) NOT NULL DEFAULT '' COMMENT 'Config type',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT 'Config name',
  `key` varchar(255) NOT NULL DEFAULT '' COMMENT 'Config key',
  `value` varchar(255) DEFAULT NULL COMMENT 'Config value',
  `status` enum('normal','disabled') NOT NULL DEFAULT 'normal' COMMENT 'Status',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`),
  KEY `type_key` (`type`, `key`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='System configuration table';

-- ----------------------------
-- Table structure for __PREFIX__file
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__file`;
CREATE TABLE `__PREFIX__file` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NOT NULL DEFAULT '0' COMMENT 'Admin user ID',
  `uri` varchar(255) DEFAULT NULL COMMENT 'File path',
  `image_width` int(11) NOT NULL DEFAULT '0' COMMENT 'Image width',
  `image_height` int(11) NOT NULL DEFAULT '0' COMMENT 'Image height',
  `group` varchar(60) NOT NULL DEFAULT 'default' COMMENT 'File group',
  `group_id` int(11) DEFAULT NULL COMMENT 'Group ID',
  `extension` varchar(60) DEFAULT NULL COMMENT 'File extension',
  `filename` varchar(255) DEFAULT NULL COMMENT 'Filename',
  `storage` varchar(60) DEFAULT NULL COMMENT 'Storage driver',
  `filesize` int(11) NOT NULL DEFAULT '0' COMMENT 'File size in bytes',
  `mimetype` varchar(191) DEFAULT NULL COMMENT 'MIME type',
  `file_md5` varchar(60) DEFAULT NULL COMMENT 'File MD5 hash',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`),
  KEY `extension` (`extension`),
  KEY `mimetype` (`mimetype`),
  KEY `file_group` (`group`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='File management table';

-- ----------------------------
-- Table structure for __PREFIX__file_group
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__file_group`;
CREATE TABLE `__PREFIX__file_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) DEFAULT NULL COMMENT 'Group name',
  `group` varchar(60) NOT NULL DEFAULT '' COMMENT 'Group identifier',
  `weigh` int(11) NOT NULL DEFAULT '0' COMMENT 'Weight for sorting',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`),
  UNIQUE KEY `group` (`group`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='File groups table';

-- ----------------------------
-- Table structure for __PREFIX__permissions
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__permissions`;
CREATE TABLE `__PREFIX__permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) NOT NULL DEFAULT '0' COMMENT 'Parent permission ID',
  `permission_mark` varchar(191) NOT NULL DEFAULT '' COMMENT 'Permission mark',
  `permission_name` varchar(255) NOT NULL DEFAULT '' COMMENT 'Permission name',
  `type` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Type: 0=directory, 1=menu, 2=button',
  `icon` varchar(255) DEFAULT NULL COMMENT 'Icon class',
  `params` varchar(255) DEFAULT NULL COMMENT 'Additional parameters',
  `route` varchar(255) NOT NULL DEFAULT '' COMMENT 'Frontend route',
  `component` varchar(255) DEFAULT NULL COMMENT 'Vue component',
  `redirect` varchar(255) DEFAULT NULL COMMENT 'Redirect URL',
  `weigh` int(11) NOT NULL DEFAULT '0' COMMENT 'Weight for sorting',
  `status` enum('show','hidden','disabled') NOT NULL DEFAULT 'show' COMMENT 'Status',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`),
  UNIQUE KEY `permission_name` (`permission_name`),
  KEY `parent_id` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='Permissions table';

-- ----------------------------
-- Table structure for __PREFIX__page
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__page`;
CREATE TABLE `__PREFIX__page` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL DEFAULT '' COMMENT 'Page name',
  `app` varchar(100) NOT NULL DEFAULT '' COMMENT 'Application name',
  `page` longtext COMMENT 'Page data (JSON)',
  `weigh` int(11) NOT NULL DEFAULT '100' COMMENT 'Weight for sorting',
  `status` enum('normal','disabled') NOT NULL DEFAULT 'normal' COMMENT 'Status',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Custom pages table';

-- ================================================
-- Lnksns APPLICATION TABLES
-- ================================================

-- ----------------------------
-- Table structure for __PREFIX__free_circle
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__free_circle`;
CREATE TABLE `__PREFIX__free_circle` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL COMMENT 'Creator user ID',
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Circle name',
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Circle avatar',
  `intro` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Circle introduction',
  `ip` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'IP address',
  `lat` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Latitude',
  `lng` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Longitude',
  `country` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Country',
  `province` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Province/State',
  `city` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'City',
  `district` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'District',
  `highlight` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Is highlighted (1=yes, 0=no)',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status (1=active, 0=inactive)',
  `weigh` int(11) NOT NULL DEFAULT '0' COMMENT 'Weight for sorting',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_weigh` (`weigh`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Circles table';

-- ----------------------------
-- Table structure for __PREFIX__free_circle_fans
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__free_circle_fans`;
CREATE TABLE `__PREFIX__free_circle_fans` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT 'User ID',
  `circle_id` int(11) NOT NULL COMMENT 'Circle ID',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Status (0=pending, 1=approved)',
  `weigh` int(11) NOT NULL DEFAULT '0' COMMENT 'Weight for sorting',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_user_circle` (`user_id`, `circle_id`),
  KEY `idx_circle_id` (`circle_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Circle members table';

-- ----------------------------
-- Table structure for __PREFIX__free_clause
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__free_clause`;
CREATE TABLE `__PREFIX__free_clause` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT 'Clause title',
  `content` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Clause content (HTML)',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Status (1=active, 0=inactive)',
  `weigh` int(11) NOT NULL DEFAULT '0' COMMENT 'Weight for sorting',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_status` (`status`),
  KEY `idx_weigh` (`weigh`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Terms and conditions table';

-- ----------------------------
-- Table structure for __PREFIX__free_dynamic
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__free_dynamic`;
CREATE TABLE `__PREFIX__free_dynamic` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT 'Author user ID',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Dynamic content',
  `circle_id` int(11) NOT NULL COMMENT 'Circle ID',
  `circle_name` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Circle name',
  `ip` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'IP address',
  `lat` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Latitude',
  `lng` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Longitude',
  `country` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Country',
  `province` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Province/State',
  `city` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'City',
  `district` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'District',
  `view` int(11) DEFAULT '0' COMMENT 'View count',
  `adds` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Location address',
  `top` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Is top (1=yes, 0=no)',
  `show` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Is visible (1=yes, 0=no)',
  `type` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Dynamic type',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status (1=active, 0=inactive)',
  `weigh` int(11) NOT NULL DEFAULT '0' COMMENT 'Weight for sorting',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`),
  KEY `idx_circle_id` (`circle_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_top` (`top`),
  FULLTEXT KEY `ft_content` (`content`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Dynamic posts table';

-- ----------------------------
-- Table structure for __PREFIX__free_dynamic_comment
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__free_dynamic_comment`;
CREATE TABLE `__PREFIX__free_dynamic_comment` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `dynamic_id` int(11) NOT NULL COMMENT 'Dynamic ID',
  `user_id` int(11) NOT NULL COMMENT 'Comment author user ID',
  `reply_user_id` int(11) DEFAULT NULL COMMENT 'Reply to user ID',
  `reply_comment_id` int(11) DEFAULT NULL COMMENT 'Reply to comment ID',
  `content` text COLLATE utf8mb4_unicode_ci COMMENT 'Comment content',
  `ip` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'IP address',
  `lat` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Latitude',
  `lng` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Longitude',
  `country` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Country',
  `province` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Province/State',
  `city` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'City',
  `district` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'District',
  `type` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Comment type',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Status (1=active, 0=inactive)',
  `weigh` int(11) NOT NULL DEFAULT '0' COMMENT 'Weight for sorting',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_dynamic_id` (`dynamic_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_reply_user_id` (`reply_user_id`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Dynamic comments table';

-- ----------------------------
-- Table structure for __PREFIX__free_dynamic_img
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__free_dynamic_img`;
CREATE TABLE `__PREFIX__free_dynamic_img` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Image URL',
  `wide` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Image width',
  `high` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'Image height',
  `dynamic_id` int(11) NOT NULL COMMENT 'Dynamic ID',
  `user_id` int(11) NOT NULL COMMENT 'Uploader user ID',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Status (1=active, 0=inactive)',
  `weigh` int(11) NOT NULL DEFAULT '0' COMMENT 'Weight for sorting',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_dynamic_id` (`dynamic_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Dynamic images table';

-- ----------------------------
-- Table structure for __PREFIX__free_message
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__free_message`;
CREATE TABLE `__PREFIX__free_message` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `launch_id` int(11) NOT NULL COMMENT 'Sender user ID',
  `user_id` int(11) NOT NULL COMMENT 'Receiver user ID',
  `title` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0' COMMENT 'Message title',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Message content',
  `img` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '0' COMMENT 'Message image',
  `avatar_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Avatar URL for navigation',
  `content_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Content URL for navigation',
  `read` tinyint(1) unsigned zerofill NOT NULL DEFAULT '0' COMMENT 'Is read (1=yes, 0=no)',
  `type` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Message type',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Status (1=active, 0=inactive)',
  `weigh` int(11) NOT NULL DEFAULT '0' COMMENT 'Weight for sorting',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_user_id` (`user_id`),
  KEY `idx_launch_id` (`launch_id`),
  KEY `idx_read` (`read`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User messages table';

-- ----------------------------
-- Table structure for __PREFIX__free_user
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__free_user`;
CREATE TABLE `__PREFIX__free_user` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'User name',
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT 'User avatar',
  `gender` tinyint(1) unsigned zerofill DEFAULT '0' COMMENT 'Gender (1=male, 2=female, 0=unknown)',
  `age` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Age group',
  `career` varchar(20) CHARACTER SET utf8 DEFAULT '' COMMENT 'Career/profession',
  `mobile` varchar(20) CHARACTER SET utf8 DEFAULT '' COMMENT 'Mobile phone',
  `ip` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'IP address',
  `lat` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Latitude',
  `lng` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Longitude',
  `country` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Country',
  `province` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'Province/State',
  `city` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'City',
  `district` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'District',
  `weixin_openid` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '' COMMENT 'WeChat OpenID',
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Status (1=active, 0=inactive)',
  `weigh` int(11) NOT NULL DEFAULT '0' COMMENT 'Weight for sorting',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_weixin_openid` (`weixin_openid`),
  KEY `idx_name` (`name`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User accounts table';

-- ----------------------------
-- Table structure for __PREFIX__free_user_follow
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__free_user_follow`;
CREATE TABLE `__PREFIX__free_user_follow` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT 'Follower user ID',
  `follow_user_id` int(11) NOT NULL COMMENT 'Following user ID',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Status (1=active, 0=inactive)',
  `weigh` int(11) NOT NULL DEFAULT '0' COMMENT 'Weight for sorting',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_user_follow` (`user_id`, `follow_user_id`),
  KEY `idx_follow_user_id` (`follow_user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User follow relationships table';

-- ----------------------------
-- Table structure for __PREFIX__free_user_like_dynamic
-- ----------------------------
DROP TABLE IF EXISTS `__PREFIX__free_user_like_dynamic`;
CREATE TABLE `__PREFIX__free_user_like_dynamic` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT 'User ID',
  `dynamic_id` int(11) NOT NULL COMMENT 'Dynamic ID',
  `status` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Status (1=liked, 0=unliked)',
  `weigh` int(11) NOT NULL DEFAULT '0' COMMENT 'Weight for sorting',
  `create_time` int(11) DEFAULT NULL COMMENT 'Created time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Updated time',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_user_dynamic` (`user_id`, `dynamic_id`),
  KEY `idx_dynamic_id` (`dynamic_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User dynamic likes table';

-- ================================================
-- FOREIGN KEY RELATIONSHIPS
-- ================================================

-- Add foreign key constraints (optional, can be enabled later)
-- ALTER TABLE `__PREFIX__admin` ADD CONSTRAINT `fk_admin_role` FOREIGN KEY (`role_id`) REFERENCES `__PREFIX__admin_role` (`id`);
-- ALTER TABLE `__PREFIX__free_circle` ADD CONSTRAINT `fk_circle_user` FOREIGN KEY (`user_id`) REFERENCES `__PREFIX__free_user` (`id`);
-- ALTER TABLE `__PREFIX__free_circle_fans` ADD CONSTRAINT `fk_circle_fans_user` FOREIGN KEY (`user_id`) REFERENCES `__PREFIX__free_user` (`id`);
-- ALTER TABLE `__PREFIX__free_circle_fans` ADD CONSTRAINT `fk_circle_fans_circle` FOREIGN KEY (`circle_id`) REFERENCES `__PREFIX__free_circle` (`id`);
-- ALTER TABLE `__PREFIX__free_dynamic` ADD CONSTRAINT `fk_dynamic_user` FOREIGN KEY (`user_id`) REFERENCES `__PREFIX__free_user` (`id`);
-- ALTER TABLE `__PREFIX__free_dynamic` ADD CONSTRAINT `fk_dynamic_circle` FOREIGN KEY (`circle_id`) REFERENCES `__PREFIX__free_circle` (`id`);
-- ALTER TABLE `__PREFIX__free_dynamic_comment` ADD CONSTRAINT `fk_comment_dynamic` FOREIGN KEY (`dynamic_id`) REFERENCES `__PREFIX__free_dynamic` (`id`);
-- ALTER TABLE `__PREFIX__free_dynamic_comment` ADD CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `__PREFIX__free_user` (`id`);
-- ALTER TABLE `__PREFIX__free_dynamic_img` ADD CONSTRAINT `fk_img_dynamic` FOREIGN KEY (`dynamic_id`) REFERENCES `__PREFIX__free_dynamic` (`id`);
-- ALTER TABLE `__PREFIX__free_dynamic_img` ADD CONSTRAINT `fk_img_user` FOREIGN KEY (`user_id`) REFERENCES `__PREFIX__free_user` (`id`);
-- ALTER TABLE `__PREFIX__free_message` ADD CONSTRAINT `fk_message_user` FOREIGN KEY (`user_id`) REFERENCES `__PREFIX__free_user` (`id`);
-- ALTER TABLE `__PREFIX__free_message` ADD CONSTRAINT `fk_message_launch` FOREIGN KEY (`launch_id`) REFERENCES `__PREFIX__free_user` (`id`);
-- ALTER TABLE `__PREFIX__free_user_follow` ADD CONSTRAINT `fk_follow_user` FOREIGN KEY (`user_id`) REFERENCES `__PREFIX__free_user` (`id`);
-- ALTER TABLE `__PREFIX__free_user_follow` ADD CONSTRAINT `fk_follow_follow_user` FOREIGN KEY (`follow_user_id`) REFERENCES `__PREFIX__free_user` (`id`);
-- ALTER TABLE `__PREFIX__free_user_like_dynamic` ADD CONSTRAINT `fk_like_user` FOREIGN KEY (`user_id`) REFERENCES `__PREFIX__free_user` (`id`);
-- ALTER TABLE `__PREFIX__free_user_like_dynamic` ADD CONSTRAINT `fk_like_dynamic` FOREIGN KEY (`dynamic_id`) REFERENCES `__PREFIX__free_dynamic` (`id`);

SET FOREIGN_KEY_CHECKS = 1;

-- ================================================
-- SAMPLE DATA (OPTIONAL - Comment out if not needed)
-- ================================================

-- Insert default admin role
-- INSERT INTO `__PREFIX__admin_role` (`id`, `parent_id`, `name`, `code`, `description`, `rules`, `status`, `create_time`, `update_time`) VALUES
-- (1, 0, '超级管理员', 'super_admin', '系统超级管理员', '*', 'normal', UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- Insert default admin user (password: admin123, salt: random)
-- INSERT INTO `__PREFIX__admin` (`id`, `role_id`, `username`, `nickname`, `mobile`, `password`, `salt`, `avatar`, `email`, `login_fail`, `login_time`, `login_ip`, `is_super`, `status`, `create_time`, `update_time`) VALUES
-- (1, 1, 'admin', '超级管理员', '', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'random_salt', '/static/images/avatar.png', '', 0, NULL, '', '1', 'normal', UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- Insert default file group
-- INSERT INTO `__PREFIX__file_group` (`id`, `name`, `group`, `weigh`, `create_time`, `update_time`) VALUES
-- (1, '默认分组', 'default', 0, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- Insert default circle categories
-- INSERT INTO `__PREFIX__free_circle` (`id`, `user_id`, `name`, `avatar`, `intro`, `highlight`, `status`, `weigh`, `create_time`, `update_time`) VALUES
-- (1, NULL, '平面设计', '/static/images/default-circle.jpg', '包装、海报、品牌、Logo等平面设计作品', 1, 1, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
-- (2, NULL, 'UI设计', '/static/images/default-circle.jpg', 'APP界面、网页界面、图标设计等', 1, 1, 2, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
-- (3, NULL, '插画', '/static/images/default-circle.jpg', '商业插画、概念设定、游戏原画等', 1, 1, 3, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- Insert default clauses
-- INSERT INTO `__PREFIX__free_clause` (`id`, `title`, `content`, `status`, `weigh`, `create_time`, `update_time`) VALUES
-- (1, '用户协议', '<h1>用户协议</h1><p>这里是用户协议内容...</p>', 1, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
-- (2, '隐私政策', '<h1>隐私政策</h1><p>这里是隐私政策内容...</p>', 1, 2, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

-- ================================================
-- INDEX RECOMMENDATIONS
-- ================================================

-- Additional indexes for performance optimization
-- CREATE INDEX idx_dynamic_content_status ON `__PREFIX__free_dynamic` (`content`(100), `status`);
-- CREATE INDEX idx_user_name_status ON `__PREFIX__free_user` (`name`, `status`);
-- CREATE INDEX idx_message_user_read ON `__PREFIX__free_message` (`user_id`, `read`, `create_time`);
-- CREATE INDEX idx_comment_dynamic_time ON `__PREFIX__free_dynamic_comment` (`dynamic_id`, `create_time`);

-- ================================================
-- COMPLETION MESSAGE
-- ================================================

SELECT 'LnkSns database schema created successfully!' AS status;
SELECT 'Tables created: admin, admin_role, config, file, file_group, permissions, page, free_circle, free_circle_fans, free_clause, free_dynamic, free_dynamic_comment, free_dynamic_img, free_message, free_user, free_user_follow, free_user_like_dynamic' AS tables_info;