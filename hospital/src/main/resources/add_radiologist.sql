-- PostgreSQL script aligned with the medical imaging platform document.
-- Structured data: PostgreSQL. Queue/cache: Redis. Binary assets: MinIO/NAS via URI columns.

-- 添加放射科医生角色和账号

-- 1. 添加放射科医生角色 (id=4)
INSERT INTO power_role (id, name, chinese_name, admin_count, sort, status, gmt_create, gmt_modified) VALUES
(4, 'radiologist', '放射科医生', 0, 4, 1, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET name = 'radiologist', chinese_name = '放射科医生', status = 1;

-- 2. 添加 radiologist1 账号 (密码: 123456)
-- 前端会先 SHA256 加密明文密码，后端再使用 BCrypt 校验
-- 这里存储的是 SHA256("123456") 后字符串的 BCrypt 值
INSERT INTO power_account (id, name, password, status, gmt_create, gmt_modified) VALUES
(1008, 'radiologist1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET password = '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', status = 1;

-- 3. 添加账号角色关联
INSERT INTO power_account_role_relation (account_id, role_id) VALUES
(1008, 4)
ON CONFLICT DO NOTHING;
