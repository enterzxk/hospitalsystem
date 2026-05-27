-- 修复 power_account 表缺少 login_time 列
ALTER TABLE `power_account` ADD COLUMN `login_time` datetime(0) NULL DEFAULT NULL COMMENT '最后登录时间' AFTER `status`;

-- 添加放射科医生角色 (id=4)
INSERT INTO `power_role` (`id`, `name`, `description`, `gmt_create`, `gmt_modified`) VALUES
(4, '放射科医生', '放射科医生，负责影像诊断和标注', NOW(), NOW())
ON DUPLICATE KEY UPDATE `name` = '放射科医生';

-- 添加 radiologist1 账号 (密码: 123456)
INSERT INTO `power_account` (`id`, `name`, `password`, `status`, `role_id`, `gmt_create`, `gmt_modified`) VALUES
(1008, 'radiologist1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, 4, NOW(), NOW())
ON DUPLICATE KEY UPDATE `password` = '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', `role_id` = 4, `status` = 1;

-- 添加账号角色关联
INSERT INTO `power_account_role_relation` (`account_id`, `role_id`, `gmt_create`, `gmt_modified`) VALUES
(1008, 4, NOW(), NOW())
ON DUPLICATE KEY UPDATE `role_id` = 4;
