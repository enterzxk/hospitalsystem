-- PostgreSQL script aligned with the medical imaging platform document.
-- Structured data: PostgreSQL. Queue/cache: Redis. Binary assets: MinIO/NAS via URI columns.

-- =====================================================
-- 修复 hospital_new.sql 与 hospital.sql 的差异
-- 添加所有缺失的列和数据
-- =====================================================

-- 1. 修复 power_role 表 - 添加缺失的列
ALTER TABLE power_role ADD COLUMN IF NOT EXISTS chinese_name varchar(32) NOT NULL DEFAULT '';
ALTER TABLE power_role ADD COLUMN IF NOT EXISTS admin_count integer NOT NULL DEFAULT 0;
ALTER TABLE power_role ADD COLUMN IF NOT EXISTS sort integer NOT NULL DEFAULT 0;
ALTER TABLE power_role ADD COLUMN IF NOT EXISTS status integer NOT NULL DEFAULT 1;
ALTER TABLE power_role DROP COLUMN IF EXISTS description;

-- 更新角色数据
UPDATE power_role SET chinese_name = '系统管理员', name = 'admin' WHERE id = 1;
UPDATE power_role SET chinese_name = '医生', name = 'doctor' WHERE id = 2;
UPDATE power_role SET chinese_name = '患者', name = 'patient' WHERE id = 3;

-- 添加放射科医生角色
INSERT INTO power_role (id, name, chinese_name, admin_count, sort, status, gmt_create, gmt_modified) VALUES
(4, 'radiologist', '放射科医生', 0, 4, 1, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET chinese_name = '放射科医生';

-- 2. 修复 power_account 表 - 确保有 login_time 和 status 列
-- (已在之前的SQL中添加)

-- 3. 修复 power_resource 表 - 添加 url 列
ALTER TABLE power_resource ADD COLUMN IF NOT EXISTS url varchar(32) NOT NULL DEFAULT '';

-- 4. 添加 radiologist1 账号
INSERT INTO power_account (id, name, password, status, gmt_create, gmt_modified) VALUES
(1008, 'radiologist1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET password = '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', status = 1;

-- 添加账号角色关联
INSERT INTO power_account_role_relation (account_id, role_id, gmt_create, gmt_modified) VALUES
(1008, 4, NOW(), NOW())
ON CONFLICT DO NOTHING;
