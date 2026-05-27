-- =====================================================
-- 修复 hospital_new.sql 与 hospital.sql 的差异
-- 添加所有缺失的列和数据
-- =====================================================

-- 1. 修复 power_role 表 - 添加缺失的列
ALTER TABLE `power_role` ADD COLUMN `chinese_name` varchar(32) NOT NULL DEFAULT '' COMMENT '中文名称' AFTER `name`;
ALTER TABLE `power_role` ADD COLUMN `admin_count` int(11) NOT NULL DEFAULT 0 COMMENT '用户数目' AFTER `chinese_name`;
ALTER TABLE `power_role` ADD COLUMN `sort` int(11) NOT NULL DEFAULT 0 COMMENT '排序' AFTER `admin_count`;
ALTER TABLE `power_role` ADD COLUMN `status` int(11) NOT NULL DEFAULT 1 COMMENT '状态 1：启用，0：禁用' AFTER `sort`;
ALTER TABLE `power_role` DROP COLUMN `description`;

-- 更新角色数据
UPDATE `power_role` SET `chinese_name` = '系统管理员', `name` = 'admin' WHERE `id` = 1;
UPDATE `power_role` SET `chinese_name` = '医生', `name` = 'doctor' WHERE `id` = 2;
UPDATE `power_role` SET `chinese_name` = '患者', `name` = 'patient' WHERE `id` = 3;

-- 添加放射科医生角色
INSERT INTO `power_role` (`id`, `name`, `chinese_name`, `admin_count`, `sort`, `status`, `gmt_create`, `gmt_modified`) VALUES
(4, 'radiologist', '放射科医生', 0, 4, 1, NOW(), NOW())
ON DUPLICATE KEY UPDATE `chinese_name` = '放射科医生';

-- 2. 修复 power_account 表 - 确保有 login_time 和 status 列
-- (已在之前的SQL中添加)

-- 3. 修复 power_resource 表 - 添加 url 列
ALTER TABLE `power_resource` ADD COLUMN `url` varchar(32) NOT NULL DEFAULT '' COMMENT '资源URL' AFTER `name`;
UPDATE `power_resource` SET `url` = `uri` WHERE `url` = '' AND `uri` IS NOT NULL;

-- 4. 添加 radiologist1 账号
INSERT INTO `power_account` (`id`, `name`, `password`, `status`, `role_id`, `gmt_create`, `gmt_modified`) VALUES
(1008, 'radiologist1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, 4, NOW(), NOW())
ON DUPLICATE KEY UPDATE `password` = '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', `role_id` = 4, `status` = 1;

-- 添加账号角色关联
INSERT INTO `power_account_role_relation` (`account_id`, `role_id`, `gmt_create`, `gmt_modified`) VALUES
(1008, 4, NOW(), NOW())
ON DUPLICATE KEY UPDATE `role_id` = 4;
