-- 添加放射科医生角色和账号

-- 1. 添加放射科医生角色 (id=4)
INSERT INTO `power_role` (`id`, `name`, `description`, `gmt_create`, `gmt_modified`) VALUES
(4, '放射科医生', '放射科医生，负责影像诊断和标注', NOW(), NOW())
ON DUPLICATE KEY UPDATE `name` = '放射科医生', `description` = '放射科医生，负责影像诊断和标注';

-- 2. 添加 radiologist1 账号 (密码: 123456)
-- 前端会先 SHA256 加密明文密码，后端再使用 BCrypt 校验
-- 这里存储的是 SHA256("123456") 后字符串的 BCrypt 值
INSERT INTO `power_account` (`id`, `name`, `password`, `role_id`, `gmt_create`, `gmt_modified`) VALUES
(1008, 'radiologist1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 4, NOW(), NOW())
ON DUPLICATE KEY UPDATE `password` = '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', `role_id` = 4;

-- 3. 添加账号角色关联
INSERT INTO `power_account_role_relation` (`account_id`, `role_id`) VALUES
(1008, 4)
ON DUPLICATE KEY UPDATE `role_id` = 4;
