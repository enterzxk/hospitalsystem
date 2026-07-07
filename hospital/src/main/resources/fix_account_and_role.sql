-- PostgreSQL script aligned with the medical imaging platform document.
-- Structured data: PostgreSQL. Queue/cache: Redis. Binary assets: MinIO/NAS via URI columns.

-- 修复 power_account 表缺少 login_time 列
ALTER TABLE power_account ADD COLUMN IF NOT EXISTS login_time timestamp NULL DEFAULT NULL;

-- 添加放射科医生角色 (id=4)
INSERT INTO power_role (id, name, chinese_name, admin_count, sort, status, gmt_create, gmt_modified) VALUES
(4, 'radiologist', '放射科医生', 0, 4, 1, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET name = 'radiologist', chinese_name = '放射科医生', status = 1;

-- 添加 radiologist1 账号 (密码: 123456)
INSERT INTO power_account (id, name, password, status, gmt_create, gmt_modified) VALUES
(1008, 'radiologist1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET password = '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', status = 1;

-- 添加账号角色关联
INSERT INTO power_account_role_relation (account_id, role_id, gmt_create, gmt_modified) VALUES
(1008, 4, NOW(), NOW())
ON CONFLICT DO NOTHING;
