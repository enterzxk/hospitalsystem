-- PostgreSQL script aligned with the medical imaging platform document.
-- Structured data: PostgreSQL. Queue/cache: Redis. Binary assets: MinIO/NAS via URI columns.

-- 医院管理系统数据库（重构版）
-- 包含：患者、医生、管理员角色，影像上传，诊断报告功能
-- ----------------------------
-- 用户基础信息表
-- ----------------------------
DROP TABLE IF EXISTS user_basic_info CASCADE;
CREATE TABLE user_basic_info (
    id bigserial NOT NULL,
    name varchar(32)   NOT NULL,
    phone varchar(16)   NULL DEFAULT NULL,
    id_card varchar(18)   NULL DEFAULT NULL,
    gender integer NULL DEFAULT 1,
    birth_date date NULL DEFAULT NULL,
    address varchar(128)   NULL DEFAULT NULL,
    blood_type varchar(4)   NULL DEFAULT NULL,
    allergy_history varchar(512)   NULL DEFAULT NULL,
    medical_history varchar(512)   NULL DEFAULT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 账号表
-- ----------------------------
DROP TABLE IF EXISTS power_account CASCADE;
CREATE TABLE power_account (
    id bigserial NOT NULL,
    name varchar(32)   NOT NULL,
    password varchar(512)   NOT NULL,
    status integer NOT NULL DEFAULT 1,
    login_time timestamp NULL DEFAULT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT power_account_name_uindex UNIQUE (name)
);

-- ----------------------------
-- 角色表
-- ----------------------------
DROP TABLE IF EXISTS power_role CASCADE;
CREATE TABLE power_role (
    id bigserial NOT NULL,
    name varchar(32)   NOT NULL,
    chinese_name varchar(32)   NOT NULL,
    admin_count integer NOT NULL DEFAULT 0,
    sort integer NOT NULL DEFAULT 0,
    status integer NOT NULL DEFAULT 1,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT power_role_name_uindex UNIQUE (name)
);

-- ----------------------------
-- 医院信息表
-- ----------------------------
DROP TABLE IF EXISTS hospital_info CASCADE;
CREATE TABLE hospital_info (
    id bigserial NOT NULL,
    name varchar(64)   NOT NULL,
    phone varchar(16)   NOT NULL,
    address varchar(128)   NOT NULL,
    description varchar(512)   NOT NULL,
    picture varchar(512)   NULL DEFAULT NULL,
    gmt_create timestamp NOT NULL,
    gmt_modified timestamp NOT NULL,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 医院专科表
-- ----------------------------
DROP TABLE IF EXISTS hospital_special CASCADE;
CREATE TABLE hospital_special (
    id bigserial NOT NULL,
    name varchar(32)   NOT NULL,
    description varchar(512)   NOT NULL,
    gmt_create timestamp NOT NULL,
    gmt_modified timestamp NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT hospital_special_name_uindex UNIQUE (name)
);

-- ----------------------------
-- 医院门诊表
-- ----------------------------
DROP TABLE IF EXISTS hospital_outpatient CASCADE;
CREATE TABLE hospital_outpatient (
    id bigserial NOT NULL,
    name varchar(32)   NOT NULL,
    special_id bigint NOT NULL,
    gmt_create timestamp NOT NULL,
    gmt_modified timestamp NOT NULL,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 医院门诊关系表
-- ----------------------------
DROP TABLE IF EXISTS hospital_outpatient_relation CASCADE;
CREATE TABLE hospital_outpatient_relation (
    id bigserial NOT NULL,
    hospital_id bigint NOT NULL,
    outpatient_id bigint NOT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 医院专科关系表
-- ----------------------------
DROP TABLE IF EXISTS hospital_special_relation CASCADE;
CREATE TABLE hospital_special_relation (
    id bigserial NOT NULL,
    hospital_id bigint NOT NULL,
    special_id bigint NOT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 诊室信息表
-- ----------------------------
DROP TABLE IF EXISTS hospital_clinic CASCADE;
CREATE TABLE hospital_clinic (
    id bigserial NOT NULL,
    outpatient_id bigint NOT NULL,
    address varchar(128)   NOT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 医生信息表
-- ----------------------------
DROP TABLE IF EXISTS hospital_doctor CASCADE;
CREATE TABLE hospital_doctor (
    id bigserial NOT NULL,
    account_id bigint NULL DEFAULT NULL,
    name varchar(32)   NOT NULL,
    gender integer NOT NULL DEFAULT 1,
    job_title varchar(32)   NOT NULL,
    specialty varchar(512)   NOT NULL,
    special_id bigint NOT NULL,
    outpatient_id bigint NOT NULL,
    hospital_id bigint NOT NULL,
    gmt_create timestamp NOT NULL,
    gmt_modified timestamp NOT NULL,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 患者信息表
-- ----------------------------
DROP TABLE IF EXISTS patient_info CASCADE;
CREATE TABLE patient_info (
    id bigserial NOT NULL,
    account_id bigint NULL DEFAULT NULL,
    name varchar(32)   NOT NULL,
    gender integer NOT NULL DEFAULT 1,
    phone varchar(16)   NULL DEFAULT NULL,
    id_card varchar(18)   NULL DEFAULT NULL,
    birth_date date NULL DEFAULT NULL,
    address varchar(128)   NULL DEFAULT NULL,
    blood_type varchar(4)   NULL DEFAULT NULL,
    allergy_history varchar(512)   NULL DEFAULT NULL,
    medical_history varchar(512)   NULL DEFAULT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 影像资料表
-- ----------------------------
DROP TABLE IF EXISTS medical_imaging CASCADE;
CREATE TABLE medical_imaging (
    id bigserial NOT NULL,
    patient_id bigint NOT NULL,
    doctor_id bigint NOT NULL,
    hospital_id bigint NOT NULL,
    imaging_type varchar(32)   NOT NULL,
    body_part varchar(64)   NOT NULL,
    file_path varchar(512)   NOT NULL,
    file_name varchar(128)   NOT NULL,
    file_size bigint NULL DEFAULT NULL,
    description varchar(512)   NULL DEFAULT NULL,
    diagnosis_status integer NOT NULL DEFAULT 0,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 诊断报告表
-- ----------------------------
DROP TABLE IF EXISTS diagnosis_report CASCADE;
CREATE TABLE diagnosis_report (
    id bigserial NOT NULL,
    patient_id bigint NOT NULL,
    doctor_id bigint NOT NULL,
    hospital_id bigint NOT NULL,
    special_id bigint NULL DEFAULT NULL,
    report_no varchar(32)   NOT NULL,
    patient_name varchar(32)   NOT NULL,
    gender integer NULL DEFAULT 1,
    age integer NULL DEFAULT NULL,
    id_card varchar(18)   NULL DEFAULT NULL,
    phone varchar(16)   NULL DEFAULT NULL,
    examination_type varchar(32)   NOT NULL,
    body_part varchar(64)   NOT NULL,
    clinical_diagnosis varchar(512)   NULL DEFAULT NULL,
    examination_findings text   NOT NULL,
    diagnostic_opinion text   NOT NULL,
    report_status integer NOT NULL DEFAULT 0,
    report_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reviewer_id bigint NULL DEFAULT NULL,
    review_time timestamp NULL DEFAULT NULL,
    review_opinion varchar(512)   NULL DEFAULT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT report_no UNIQUE (report_no)
);

-- ----------------------------
-- 报告影像关联表
-- ----------------------------
DROP TABLE IF EXISTS report_imaging_relation CASCADE;
CREATE TABLE report_imaging_relation (
    id bigserial NOT NULL,
    report_id bigint NOT NULL,
    imaging_id bigint NOT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uk_report_imaging UNIQUE (report_id, imaging_id)
);

-- ----------------------------
-- 影像标注表：保存 MedSAM 机器标注与医生人工标注
-- ----------------------------
DROP TABLE IF EXISTS imaging_annotation CASCADE;
CREATE TABLE imaging_annotation (
    id bigserial NOT NULL,
    imaging_id bigint NOT NULL,
    doctor_id bigint NULL DEFAULT NULL,
    annotation_type varchar(32)   NOT NULL,
    annotation_data text   NOT NULL,
    label varchar(64)   NULL DEFAULT NULL,
    color varchar(16)   NULL DEFAULT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- MedSAM 分割任务表：保存模型 prompt、评分和测量结果
-- ----------------------------
DROP TABLE IF EXISTS medsam_segmentation_task CASCADE;
CREATE TABLE medsam_segmentation_task (
    id bigserial NOT NULL,
    imaging_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    operator_doctor_id bigint NULL DEFAULT NULL,
    model_name varchar(32)   NOT NULL DEFAULT 'MedSAM',
    prompt_type varchar(32)   NOT NULL,
    prompt_data text   NOT NULL,
    mask_data text NULL,
    confidence numeric(5, 4) NULL DEFAULT NULL,
    dice_estimate numeric(5, 4) NULL DEFAULT NULL,
    area_mm2 numeric(10, 2) NULL DEFAULT NULL,
    volume_cm3 numeric(10, 2) NULL DEFAULT NULL,
    task_status integer NOT NULL DEFAULT 0,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 就诊记录表
-- ----------------------------
DROP TABLE IF EXISTS visit_record CASCADE;
CREATE TABLE visit_record (
    id bigserial NOT NULL,
    patient_id bigint NOT NULL,
    doctor_id bigint NOT NULL,
    hospital_id bigint NOT NULL,
    special_id bigint NULL DEFAULT NULL,
    outpatient_id bigint NULL DEFAULT NULL,
    visit_date timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    symptoms varchar(512)   NULL DEFAULT NULL,
    diagnosis varchar(512)   NULL DEFAULT NULL,
    treatment_plan varchar(512)   NULL DEFAULT NULL,
    prescription text NULL,
    visit_status integer NOT NULL DEFAULT 0,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 菜单表
-- ----------------------------
DROP TABLE IF EXISTS power_menu CASCADE;
CREATE TABLE power_menu (
    id bigserial NOT NULL,
    parent_id bigint NULL DEFAULT NULL,
    name varchar(32)   NOT NULL,
    url varchar(128)   NULL DEFAULT NULL,
    icon varchar(64)   NULL DEFAULT NULL,
    sort integer NULL DEFAULT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 资源表
-- ----------------------------
DROP TABLE IF EXISTS power_resource CASCADE;
CREATE TABLE power_resource (
    id bigserial NOT NULL,
    category_id bigint NULL DEFAULT NULL,
    url varchar(128)   NULL DEFAULT NULL,
    name varchar(64)   NOT NULL,
    description varchar(128)   NULL DEFAULT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 资源类别表
-- ----------------------------
DROP TABLE IF EXISTS power_resource_category CASCADE;
CREATE TABLE power_resource_category (
    id bigserial NOT NULL,
    name varchar(32)   NOT NULL,
    description varchar(128)   NULL DEFAULT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 角色菜单关联表
-- ----------------------------
DROP TABLE IF EXISTS power_role_menu_relation CASCADE;
CREATE TABLE power_role_menu_relation (
    id bigserial NOT NULL,
    role_id bigint NOT NULL,
    menu_id bigint NOT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 角色资源关联表
-- ----------------------------
DROP TABLE IF EXISTS power_role_resource_relation CASCADE;
CREATE TABLE power_role_resource_relation (
    id bigserial NOT NULL,
    role_id bigint NOT NULL,
    resource_id bigint NOT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 账号角色关联表
-- ----------------------------
DROP TABLE IF EXISTS power_account_role_relation CASCADE;
CREATE TABLE power_account_role_relation (
    id bigserial NOT NULL,
    account_id bigint NOT NULL,
    role_id bigint NOT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 登录日志表
-- ----------------------------
DROP TABLE IF EXISTS log_account_login CASCADE;
CREATE TABLE log_account_login (
    id bigserial NOT NULL,
    account_id bigint NOT NULL,
    account_name varchar(32)   NULL DEFAULT NULL,
    ip_address varchar(32)   NULL DEFAULT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 操作日志表
-- ----------------------------
DROP TABLE IF EXISTS log_operation CASCADE;
CREATE TABLE log_operation (
    id bigserial NOT NULL,
    account_name varchar(32)   NULL DEFAULT NULL,
    start_time bigint NULL DEFAULT NULL,
    spend_time integer NULL DEFAULT NULL,
    description varchar(512)   NULL DEFAULT NULL,
    base_path varchar(512)   NULL DEFAULT NULL,
    uri varchar(512)   NULL DEFAULT NULL,
    url varchar(512)   NULL DEFAULT NULL,
    method varchar(32)   NULL DEFAULT NULL,
    ip_address varchar(32)   NULL DEFAULT NULL,
    parameter varchar(3072)   NULL DEFAULT NULL,
    result text NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 初始化数据
-- ----------------------------

-- 初始化角色
INSERT INTO power_role (id, name, chinese_name, admin_count, sort, status, gmt_create, gmt_modified) VALUES
(1, 'admin', '系统管理员', 1, 1, 1, NOW(), NOW()),
(2, 'doctor', '医生', 0, 2, 1, NOW(), NOW()),
(3, 'patient', '患者', 0, 3, 1, NOW(), NOW()),
(4, 'radiologist', '放射科医生', 0, 4, 1, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- 初始化测试账号
-- 前端会先 SHA256 加密明文密码，后端再使用 BCrypt 校验，这里存储的是 SHA256 后字符串的 BCrypt 值。
INSERT INTO power_account (id, name, password, status, login_time, gmt_create, gmt_modified) VALUES
(1000, 'admin', '$2a$10$PmoMm5QCsVEddE3yw1F/aez3a/0slKfgA8i/ydTsgHeuI6t9v93gW', 1, NULL, NOW(), NOW()),
(1001, 'doctor1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1002, 'doctor2', '$2a$10$e5kPah/Adaf59rhYv8UUpuydluURQ2jlV3WxDEDs2bsMgzJpxmt1u', 1, NULL, NOW(), NOW()),
(1005, 'doctor3', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1008, 'radiologist1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1003, 'patient1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1004, 'patient2', '$2a$10$Ah0XaOc/uEDQjvWzySygieTRfHuzHcv1NCTebrtNfu.uS4b/Av6SS', 1, NULL, NOW(), NOW()),
(1006, 'patient3', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1007, 'patient4', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- 初始化账号角色关联
INSERT INTO power_account_role_relation (account_id, role_id) VALUES
(1000, 1), (1001, 2), (1002, 2), (1005, 2), (1008, 4), (1003, 3), (1004, 3), (1006, 3), (1007, 3)
ON CONFLICT DO NOTHING;

-- 初始化医院信息
INSERT INTO hospital_info (id, name, phone, address, description, picture, gmt_create, gmt_modified) VALUES
(1000, '云岚宗医院', '0571-8808-6677', '云岚市青澜区云岚宗大道88号', '云岚宗医院是一所虚构的现代化综合医疗中心，提供门诊、住院、影像诊断、报告查询和慢病随访服务。', NULL, NOW(), NOW()),
(1001, '云岚宗医院城北院区', '0571-8808-6688', '云岚市北杉区清溪路66号', '云岚宗医院城北院区聚焦康复医学、慢病管理和社区连续照护。', NULL, NOW(), NOW()),
(1002, '云岚宗医院临研中心', '0571-8808-6699', '云岚市青澜区知行路18号', '云岚宗医院临研中心负责临床研究、医学教学和多学科协作诊疗。', NULL, NOW(), NOW());

-- 初始化专科
INSERT INTO hospital_special (id, name, description, gmt_create, gmt_modified) VALUES
(10000, '内科', '内科疾病诊治', NOW(), NOW()),
(10001, '外科', '外科疾病诊治', NOW(), NOW()),
(10002, '骨科', '骨科疾病诊治', NOW(), NOW()),
(10003, '神经科', '神经科疾病诊治', NOW(), NOW()),
(10004, '心血管科', '心血管疾病诊治', NOW(), NOW()),
(10005, '呼吸科', '呼吸系统疾病诊治', NOW(), NOW()),
(10006, '消化科', '消化系统疾病诊治', NOW(), NOW()),
(10007, '泌尿科', '泌尿系统疾病诊治', NOW(), NOW()),
(10008, '妇科', '妇科疾病诊治', NOW(), NOW()),
(10009, '儿科', '儿科疾病诊治', NOW(), NOW()),
(10010, '眼科', '眼科疾病诊治', NOW(), NOW()),
(10011, '医学影像科', 'CT、MRI、X光、超声检查与AI辅助影像标注', NOW(), NOW());

-- 初始化门诊
INSERT INTO hospital_outpatient (id, name, special_id, gmt_create, gmt_modified) VALUES
(10000, '普通内科门诊', 10000, NOW(), NOW()),
(10001, '专家内科门诊', 10000, NOW(), NOW()),
(10002, '普通外科门诊', 10001, NOW(), NOW()),
(10003, '骨科门诊', 10002, NOW(), NOW()),
(10004, '神经科门诊', 10003, NOW(), NOW()),
(10005, '心血管门诊', 10004, NOW(), NOW()),
(10006, '呼吸科门诊', 10005, NOW(), NOW()),
(10007, '消化科门诊', 10006, NOW(), NOW()),
(10008, '泌尿科门诊', 10007, NOW(), NOW()),
(10009, '妇科门诊', 10008, NOW(), NOW()),
(10010, '儿科门诊', 10009, NOW(), NOW()),
(10011, '眼科门诊', 10010, NOW(), NOW()),
(10012, '医学影像门诊', 10011, NOW(), NOW());

-- 初始化医院专科关系
INSERT INTO hospital_special_relation (hospital_id, special_id, gmt_create, gmt_modified) VALUES
(1000, 10000, NOW(), NOW()), (1000, 10001, NOW(), NOW()), (1000, 10002, NOW(), NOW()),
(1000, 10003, NOW(), NOW()), (1000, 10004, NOW(), NOW()), (1000, 10005, NOW(), NOW()),
(1001, 10000, NOW(), NOW()), (1001, 10001, NOW(), NOW()), (1001, 10002, NOW(), NOW());

-- 初始化医院门诊关系
INSERT INTO hospital_outpatient_relation (hospital_id, outpatient_id, gmt_create, gmt_modified) VALUES
(1000, 10000, NOW(), NOW()), (1000, 10001, NOW(), NOW()), (1000, 10002, NOW(), NOW()),
(1000, 10003, NOW(), NOW()), (1000, 10004, NOW(), NOW()), (1000, 10005, NOW(), NOW()),
(1001, 10000, NOW(), NOW()), (1001, 10002, NOW(), NOW());

-- 初始化医生信息
INSERT INTO hospital_doctor (id, account_id, name, gender, job_title, specialty, special_id, outpatient_id, hospital_id, gmt_create, gmt_modified) VALUES
(10001, 1001, '林医生', 1, '主任医师', '擅长呼吸系统疾病、胸部影像判读和慢病随访管理', 10005, 10006, 1000, NOW(), NOW()),
(10002, 1002, '韩医生', 2, '副主任医师', '擅长骨科疾病诊治、脊柱MRI判读和康复方案制定', 10002, 10003, 1000, NOW(), NOW()),
(10003, 1005, '许医生', 1, '主治医师', '擅长消化系统疾病、腹部超声和门诊综合诊疗', 10006, 10007, 1000, NOW(), NOW()),
(10004, 1008, '沈放射', 1, '主治医师', '擅长CT、MRI阅片、MedSAM自动分割和人工标注修正', 10011, 10012, 1000, NOW(), NOW());

-- 初始化患者信息
INSERT INTO patient_info (id, account_id, name, gender, phone, id_card, birth_date, address, blood_type, allergy_history, medical_history, gmt_create, gmt_modified) VALUES
(30001, 1003, '张明', 1, '13810010001', '330101198001011234', '1980-01-01', '云岚市青澜区云岚宗大道12号', 'A', '青霉素过敏', '高血压病史5年', NOW(), NOW()),
(30002, 1004, '李娜', 2, '13810010002', '330101199302022345', '1993-02-02', '云岚市青澜区白塔街26号', 'O', '无', '偏头痛病史', NOW(), NOW()),
(30003, 1006, '周强', 1, '13810010003', '330101196803033456', '1968-03-03', '云岚市北杉区清溪路19号', 'B', '无', '腰椎间盘突出病史', NOW(), NOW()),
(30004, 1007, '赵敏', 2, '13810010004', '330101198504044567', '1985-04-04', '云岚市南湖区星河路8号', 'AB', '头孢过敏', '胆囊炎间断发作', NOW(), NOW()),
(30005, NULL, '陈晨', 1, '13810010005', '330101199905055678', '1999-05-05', '云岚市青澜区知行路30号', 'A', '无', '无', NOW(), NOW()),
(30006, NULL, '孙悦', 2, '13810010006', '330101196206066789', '1962-06-06', '云岚市北杉区松风路5号', 'O', '无', '2型糖尿病', NOW(), NOW());

-- 初始化影像资料
INSERT INTO medical_imaging (id, patient_id, doctor_id, hospital_id, imaging_type, body_part, file_path, file_name, file_size, description, diagnosis_status, gmt_create, gmt_modified) VALUES
(10001, 30001, 10001, 1000, 'X光', '胸部', '/demo/imaging/chest-xray-10001.dcm', 'chest-xray-10001.dcm', 2936012, '咳嗽伴低热，胸部正侧位片。', 0, '2026-05-26 09:20:00', NOW()),
(10002, 30002, 10001, 1000, 'CT', '头颅', '/demo/imaging/head-ct-10002.dcm', 'head-ct-10002.dcm', 19293798, '头痛一周，头颅CT平扫。', 1, '2026-05-26 10:15:00', NOW()),
(10003, 30003, 10002, 1000, 'MRI', '腰椎', '/demo/imaging/lumbar-mri-10003.dcm', 'lumbar-mri-10003.dcm', 37329305, '腰痛伴左下肢放射痛。', 0, '2026-05-25 15:40:00', NOW()),
(10004, 30004, 10003, 1000, '超声', '腹部', '/demo/imaging/abdomen-us-10004.png', 'abdomen-us-10004.png', 6396313, '右上腹不适，腹部超声检查。', 1, '2026-05-24 14:05:00', NOW()),
(10005, 30005, 10001, 1000, 'CT', '胸部', '/demo/imaging/chest-ct-10005.dcm', 'chest-ct-10005.dcm', 23068672, '胸闷气短，胸部CT薄层扫描。', 0, '2026-05-23 11:30:00', NOW());

-- 初始化诊断报告
INSERT INTO diagnosis_report (id, patient_id, doctor_id, hospital_id, special_id, report_no, patient_name, gender, age, id_card, phone, examination_type, body_part, clinical_diagnosis, examination_findings, diagnostic_opinion, report_status, report_date, reviewer_id, review_time, review_opinion, gmt_create, gmt_modified) VALUES
(20001, 30002, 10001, 1000, 10003, 'YLZ-R-20260526001', '李娜', 2, 33, '330101199302022345', '13810010002', 'CT', '头颅', '头痛待查', '头颅CT平扫示脑实质密度未见明显异常，脑室系统形态大小正常，中线结构居中。', '头颅CT未见明确急性异常征象。建议结合神经内科查体及随访。', 1, '2026-05-26 11:05:00', NULL, NULL, NULL, NOW(), NOW()),
(20002, 30004, 10003, 1000, 10006, 'YLZ-R-20260524001', '赵敏', 2, 41, '330101198504044567', '13810010004', '超声', '腹部', '右上腹不适', '肝胆胰脾超声检查，胆囊壁稍毛糙，未见明显结石声影。', '胆囊壁轻度改变，建议结合肝胆功能检查。', 1, '2026-05-24 15:00:00', NULL, NULL, NULL, NOW(), NOW()),
(20003, 30006, 10002, 1000, 10002, 'YLZ-R-20260522001', '孙悦', 2, 62, '330101196206066789', '13810010006', 'MRI', '膝关节', '膝关节疼痛', '右膝关节MRI示半月板退变信号，关节腔少量积液。', '右膝退行性改变，建议骨科门诊结合体征评估。', 2, '2026-05-22 16:10:00', 10002, '2026-05-22 16:30:00', '同意报告结论。', NOW(), NOW());

INSERT INTO report_imaging_relation (report_id, imaging_id, gmt_create) VALUES
(20001, 10002, NOW()),
(20002, 10004, NOW());

-- 初始化 MedSAM 分割与标注归档
INSERT INTO medsam_segmentation_task (id, imaging_id, patient_id, operator_doctor_id, model_name, prompt_type, prompt_data, mask_data, confidence, dice_estimate, area_mm2, volume_cm3, task_status, gmt_create, gmt_modified) VALUES
(10001, 10001, 30001, 10004, 'MedSAM', 'box', '{"x":156,"y":89,"w":234,"h":187,"slice":42,"series":"序列3"}', '{"maskType":"ellipse","center":[278,186],"rx":80,"ry":52}', 0.9300, 0.9100, 342.50, 12.80, 3, '2026-05-26 10:20:00', NOW()),
(10002, 10003, 30003, 10004, 'MedSAM', 'box', '{"x":142,"y":96,"w":210,"h":168,"slice":36,"series":"序列2"}', '{"maskType":"ellipse","center":[247,180],"rx":72,"ry":48}', 0.9000, 0.8800, 298.20, 10.60, 1, '2026-05-25 16:10:00', NOW());

INSERT INTO imaging_annotation (id, imaging_id, doctor_id, annotation_type, annotation_data, label, color, gmt_create) VALUES
(10001, 10001, 10004, 'mask', '{"source":"machine","modelName":"MedSAM","promptBox":{"x":156,"y":89,"w":234,"h":187},"slice":42,"confidence":0.93,"dice":0.91}', 'AI分割结果', '#18bc7e', '2026-05-26 10:20:00'),
(10002, 10001, 10004, 'brush', '{"source":"manual","tool":"brush","x":288,"y":190,"r":18,"slice":42}', '人工补画', '#22c55e', '2026-05-26 10:24:00'),
(10003, 10003, 10004, 'mask', '{"source":"machine","modelName":"MedSAM","promptBox":{"x":142,"y":96,"w":210,"h":168},"slice":36,"confidence":0.90,"dice":0.88}', 'AI分割结果', '#18bc7e', '2026-05-25 16:10:00');

-- 初始化就诊记录
INSERT INTO visit_record (id, patient_id, doctor_id, hospital_id, special_id, outpatient_id, visit_date, symptoms, diagnosis, treatment_plan, prescription, visit_status, gmt_create, gmt_modified) VALUES
(40001, 30001, 10001, 1000, 10005, 10006, '2026-05-26 08:50:00', '咳嗽、低热3天', '呼吸道感染待排', '完善胸部X光，必要时复诊', '对症治疗，遵医嘱用药', 1, NOW(), NOW()),
(40002, 30002, 10001, 1000, 10003, 10004, '2026-05-26 09:45:00', '头痛一周', '头痛待查', '已完成头颅CT，建议神经内科随访', '监测血压，注意休息', 2, NOW(), NOW()),
(40003, 30003, 10002, 1000, 10002, 10003, '2026-05-25 15:00:00', '腰痛伴左下肢放射痛', '腰椎间盘突出待排', '完善腰椎MRI后评估', '避免久坐久站', 1, NOW(), NOW());

-- 初始化菜单
INSERT INTO power_menu (id, parent_id, name, url, icon, sort, gmt_create, gmt_modified) VALUES
(1, NULL, '系统管理', NULL, 'el-icon-setting', 1, NOW(), NOW()),
(2, NULL, '医院管理', NULL, 'el-icon-hospital', 2, NOW(), NOW()),
(3, NULL, '诊疗管理', NULL, 'el-icon-first-aid-kit', 3, NOW(), NOW()),
(4, NULL, '患者管理', NULL, 'el-icon-user', 4, NOW(), NOW()),
(5, 1, '账号管理', '/system/account', NULL, 1, NOW(), NOW()),
(6, 1, '角色管理', '/system/role', NULL, 2, NOW(), NOW()),
(7, 2, '医院信息', '/hospital/info', NULL, 1, NOW(), NOW()),
(8, 2, '专科管理', '/hospital/special', NULL, 2, NOW(), NOW()),
(9, 2, '门诊管理', '/hospital/outpatient', NULL, 3, NOW(), NOW()),
(10, 2, '医生管理', '/hospital/doctor', NULL, 4, NOW(), NOW()),
(11, 3, '就诊记录', '/diagnosis/visit', NULL, 1, NOW(), NOW()),
(12, 3, '影像管理', '/diagnosis/imaging', NULL, 2, NOW(), NOW()),
(13, 3, '诊断报告', '/diagnosis/report', NULL, 3, NOW(), NOW()),
(14, 4, '患者列表', '/patient/list', NULL, 1, NOW(), NOW()),
(15, 4, '患者档案', '/patient/archive', NULL, 2, NOW(), NOW()),
(16, NULL, '我的就诊', NULL, 'el-icon-document', 5, NOW(), NOW()),
(17, 16, '我的病历', '/my/medical-record', NULL, 1, NOW(), NOW()),
(18, 16, '我的报告', '/my/report', NULL, 2, NOW(), NOW()),
(19, 16, '预约挂号', '/my/appointment', NULL, 3, NOW(), NOW());

-- PostgreSQL sequence synchronization
SELECT setval(pg_get_serial_sequence('user_basic_info', 'id'), COALESCE((SELECT MAX(id) FROM user_basic_info), 1));
SELECT setval(pg_get_serial_sequence('power_account', 'id'), COALESCE((SELECT MAX(id) FROM power_account), 1));
SELECT setval(pg_get_serial_sequence('power_role', 'id'), COALESCE((SELECT MAX(id) FROM power_role), 1));
SELECT setval(pg_get_serial_sequence('hospital_info', 'id'), COALESCE((SELECT MAX(id) FROM hospital_info), 1));
SELECT setval(pg_get_serial_sequence('hospital_special', 'id'), COALESCE((SELECT MAX(id) FROM hospital_special), 1));
SELECT setval(pg_get_serial_sequence('hospital_outpatient', 'id'), COALESCE((SELECT MAX(id) FROM hospital_outpatient), 1));
SELECT setval(pg_get_serial_sequence('hospital_outpatient_relation', 'id'), COALESCE((SELECT MAX(id) FROM hospital_outpatient_relation), 1));
SELECT setval(pg_get_serial_sequence('hospital_special_relation', 'id'), COALESCE((SELECT MAX(id) FROM hospital_special_relation), 1));
SELECT setval(pg_get_serial_sequence('hospital_clinic', 'id'), COALESCE((SELECT MAX(id) FROM hospital_clinic), 1));
SELECT setval(pg_get_serial_sequence('hospital_doctor', 'id'), COALESCE((SELECT MAX(id) FROM hospital_doctor), 1));
SELECT setval(pg_get_serial_sequence('patient_info', 'id'), COALESCE((SELECT MAX(id) FROM patient_info), 1));
SELECT setval(pg_get_serial_sequence('medical_imaging', 'id'), COALESCE((SELECT MAX(id) FROM medical_imaging), 1));
SELECT setval(pg_get_serial_sequence('diagnosis_report', 'id'), COALESCE((SELECT MAX(id) FROM diagnosis_report), 1));
SELECT setval(pg_get_serial_sequence('report_imaging_relation', 'id'), COALESCE((SELECT MAX(id) FROM report_imaging_relation), 1));
SELECT setval(pg_get_serial_sequence('imaging_annotation', 'id'), COALESCE((SELECT MAX(id) FROM imaging_annotation), 1));
SELECT setval(pg_get_serial_sequence('medsam_segmentation_task', 'id'), COALESCE((SELECT MAX(id) FROM medsam_segmentation_task), 1));
SELECT setval(pg_get_serial_sequence('visit_record', 'id'), COALESCE((SELECT MAX(id) FROM visit_record), 1));
SELECT setval(pg_get_serial_sequence('power_menu', 'id'), COALESCE((SELECT MAX(id) FROM power_menu), 1));
SELECT setval(pg_get_serial_sequence('power_resource', 'id'), COALESCE((SELECT MAX(id) FROM power_resource), 1));
SELECT setval(pg_get_serial_sequence('power_resource_category', 'id'), COALESCE((SELECT MAX(id) FROM power_resource_category), 1));
SELECT setval(pg_get_serial_sequence('power_role_menu_relation', 'id'), COALESCE((SELECT MAX(id) FROM power_role_menu_relation), 1));
SELECT setval(pg_get_serial_sequence('power_role_resource_relation', 'id'), COALESCE((SELECT MAX(id) FROM power_role_resource_relation), 1));
SELECT setval(pg_get_serial_sequence('power_account_role_relation', 'id'), COALESCE((SELECT MAX(id) FROM power_account_role_relation), 1));
SELECT setval(pg_get_serial_sequence('log_account_login', 'id'), COALESCE((SELECT MAX(id) FROM log_account_login), 1));
SELECT setval(pg_get_serial_sequence('log_operation', 'id'), COALESCE((SELECT MAX(id) FROM log_operation), 1));
