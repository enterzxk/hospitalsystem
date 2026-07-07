-- PostgreSQL script aligned with the medical imaging platform document.
-- Structured data: PostgreSQL. Queue/cache: Redis. Binary assets: MinIO/NAS via URI columns.

-- ============================================
-- 测试数据插入脚本（兼容旧表结构 hospital_clinic）
-- ============================================
-- ============================================
-- 1. 角色（已存在则忽略）
-- ============================================
INSERT INTO power_role (id, name, chinese_name, admin_count, sort, status, gmt_create, gmt_modified) VALUES
(1, 'admin', '管理员', 1, 1, 1, NOW(), NOW()),
(2, 'doctor', '医生', 0, 2, 1, NOW(), NOW()),
(3, 'radiologist', '放射科医生', 0, 3, 1, NOW(), NOW()),
(4, 'patient', '患者', 0, 4, 1, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 2. 账号（已存在则忽略）
-- ============================================
INSERT INTO power_account (id, name, password, status, login_time, gmt_create, gmt_modified) VALUES
(10000001, 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 1, NOW(), NOW(), NOW()),
(10000002, 'doctor1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 1, NOW(), NOW(), NOW()),
(10000004, 'patient1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi', 1, NOW(), NOW(), NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 3. 账号-角色关联（已存在则忽略）
-- ============================================
INSERT INTO power_account_role_relation (account_id, role_id, gmt_create, gmt_modified) VALUES
(10000001, 1, NOW(), NOW()),
(10000002, 2, NOW(), NOW()),
(10000010, 3, NOW(), NOW()),
(10000004, 4, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- ============================================
-- 4. 医院信息
-- ============================================
DELETE FROM hospital_info;
INSERT INTO hospital_info (id, name, phone, address, description, picture, gmt_create, gmt_modified) VALUES
(1000, '云岚宗医院', '0571-8808-6677', '云岚市青澜区云岚宗大道88号', '云岚宗医院是一所集医疗、教学、科研为一体的综合性医院', NULL, NOW(), NOW()),
(1001, '云岚宗医院分院', '0571-8808-6678', '云岚市青澜区云岚宗大道100号', '云岚宗医院分院', NULL, NOW(), NOW());

-- ============================================
-- 5. 科室
-- ============================================
DELETE FROM hospital_special;
INSERT INTO hospital_special (id, name, description, gmt_create, gmt_modified) VALUES
(10000, '内科学系', '内科疾病诊治', NOW(), NOW()),
(10001, '心内科', '心血管疾病诊治', NOW(), NOW()),
(10002, '消化内科', '消化系统疾病诊治', NOW(), NOW()),
(10003, '呼吸内科', '呼吸系统疾病诊治', NOW(), NOW()),
(10004, '神经内科', '神经系统疾病诊治', NOW(), NOW()),
(10005, '外科', '外科手术治疗', NOW(), NOW()),
(10006, '骨科', '骨科疾病诊治', NOW(), NOW()),
(10007, '妇产科', '妇产科疾病诊治', NOW(), NOW()),
(10008, '儿科', '儿童疾病诊治', NOW(), NOW()),
(10009, '眼科', '眼部疾病诊治', NOW(), NOW()),
(10010, '皮肤科', '皮肤疾病诊治', NOW(), NOW()),
(10011, '口腔科', '口腔疾病诊治', NOW(), NOW());

-- ============================================
-- 6. 门诊
-- ============================================
DELETE FROM hospital_outpatient;
INSERT INTO hospital_outpatient (id, name, special_id, gmt_create, gmt_modified) VALUES
(10000, '普通内科门诊', 10000, NOW(), NOW()),
(10001, '专家内科门诊', 10000, NOW(), NOW()),
(10002, '心内科门诊', 10001, NOW(), NOW()),
(10003, '消化内科门诊', 10002, NOW(), NOW()),
(10004, '呼吸内科门诊', 10003, NOW(), NOW()),
(10005, '神经内科门诊', 10004, NOW(), NOW()),
(10006, '普通外科门诊', 10005, NOW(), NOW()),
(10007, '骨科门诊', 10006, NOW(), NOW()),
(10008, '妇产科门诊', 10007, NOW(), NOW()),
(10009, '儿科门诊', 10008, NOW(), NOW()),
(10010, '眼科门诊', 10009, NOW(), NOW()),
(10011, '皮肤科门诊', 10010, NOW(), NOW()),
(10012, '口腔科门诊', 10011, NOW(), NOW());

-- ============================================
-- 7. 诊室（hospital_clinic 表）
-- ============================================
DELETE FROM hospital_clinic;
INSERT INTO hospital_clinic (id, outpatient_id, address, gmt_create, gmt_modified) VALUES
(10000, 10000, '1楼 101诊室', NOW(), NOW()),
(10001, 10000, '1楼 102诊室', NOW(), NOW()),
(10002, 10001, '2楼 201诊室', NOW(), NOW()),
(10003, 10002, '2楼 202诊室', NOW(), NOW()),
(10004, 10003, '3楼 301诊室', NOW(), NOW()),
(10005, 10004, '3楼 302诊室', NOW(), NOW()),
(10006, 10005, '3楼 303诊室', NOW(), NOW()),
(10007, 10006, '4楼 401诊室', NOW(), NOW()),
(10008, 10007, '4楼 402诊室', NOW(), NOW()),
(10009, 10008, '5楼 501诊室', NOW(), NOW()),
(10010, 10009, '5楼 502诊室', NOW(), NOW()),
(10011, 10010, '6楼 601诊室', NOW(), NOW()),
(10012, 10011, '6楼 602诊室', NOW(), NOW()),
(10013, 10012, '6楼 603诊室', NOW(), NOW());

-- ============================================
-- 8. 医生
-- ============================================
DELETE FROM hospital_doctor;
INSERT INTO hospital_doctor (id, name, gender, job_title, specialty, special_id, outpatient_id, gmt_create, gmt_modified) VALUES
(10001, '张伟', 1, '主任医师', '擅长心血管疾病诊治，从事内科临床工作20年', 10000, 10000, NOW(), NOW()),
(10002, '李芳', 2, '副主任医师', '擅长消化系统疾病诊治', 10002, 10003, NOW(), NOW()),
(10003, '王强', 1, '主治医师', '擅长呼吸系统疾病诊治', 10003, 10004, NOW(), NOW()),
(10004, '赵丽', 2, '主任医师', '擅长神经系统疾病诊治', 10004, 10005, NOW(), NOW()),
(10005, '刘明', 1, '副主任医师', '擅长外科手术治疗', 10005, 10006, NOW(), NOW()),
(10006, '陈静', 2, '主治医师', '擅长骨科疾病诊治', 10006, 10007, NOW(), NOW()),
(10007, '孙磊', 1, '主任医师', '擅长妇产科疾病诊治', 10007, 10008, NOW(), NOW());

-- ============================================
-- 9. 医院-门诊关联
-- ============================================
DELETE FROM hospital_outpatient_relation;
INSERT INTO hospital_outpatient_relation (hospital_id, outpatient_id, gmt_create, gmt_modified) VALUES
(1000, 10000, NOW(), NOW()),
(1000, 10001, NOW(), NOW()),
(1000, 10002, NOW(), NOW()),
(1000, 10003, NOW(), NOW()),
(1000, 10004, NOW(), NOW()),
(1000, 10005, NOW(), NOW()),
(1000, 10006, NOW(), NOW()),
(1000, 10007, NOW(), NOW()),
(1000, 10008, NOW(), NOW()),
(1000, 10009, NOW(), NOW()),
(1000, 10010, NOW(), NOW()),
(1000, 10011, NOW(), NOW()),
(1000, 10012, NOW(), NOW()),
(1001, 10000, NOW(), NOW()),
(1001, 10006, NOW(), NOW()),
(1001, 10007, NOW(), NOW());

-- ============================================
-- 10. 医院-科室关联
-- ============================================
DELETE FROM hospital_special_relation;
INSERT INTO hospital_special_relation (hospital_id, special_id, gmt_create, gmt_modified) VALUES
(1000, 10000, NOW(), NOW()),
(1000, 10001, NOW(), NOW()),
(1000, 10002, NOW(), NOW()),
(1000, 10003, NOW(), NOW()),
(1000, 10004, NOW(), NOW()),
(1000, 10005, NOW(), NOW()),
(1000, 10006, NOW(), NOW()),
(1000, 10007, NOW(), NOW()),
(1000, 10008, NOW(), NOW()),
(1000, 10009, NOW(), NOW()),
(1000, 10010, NOW(), NOW()),
(1000, 10011, NOW(), NOW()),
(1001, 10000, NOW(), NOW()),
(1001, 10005, NOW(), NOW()),
(1001, 10006, NOW(), NOW());

-- ============================================
-- 11. 出诊排班
-- ============================================
DELETE FROM visit_plan;
INSERT INTO visit_plan (id, hospital_id, special_id, outpatient_id, clinic_id, doctor_id, time, day, gmt_create, gmt_modified) VALUES
(10000, 1000, 10000, 10000, 10000, 10001, 1, CURRENT_DATE, NOW(), NOW()),
(10001, 1000, 10000, 10000, 10001, 10001, 2, CURRENT_DATE, NOW(), NOW()),
(10002, 1000, 10002, 10003, 10004, 10002, 1, CURRENT_DATE, NOW(), NOW()),
(10003, 1000, 10003, 10004, 10005, 10003, 2, CURRENT_DATE, NOW(), NOW()),
(10004, 1000, 10005, 10006, 10007, 10005, 1, CURRENT_DATE, NOW(), NOW());

-- ============================================
-- 12. 显式 ID 后同步序列，避免新增数据主键冲突
-- ============================================
SELECT setval(pg_get_serial_sequence('power_role', 'id'), COALESCE((SELECT MAX(id) FROM power_role), 1), true);
SELECT setval(pg_get_serial_sequence('power_account', 'id'), COALESCE((SELECT MAX(id) FROM power_account), 1), true);
SELECT setval(pg_get_serial_sequence('hospital_info', 'id'), COALESCE((SELECT MAX(id) FROM hospital_info), 1), true);
SELECT setval(pg_get_serial_sequence('hospital_special', 'id'), COALESCE((SELECT MAX(id) FROM hospital_special), 1), true);
SELECT setval(pg_get_serial_sequence('hospital_outpatient', 'id'), COALESCE((SELECT MAX(id) FROM hospital_outpatient), 1), true);
SELECT setval(pg_get_serial_sequence('hospital_clinic', 'id'), COALESCE((SELECT MAX(id) FROM hospital_clinic), 1), true);
SELECT setval(pg_get_serial_sequence('hospital_doctor', 'id'), COALESCE((SELECT MAX(id) FROM hospital_doctor), 1), true);
SELECT setval(pg_get_serial_sequence('visit_plan', 'id'), COALESCE((SELECT MAX(id) FROM visit_plan), 1), true);
