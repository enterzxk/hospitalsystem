-- PostgreSQL script aligned with the medical imaging platform document.
-- Structured data: PostgreSQL. Queue/cache: Redis. Binary assets: MinIO/NAS via URI columns.

-- =====================================================
-- 使用正确的 hospital.sql 重建数据库
-- =====================================================

-- 先删除数据库（如果存在）
DROP DATABASE IF EXISTS hospital;

-- 重新创建数据库
CREATE DATABASE hospital DEFAULT  ;

-- 使用数据库
USE hospital;

-- 禁用外键检查
-- =====================================================
-- 以下内容来自 hospital.sql（与代码匹配的正确版本）
-- =====================================================

-- ----------------------------
-- 菜单表
-- ----------------------------
DROP TABLE IF EXISTS power_menu CASCADE;
CREATE TABLE power_menu
(
    id          bigserial NOT NULL,
    parent_id   bigint                                                   NULL DEFAULT 0,
    create_time timestamp                                                  NULL DEFAULT NULL,
    title       varchar(32)   NOT NULL,
    level       integer                                                      NOT NULL DEFAULT 0,
    sort        integer                                                      NOT NULL DEFAULT 0,
    name        varchar(32)   NOT NULL,
    icon        varchar(255)   NULL DEFAULT NULL,
    hidden      integer                                                      NOT NULL DEFAULT 1,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 资源表
-- ----------------------------
DROP TABLE IF EXISTS power_resource CASCADE;
CREATE TABLE power_resource
(
    id           bigserial NOT NULL,
    category_id  bigint                                                   NOT NULL,
    name         varchar(32)   NOT NULL,
    url          varchar(32)   NOT NULL,
    description  varchar(64)   NOT NULL,
    gmt_create   timestamp                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT power_resource_url_uindex UNIQUE (url),
    CONSTRAINT power_resource_name_uindex UNIQUE (name)
);

-- ----------------------------
-- 资源分类表
-- ----------------------------
DROP TABLE IF EXISTS power_resource_category CASCADE;
CREATE TABLE power_resource_category
(
    id           bigserial NOT NULL,
    name         varchar(32)   NOT NULL,
    sort         integer                                                      NOT NULL DEFAULT 1,
    gmt_create   timestamp                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT power_resource_category_name_uindex UNIQUE (name)
);

-- ----------------------------
-- 角色表
-- ----------------------------
DROP TABLE IF EXISTS power_role CASCADE;
CREATE TABLE power_role
(
    id           bigserial NOT NULL,
    name         varchar(32)   NOT NULL,
    chinese_name varchar(32)   NOT NULL,
    admin_count  integer                                                      NOT NULL DEFAULT 0,
    sort         integer                                                      NOT NULL DEFAULT 0,
    status       integer                                                      NOT NULL DEFAULT 1,
    gmt_create   timestamp                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT power_role_name_uindex UNIQUE (name)
);

-- ----------------------------
-- 账号信息表
-- ----------------------------
DROP TABLE IF EXISTS power_account CASCADE;
CREATE TABLE power_account
(
    id           bigserial NOT NULL,
    name         varchar(32)    NOT NULL,
    password     varchar(512)   NOT NULL,
    status       integer                                                       NOT NULL DEFAULT 1,
    login_time   timestamp                                                   NULL     DEFAULT NULL,
    gmt_create   timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT power_account_name_uindex UNIQUE (name)
);

-- ----------------------------
-- 账号角色关系表
-- ----------------------------
DROP TABLE IF EXISTS power_account_role_relation CASCADE;
CREATE TABLE power_account_role_relation
(
    id           bigserial NOT NULL,
    account_id   bigint  NOT NULL,
    role_id      bigint  NOT NULL,
    gmt_create   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 角色菜单关系表
-- ----------------------------
DROP TABLE IF EXISTS power_role_menu_relation CASCADE;
CREATE TABLE power_role_menu_relation
(
    id          bigserial NOT NULL,
    role_id     bigint NOT NULL,
    menu_id     bigint NOT NULL,
    gmt_create  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 角色资源关系表
-- ----------------------------
DROP TABLE IF EXISTS power_role_resource_relation CASCADE;
CREATE TABLE power_role_resource_relation
(
    id          bigserial NOT NULL,
    role_id     bigint NOT NULL,
    resource_id bigint NOT NULL,
    gmt_create  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 医院信息表
-- ----------------------------
DROP TABLE IF EXISTS hospital_info CASCADE;
CREATE TABLE hospital_info
(
    id           bigserial NOT NULL,
    name         varchar(64)    NOT NULL,
    phone        varchar(64)    NULL     DEFAULT NULL,
    address      varchar(128)   NULL     DEFAULT NULL,
    description  varchar(512)   NULL     DEFAULT NULL,
    picture      varchar(255)   NULL     DEFAULT NULL,
    gmt_create   timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 医院科室表
-- ----------------------------
DROP TABLE IF EXISTS hospital_special CASCADE;
CREATE TABLE hospital_special
(
    id           bigserial NOT NULL,
    hospital_id  bigint                                                    NOT NULL,
    name         varchar(64)    NOT NULL,
    icon         varchar(255)   NULL     DEFAULT NULL,
    description  varchar(128)   NULL     DEFAULT NULL,
    sort         integer                                                       NOT NULL DEFAULT 0,
    status       integer                                                       NOT NULL DEFAULT 1,
    gmt_create   timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 医生信息表
-- ----------------------------
DROP TABLE IF EXISTS hospital_doctor CASCADE;
CREATE TABLE hospital_doctor
(
    id              bigserial NOT NULL,
    account_id      bigint                                                    NULL     DEFAULT NULL,
    hospital_id     bigint                                                    NOT NULL,
    special_id      bigint                                                    NULL     DEFAULT NULL,
    name            varchar(32)    NOT NULL,
    professional    varchar(32)    NULL     DEFAULT NULL,
    hospital_name   varchar(64)    NOT NULL,
    special_name    varchar(64)    NULL     DEFAULT NULL,
    expertise       varchar(128)   NULL     DEFAULT NULL,
    picture         varchar(255)   NULL     DEFAULT NULL,
    pinyin          varchar(32)    NULL     DEFAULT NULL,
    good_rate       integer                                                       NULL     DEFAULT 100,
    service_count   integer                                                       NULL     DEFAULT 0,
    sort            integer                                                       NOT NULL DEFAULT 0,
    status          integer                                                       NOT NULL DEFAULT 1,
    gmt_create      timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified    timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 门诊信息表
-- ----------------------------
DROP TABLE IF EXISTS hospital_outpatient CASCADE;
CREATE TABLE hospital_outpatient
(
    id           bigserial NOT NULL,
    hospital_id  bigint                                                    NOT NULL,
    name         varchar(64)    NOT NULL,
    phone        varchar(64)    NULL     DEFAULT NULL,
    address      varchar(128)   NULL     DEFAULT NULL,
    description  varchar(128)   NULL     DEFAULT NULL,
    picture      varchar(255)   NULL     DEFAULT NULL,
    status       integer                                                       NOT NULL DEFAULT 1,
    gmt_create   timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 诊室信息表
-- ----------------------------
DROP TABLE IF EXISTS hospital_clinic CASCADE;
CREATE TABLE hospital_clinic
(
    id             bigserial NOT NULL,
    outpatient_id  bigint                                                    NOT NULL,
    name           varchar(64)    NOT NULL,
    address        varchar(128)   NULL     DEFAULT NULL,
    status         integer                                                       NOT NULL DEFAULT 1,
    gmt_create     timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified   timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 出诊信息表
-- ----------------------------
DROP TABLE IF EXISTS visit_plan CASCADE;
CREATE TABLE visit_plan
(
    id            bigserial NOT NULL,
    hospital_id   bigint  NOT NULL,
    special_id    bigint  NOT NULL,
    outpatient_id bigint  NOT NULL,
    clinic_id     bigint  NOT NULL,
    doctor_id     bigint  NOT NULL,
    time          integer     NOT NULL DEFAULT 1,
    day           timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_create    timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 患者就诊卡表
-- ----------------------------
DROP TABLE IF EXISTS user_medical_card CASCADE;
CREATE TABLE user_medical_card
(
    id           bigserial NOT NULL,
    account_id   bigint                                                    NOT NULL,
    real_name    varchar(32)    NOT NULL,
    id_card      varchar(32)    NULL     DEFAULT NULL,
    phone        varchar(32)    NULL     DEFAULT NULL,
    gender       integer                                                       NOT NULL DEFAULT 1,
    birthday     timestamp                                                   NULL     DEFAULT NULL,
    gmt_create   timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 用户基本信息表
-- ----------------------------
DROP TABLE IF EXISTS user_basic_info CASCADE;
CREATE TABLE user_basic_info
(
    id           bigserial NOT NULL,
    account_id   bigint                                                    NOT NULL,
    name         varchar(32)    NOT NULL,
    icon         varchar(255)   NULL     DEFAULT NULL,
    gender       integer                                                       NOT NULL DEFAULT 1,
    age          integer                                                       NULL     DEFAULT NULL,
    phone        varchar(32)    NOT NULL,
    gmt_create   timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 用户病案表
-- ----------------------------
DROP TABLE IF EXISTS user_case CASCADE;
CREATE TABLE user_case
(
    id             bigserial NOT NULL,
    account_id     bigint                                                    NOT NULL,
    medical_id     bigint                                                    NOT NULL,
    real_name      varchar(32)    NOT NULL,
    id_card        varchar(32)    NULL     DEFAULT NULL,
    phone          varchar(32)    NULL     DEFAULT NULL,
    gender         integer                                                       NOT NULL DEFAULT 1,
    birthday       timestamp                                                   NULL     DEFAULT NULL,
    blood_type     varchar(16)    NULL     DEFAULT NULL,
    allergy_history varchar(128)   NULL     DEFAULT NULL,
    gmt_create     timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified   timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 就诊卡关系表
-- ----------------------------
DROP TABLE IF EXISTS user_medical_card_relation CASCADE;
CREATE TABLE user_medical_card_relation
(
    id             bigserial NOT NULL,
    account_id     bigint NOT NULL,
    medical_id     bigint NOT NULL,
    is_default     integer    NOT NULL DEFAULT 0,
    gmt_create     timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 预约挂号表
-- ----------------------------
DROP TABLE IF EXISTS visit_appointment CASCADE;
CREATE TABLE visit_appointment
(
    id              bigserial NOT NULL,
    account_id      bigint  NOT NULL,
    medical_id      bigint  NULL     DEFAULT NULL,
    plan_id         bigint  NOT NULL,
    real_name       varchar(32)    NOT NULL,
    id_card         varchar(32)    NULL     DEFAULT NULL,
    phone           varchar(32)    NOT NULL,
    appointment_status integer NOT NULL DEFAULT 1,
    is_system       integer     NOT NULL DEFAULT 0,
    gmt_create      timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified    timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 黑名单表
-- ----------------------------
DROP TABLE IF EXISTS visit_blacklist CASCADE;
CREATE TABLE visit_blacklist
(
    id             bigserial NOT NULL,
    account_id     bigint  NOT NULL,
    medical_id     bigint  NOT NULL,
    real_name      varchar(32)    NOT NULL,
    id_card        varchar(32)    NULL     DEFAULT NULL,
    phone          varchar(32)    NOT NULL,
    appointment_count integer  NOT NULL DEFAULT 0,
    reason         varchar(64)    NULL     DEFAULT NULL,
    gmt_create     timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 操作日志表
-- ----------------------------
DROP TABLE IF EXISTS log_operation CASCADE;
CREATE TABLE log_operation
(
    id          bigserial NOT NULL,
    name        varchar(64)    NOT NULL,
    description varchar(255)   NULL     DEFAULT NULL,
    ip          varchar(64)    NULL     DEFAULT NULL,
    account     varchar(64)    NULL     DEFAULT NULL,
    gmt_create  timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 登录日志表
-- ----------------------------
DROP TABLE IF EXISTS log_account_login CASCADE;
CREATE TABLE log_account_login
(
    id          bigserial NOT NULL,
    ip          varchar(64)    NULL     DEFAULT NULL,
    account     varchar(64)    NOT NULL,
    gmt_create  timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 门诊关系表
-- ----------------------------
DROP TABLE IF EXISTS hospital_outpatient_relation CASCADE;
CREATE TABLE hospital_outpatient_relation
(
    id            bigserial NOT NULL,
    outpatient_id bigint NOT NULL,
    special_id    bigint NOT NULL,
    gmt_create    timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 医生关系表
-- ----------------------------
DROP TABLE IF EXISTS hospital_special_relation CASCADE;
CREATE TABLE hospital_special_relation
(
    id           bigserial NOT NULL,
    doctor_id    bigint NOT NULL,
    special_id   bigint NOT NULL,
    gmt_create   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- =====================================================
-- 新增表：患者信息、影像、诊断报告等
-- =====================================================

-- 患者信息表
DROP TABLE IF EXISTS patient_info CASCADE;
CREATE TABLE patient_info (
    id bigserial NOT NULL,
    account_id bigint NULL DEFAULT NULL,
    name varchar(32) NOT NULL,
    gender integer NOT NULL DEFAULT 1,
    phone varchar(16) NULL DEFAULT NULL,
    id_card varchar(18) NULL DEFAULT NULL,
    birth_date date NULL DEFAULT NULL,
    address varchar(128) NULL DEFAULT NULL,
    blood_type varchar(4) NULL DEFAULT NULL,
    allergy_history varchar(512) NULL DEFAULT NULL,
    medical_history varchar(512) NULL DEFAULT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- 影像资料表
DROP TABLE IF EXISTS medical_imaging CASCADE;
CREATE TABLE medical_imaging (
    id bigserial NOT NULL,
    patient_id bigint NOT NULL,
    doctor_id bigint NOT NULL,
    hospital_id bigint NOT NULL,
    imaging_type varchar(32) NOT NULL,
    body_part varchar(64) NOT NULL,
    file_path varchar(512) NOT NULL,
    file_name varchar(128) NOT NULL,
    file_size bigint NULL DEFAULT NULL,
    description varchar(512) NULL DEFAULT NULL,
    diagnosis_status integer NOT NULL DEFAULT 0,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- 诊断报告表
DROP TABLE IF EXISTS diagnosis_report CASCADE;
CREATE TABLE diagnosis_report (
    id bigserial NOT NULL,
    patient_id bigint NOT NULL,
    doctor_id bigint NOT NULL,
    hospital_id bigint NOT NULL,
    special_id bigint NULL DEFAULT NULL,
    report_no varchar(32) NOT NULL,
    patient_name varchar(32) NOT NULL,
    gender integer NULL DEFAULT 1,
    age integer NULL DEFAULT NULL,
    id_card varchar(18) NULL DEFAULT NULL,
    phone varchar(16) NULL DEFAULT NULL,
    examination_type varchar(32) NOT NULL,
    body_part varchar(64) NOT NULL,
    clinical_diagnosis varchar(512) NULL DEFAULT NULL,
    examination_findings text NOT NULL,
    diagnostic_opinion text NOT NULL,
    report_status integer NOT NULL DEFAULT 0,
    report_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewer_id bigint NULL DEFAULT NULL,
    review_time timestamp NULL DEFAULT NULL,
    review_opinion varchar(512) NULL DEFAULT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT report_no UNIQUE (report_no)
);

-- 报告影像关联表
DROP TABLE IF EXISTS report_imaging_relation CASCADE;
CREATE TABLE report_imaging_relation (
    id bigserial NOT NULL,
    report_id bigint NOT NULL,
    imaging_id bigint NOT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uk_report_imaging UNIQUE (report_id, imaging_id)
);

-- 就诊记录表
DROP TABLE IF EXISTS visit_record CASCADE;
CREATE TABLE visit_record (
    id bigserial NOT NULL,
    patient_id bigint NOT NULL,
    doctor_id bigint NOT NULL,
    hospital_id bigint NOT NULL,
    special_id bigint NULL DEFAULT NULL,
    outpatient_id bigint NULL DEFAULT NULL,
    visit_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    symptoms varchar(512) NULL DEFAULT NULL,
    diagnosis varchar(512) NULL DEFAULT NULL,
    treatment_plan varchar(512) NULL DEFAULT NULL,
    prescription text NULL,
    visit_status integer NOT NULL DEFAULT 0,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- 影像标注表
DROP TABLE IF EXISTS imaging_annotation CASCADE;
CREATE TABLE imaging_annotation (
    id bigserial NOT NULL,
    imaging_id bigint NOT NULL,
    doctor_id bigint NOT NULL,
    annotation_type varchar(32) NOT NULL,
    annotation_data text NOT NULL,
    label varchar(64) NULL DEFAULT NULL,
    color varchar(16) NULL DEFAULT '#FF0000',
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
-- =====================================================
-- 初始化数据
-- =====================================================

-- 初始化角色
INSERT INTO power_role (id, name, chinese_name, admin_count, sort, status, gmt_create, gmt_modified) VALUES
(1, 'admin', '系统管理员', 0, 1, 1, NOW(), NOW()),
(2, 'doctor', '医生', 0, 2, 1, NOW(), NOW()),
(3, 'patient', '患者', 0, 3, 1, NOW(), NOW()),
(4, 'radiologist', '放射科医生', 0, 4, 1, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- 初始化测试账号
INSERT INTO power_account (id, name, password, status, login_time, gmt_create, gmt_modified) VALUES
(1000, 'admin', '$2a$10$PmoMm5QCsVEddE3yw1F/aez3a/0slKfgA8i/ydTsgHeuI6t9v93gW', 1, NULL, NOW(), NOW()),
(1001, 'doctor1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1002, 'doctor2', '$2a$10$e5kPah/Adaf59rhYv8UUpuydluURQ2jlV3WxDEDs2bsMgzJpxmt1u', 1, NULL, NOW(), NOW()),
(1003, 'patient1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1004, 'patient2', '$2a$10$Ah0XaOc/uEDQjvWzySygieTRfHuzHcv1NCTebrtNfu.uS4b/Av6SS', 1, NULL, NOW(), NOW()),
(1005, 'doctor3', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1006, 'patient3', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1007, 'patient4', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1008, 'radiologist1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- 初始化账号角色关联
INSERT INTO power_account_role_relation (account_id, role_id, gmt_create, gmt_modified) VALUES
(1000, 1, NOW(), NOW()),
(1001, 2, NOW(), NOW()),
(1002, 2, NOW(), NOW()),
(1005, 2, NOW(), NOW()),
(1003, 3, NOW(), NOW()),
(1004, 3, NOW(), NOW()),
(1006, 3, NOW(), NOW()),
(1007, 3, NOW(), NOW()),
(1008, 4, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- 初始化医院信息
INSERT INTO hospital_info (id, name, phone, address, description, picture, gmt_create, gmt_modified) VALUES
(1000, '云岚宗医院', '0571-8808-6677', '云岚市青澜区云岚宗大道88号', '云岚宗医院是一所虚构的现代化综合医疗中心，提供门诊、住院、影像诊断、报告查询和慢病随访服务。', NULL, NOW(), NOW()),
(1001, '云岚宗医院城北院区', '0571-8808-6688', '云岚市北杉区清溪路66号', '云岚宗医院城北院区聚焦康复医学、慢病管理和社区连续照护。', NULL, NOW(), NOW()),
(1002, '云岚宗医院临研中心', '0571-8808-6699', '云岚市青澜区知行路18号', '云岚宗医院临研中心负责临床研究、医学教学和多学科协作诊疗。', NULL, NOW(), NOW());

-- 初始化科室
INSERT INTO hospital_special (id, hospital_id, name, icon, description, sort, status, gmt_create, gmt_modified) VALUES
(1000, 1000, '内科', NULL, '内科', 1, 1, NOW(), NOW()),
(1001, 1000, '外科', NULL, '外科', 2, 1, NOW(), NOW()),
(1002, 1000, '妇产科', NULL, '妇产科', 3, 1, NOW(), NOW()),
(1003, 1000, '儿科', NULL, '儿科', 4, 1, NOW(), NOW()),
(1004, 1000, '放射科', NULL, '放射科', 5, 1, NOW(), NOW()),
(1005, 1000, '检验科', NULL, '检验科', 6, 1, NOW(), NOW()),
(1006, 1000, '药剂科', NULL, '药剂科', 7, 1, NOW(), NOW()),
(1007, 1000, '急诊科', NULL, '急诊科', 8, 1, NOW(), NOW()),
(1008, 1000, '骨科', NULL, '骨科', 9, 1, NOW(), NOW()),
(1009, 1000, '神经内科', NULL, '神经内科', 10, 1, NOW(), NOW());

-- 初始化医生
INSERT INTO hospital_doctor (id, account_id, hospital_id, special_id, name, professional, hospital_name, special_name, expertise, picture, pinyin, good_rate, service_count, sort, status, gmt_create, gmt_modified) VALUES
(1000, 1001, 1000, 1000, '张医生', '主任医师', '云岚宗医院', '内科', '擅长内科常见病、多发病的诊治', NULL, 'zhangyisheng', 98, 1000, 1, 1, NOW(), NOW()),
(1001, 1002, 1000, 1001, '李医生', '副主任医师', '云岚宗医院', '外科', '擅长外科手术', NULL, 'liyisheng', 95, 800, 2, 1, NOW(), NOW()),
(1002, 1005, 1000, 1004, '王放射', '主治医师', '云岚宗医院', '放射科', '擅长CT、MRI影像诊断', NULL, 'wangfangshe', 97, 500, 3, 1, NOW(), NOW());

-- 初始化门诊
INSERT INTO hospital_outpatient (id, hospital_id, name, phone, address, description, picture, status, gmt_create, gmt_modified) VALUES
(1000, 1000, '门诊一部', '0571-8808-6677', '云岚宗医院主楼1楼', '综合门诊', NULL, 1, NOW(), NOW()),
(1001, 1000, '门诊二部', '0571-8808-6678', '云岚宗医院主楼2楼', '专科门诊', NULL, 1, NOW(), NOW()),
(1002, 1000, '急诊部', '0571-8808-6699', '云岚宗医院急诊楼', '急诊服务', NULL, 1, NOW(), NOW()),
(1003, 1000, '体检中心', '0571-8808-6680', '云岚宗医院体检楼', '健康体检', NULL, 1, NOW(), NOW());

-- 初始化诊室
INSERT INTO hospital_clinic (id, outpatient_id, name, address, status, gmt_create, gmt_modified) VALUES
(1000, 1000, '101诊室', '门诊一部101', 1, NOW(), NOW()),
(1001, 1000, '102诊室', '门诊一部102', 1, NOW(), NOW()),
(1002, 1001, '201诊室', '门诊二部201', 1, NOW(), NOW()),
(1003, 1002, '急诊1诊室', '急诊部1', 1, NOW(), NOW());

-- 初始化出诊计划
INSERT INTO visit_plan (id, hospital_id, special_id, outpatient_id, clinic_id, doctor_id, time, day, gmt_create, gmt_modified) VALUES
(1000, 1000, 1000, 1000, 1000, 1000, 1, DATE_ADD(NOW(), INTERVAL 1 DAY), NOW(), NOW()),
(1001, 1000, 1001, 1001, 1002, 1001, 1, DATE_ADD(NOW(), INTERVAL 1 DAY), NOW(), NOW()),
(1002, 1000, 1004, 1000, 1001, 1002, 2, DATE_ADD(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
(1003, 1000, 1000, 1000, 1000, 1000, 2, DATE_ADD(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
(1004, 1000, 1001, 1001, 1002, 1001, 1, DATE_ADD(NOW(), INTERVAL 3 DAY), NOW(), NOW());

-- PostgreSQL sequence synchronization
SELECT setval(pg_get_serial_sequence('power_menu', 'id'), COALESCE((SELECT MAX(id) FROM power_menu), 1));
SELECT setval(pg_get_serial_sequence('power_resource', 'id'), COALESCE((SELECT MAX(id) FROM power_resource), 1));
SELECT setval(pg_get_serial_sequence('power_resource_category', 'id'), COALESCE((SELECT MAX(id) FROM power_resource_category), 1));
SELECT setval(pg_get_serial_sequence('power_role', 'id'), COALESCE((SELECT MAX(id) FROM power_role), 1));
SELECT setval(pg_get_serial_sequence('power_account', 'id'), COALESCE((SELECT MAX(id) FROM power_account), 1));
SELECT setval(pg_get_serial_sequence('power_account_role_relation', 'id'), COALESCE((SELECT MAX(id) FROM power_account_role_relation), 1));
SELECT setval(pg_get_serial_sequence('power_role_menu_relation', 'id'), COALESCE((SELECT MAX(id) FROM power_role_menu_relation), 1));
SELECT setval(pg_get_serial_sequence('power_role_resource_relation', 'id'), COALESCE((SELECT MAX(id) FROM power_role_resource_relation), 1));
SELECT setval(pg_get_serial_sequence('hospital_info', 'id'), COALESCE((SELECT MAX(id) FROM hospital_info), 1));
SELECT setval(pg_get_serial_sequence('hospital_special', 'id'), COALESCE((SELECT MAX(id) FROM hospital_special), 1));
SELECT setval(pg_get_serial_sequence('hospital_doctor', 'id'), COALESCE((SELECT MAX(id) FROM hospital_doctor), 1));
SELECT setval(pg_get_serial_sequence('hospital_outpatient', 'id'), COALESCE((SELECT MAX(id) FROM hospital_outpatient), 1));
SELECT setval(pg_get_serial_sequence('hospital_clinic', 'id'), COALESCE((SELECT MAX(id) FROM hospital_clinic), 1));
SELECT setval(pg_get_serial_sequence('visit_plan', 'id'), COALESCE((SELECT MAX(id) FROM visit_plan), 1));
SELECT setval(pg_get_serial_sequence('user_medical_card', 'id'), COALESCE((SELECT MAX(id) FROM user_medical_card), 1));
SELECT setval(pg_get_serial_sequence('user_basic_info', 'id'), COALESCE((SELECT MAX(id) FROM user_basic_info), 1));
SELECT setval(pg_get_serial_sequence('user_case', 'id'), COALESCE((SELECT MAX(id) FROM user_case), 1));
SELECT setval(pg_get_serial_sequence('user_medical_card_relation', 'id'), COALESCE((SELECT MAX(id) FROM user_medical_card_relation), 1));
SELECT setval(pg_get_serial_sequence('visit_appointment', 'id'), COALESCE((SELECT MAX(id) FROM visit_appointment), 1));
SELECT setval(pg_get_serial_sequence('visit_blacklist', 'id'), COALESCE((SELECT MAX(id) FROM visit_blacklist), 1));
SELECT setval(pg_get_serial_sequence('log_operation', 'id'), COALESCE((SELECT MAX(id) FROM log_operation), 1));
SELECT setval(pg_get_serial_sequence('log_account_login', 'id'), COALESCE((SELECT MAX(id) FROM log_account_login), 1));
SELECT setval(pg_get_serial_sequence('hospital_outpatient_relation', 'id'), COALESCE((SELECT MAX(id) FROM hospital_outpatient_relation), 1));
SELECT setval(pg_get_serial_sequence('hospital_special_relation', 'id'), COALESCE((SELECT MAX(id) FROM hospital_special_relation), 1));
SELECT setval(pg_get_serial_sequence('patient_info', 'id'), COALESCE((SELECT MAX(id) FROM patient_info), 1));
SELECT setval(pg_get_serial_sequence('medical_imaging', 'id'), COALESCE((SELECT MAX(id) FROM medical_imaging), 1));
SELECT setval(pg_get_serial_sequence('diagnosis_report', 'id'), COALESCE((SELECT MAX(id) FROM diagnosis_report), 1));
SELECT setval(pg_get_serial_sequence('report_imaging_relation', 'id'), COALESCE((SELECT MAX(id) FROM report_imaging_relation), 1));
SELECT setval(pg_get_serial_sequence('visit_record', 'id'), COALESCE((SELECT MAX(id) FROM visit_record), 1));
SELECT setval(pg_get_serial_sequence('imaging_annotation', 'id'), COALESCE((SELECT MAX(id) FROM imaging_annotation), 1));
