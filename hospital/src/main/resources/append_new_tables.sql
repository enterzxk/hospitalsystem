-- PostgreSQL canonical schema generated for the medical imaging platform.
-- Structured data: PostgreSQL. Queue/cache: Redis. Binary assets: MinIO/NAS via URI columns.

-- =====================================================
-- 新增表：患者信息、影像、诊断报告、标注等
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

-- 标准检查表
DROP TABLE IF EXISTS studies CASCADE;
CREATE TABLE studies (
    id bigserial NOT NULL,
    patient_id bigint NOT NULL,
    imaging_id bigint NULL DEFAULT NULL,
    study_uid varchar(96) NOT NULL,
    modality varchar(32) NOT NULL,
    body_part varchar(64) NULL DEFAULT NULL,
    study_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metadata_json text NULL,
    storage_root varchar(512) NULL DEFAULT NULL,
    anonymized integer NOT NULL DEFAULT 0,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uk_study_uid UNIQUE (study_uid)
);

-- 标准序列表
DROP TABLE IF EXISTS series CASCADE;
CREATE TABLE series (
    id bigserial NOT NULL,
    study_id bigint NOT NULL,
    series_uid varchar(96) NOT NULL,
    modality varchar(32) NOT NULL,
    description varchar(256) NULL DEFAULT NULL,
    spacing varchar(128) NULL DEFAULT NULL,
    slice_count integer NULL DEFAULT 1,
    metadata_json text NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uk_series_uid UNIQUE (series_uid)
);

-- 标准实例表
DROP TABLE IF EXISTS instances CASCADE;
CREATE TABLE instances (
    id bigserial NOT NULL,
    series_id bigint NOT NULL,
    sop_uid varchar(96) NOT NULL,
    slice_index integer NOT NULL DEFAULT 1,
    file_uri varchar(512) NOT NULL,
    thumbnail_uri varchar(512) NULL DEFAULT NULL,
    render_uri varchar(512) NULL DEFAULT NULL,
    metadata_json text NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uk_sop_uid UNIQUE (sop_uid)
);

-- Prompt 表
DROP TABLE IF EXISTS prompts CASCADE;
CREATE TABLE prompts (
    id bigserial NOT NULL,
    imaging_id bigint NULL DEFAULT NULL,
    study_id bigint NULL DEFAULT NULL,
    series_id bigint NULL DEFAULT NULL,
    instance_id bigint NULL DEFAULT NULL,
    prompt_type varchar(32) NOT NULL,
    coordinates_json text NOT NULL,
    coord_space varchar(32) NOT NULL DEFAULT 'viewer',
    slice_index integer NULL DEFAULT NULL,
    created_by bigint NULL DEFAULT NULL,
    version integer NOT NULL DEFAULT 1,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- 模型注册表
DROP TABLE IF EXISTS model_registry CASCADE;
CREATE TABLE model_registry (
    id bigserial NOT NULL,
    model_id varchar(96) NOT NULL,
    name varchar(128) NOT NULL,
    task_type varchar(32) NOT NULL,
    modality varchar(64) NOT NULL DEFAULT 'ALL',
    version varchar(32) NOT NULL,
    weight_uri varchar(512) NULL DEFAULT NULL,
    config_json text NULL,
    status integer NOT NULL DEFAULT 1,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uk_model_id UNIQUE (model_id)
);

-- 推理任务表
DROP TABLE IF EXISTS inference_jobs CASCADE;
CREATE TABLE inference_jobs (
    id bigserial NOT NULL,
    job_id varchar(96) NOT NULL,
    task_type varchar(32) NOT NULL,
    model_id varchar(96) NOT NULL,
    imaging_id bigint NULL DEFAULT NULL,
    study_id bigint NULL DEFAULT NULL,
    series_id bigint NULL DEFAULT NULL,
    instance_id bigint NULL DEFAULT NULL,
    input_ref varchar(512) NULL DEFAULT NULL,
    prompt_json text NULL,
    preprocess_json text NULL,
    status integer NOT NULL DEFAULT 0,
    progress integer NOT NULL DEFAULT 0,
    error_msg varchar(512) NULL DEFAULT NULL,
    created_by bigint NULL DEFAULT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uk_job_id UNIQUE (job_id)
);

-- AI 分析结果表
DROP TABLE IF EXISTS ai_analysis_result CASCADE;
CREATE TABLE ai_analysis_result (
    id bigserial NOT NULL,
    result_id varchar(96) NOT NULL,
    job_id varchar(96) NOT NULL,
    task_type varchar(32) NOT NULL,
    imaging_id bigint NULL DEFAULT NULL,
    study_id bigint NULL DEFAULT NULL,
    series_id bigint NULL DEFAULT NULL,
    instance_id bigint NULL DEFAULT NULL,
    model_id varchar(96) NOT NULL,
    model_name varchar(128) NULL DEFAULT NULL,
    model_version varchar(32) NULL DEFAULT NULL,
    confidence numeric(8,4) NULL DEFAULT NULL,
    result_json text NOT NULL,
    confirm_status integer NOT NULL DEFAULT 0,
    confirmed_by bigint NULL DEFAULT NULL,
    confirmed_at timestamp NULL DEFAULT NULL,
    confirm_comment varchar(512) NULL DEFAULT NULL,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT uk_result_id UNIQUE (result_id)
);

INSERT INTO model_registry (model_id, name, task_type, modality, version, weight_uri, config_json, status, gmt_create, gmt_modified) VALUES
('medsam_v1.0', 'MedSAM', 'segmentation', 'CT', 'v1.0', 'minio://medical-imaging/models/medsam_v1.0/medsam_v1.pth', '{"prompt":["box","point"],"worker":"medsam-service"}', 1, NOW(), NOW()),
('lesion_det_demo_v1', 'lesion_det_demo', 'detection', 'CT', 'v1.0', 'minio://medical-imaging/models/lesion_det_demo_v1/detection-demo.onnx', '{"worker":"demo","output":"bbox"}', 1, NOW(), NOW()),
('lesion_cls_demo_v1', 'lesion_cls_demo', 'classification', 'CT', 'v1.0', 'minio://medical-imaging/models/lesion_cls_demo_v1/classification-demo.onnx', '{"worker":"demo","output":"label_probability"}', 1, NOW(), NOW());

-- =====================================================
-- 新增放射科医生角色和账号
-- =====================================================

-- 添加基础角色
INSERT INTO power_role(id, name, chinese_name, admin_count, sort, status, gmt_create, gmt_modified)
VALUES
(1, 'admin', '系统管理员', 1, 1, 1, NOW(), NOW()),
(2, 'doctor', '医生', 0, 2, 1, NOW(), NOW()),
(3, 'patient', '患者', 0, 3, 1, NOW(), NOW()),
(4, 'radiologist', '放射科医生', 0, 4, 1, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- 添加基础账号：admin/admin，其余账号/123456
INSERT INTO power_account(id, name, password, status, login_time, gmt_create, gmt_modified)
VALUES
(1000, 'admin', '$2a$10$PmoMm5QCsVEddE3yw1F/aez3a/0slKfgA8i/ydTsgHeuI6t9v93gW', 1, NULL, NOW(), NOW()),
(1001, 'doctor1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1003, 'patient1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(10000010, 'radiologist1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- 添加账号角色关联
INSERT INTO power_account_role_relation(account_id, role_id, gmt_create, gmt_modified)
VALUES
(1000, 1, NOW(), NOW()),
(1001, 2, NOW(), NOW()),
(1003, 3, NOW(), NOW()),
(10000010, 4, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- Synchronize PostgreSQL sequences seed IDs.
SELECT setval(pg_get_serial_sequence('patient_info', 'id'), COALESCE((SELECT MAX(id) FROM patient_info), 1));
SELECT setval(pg_get_serial_sequence('medical_imaging', 'id'), COALESCE((SELECT MAX(id) FROM medical_imaging), 1));
SELECT setval(pg_get_serial_sequence('diagnosis_report', 'id'), COALESCE((SELECT MAX(id) FROM diagnosis_report), 1));
SELECT setval(pg_get_serial_sequence('report_imaging_relation', 'id'), COALESCE((SELECT MAX(id) FROM report_imaging_relation), 1));
SELECT setval(pg_get_serial_sequence('visit_record', 'id'), COALESCE((SELECT MAX(id) FROM visit_record), 1));
SELECT setval(pg_get_serial_sequence('imaging_annotation', 'id'), COALESCE((SELECT MAX(id) FROM imaging_annotation), 1));
SELECT setval(pg_get_serial_sequence('studies', 'id'), COALESCE((SELECT MAX(id) FROM studies), 1));
SELECT setval(pg_get_serial_sequence('series', 'id'), COALESCE((SELECT MAX(id) FROM series), 1));
SELECT setval(pg_get_serial_sequence('instances', 'id'), COALESCE((SELECT MAX(id) FROM instances), 1));
SELECT setval(pg_get_serial_sequence('prompts', 'id'), COALESCE((SELECT MAX(id) FROM prompts), 1));
SELECT setval(pg_get_serial_sequence('model_registry', 'id'), COALESCE((SELECT MAX(id) FROM model_registry), 1));
SELECT setval(pg_get_serial_sequence('inference_jobs', 'id'), COALESCE((SELECT MAX(id) FROM inference_jobs), 1));
SELECT setval(pg_get_serial_sequence('ai_analysis_result', 'id'), COALESCE((SELECT MAX(id) FROM ai_analysis_result), 1));

-- PostgreSQL sequence synchronization
SELECT setval(pg_get_serial_sequence('patient_info', 'id'), COALESCE((SELECT MAX(id) FROM patient_info), 1));
SELECT setval(pg_get_serial_sequence('medical_imaging', 'id'), COALESCE((SELECT MAX(id) FROM medical_imaging), 1));
SELECT setval(pg_get_serial_sequence('diagnosis_report', 'id'), COALESCE((SELECT MAX(id) FROM diagnosis_report), 1));
SELECT setval(pg_get_serial_sequence('report_imaging_relation', 'id'), COALESCE((SELECT MAX(id) FROM report_imaging_relation), 1));
SELECT setval(pg_get_serial_sequence('visit_record', 'id'), COALESCE((SELECT MAX(id) FROM visit_record), 1));
SELECT setval(pg_get_serial_sequence('imaging_annotation', 'id'), COALESCE((SELECT MAX(id) FROM imaging_annotation), 1));
SELECT setval(pg_get_serial_sequence('studies', 'id'), COALESCE((SELECT MAX(id) FROM studies), 1));
SELECT setval(pg_get_serial_sequence('series', 'id'), COALESCE((SELECT MAX(id) FROM series), 1));
SELECT setval(pg_get_serial_sequence('instances', 'id'), COALESCE((SELECT MAX(id) FROM instances), 1));
SELECT setval(pg_get_serial_sequence('prompts', 'id'), COALESCE((SELECT MAX(id) FROM prompts), 1));
SELECT setval(pg_get_serial_sequence('model_registry', 'id'), COALESCE((SELECT MAX(id) FROM model_registry), 1));
SELECT setval(pg_get_serial_sequence('inference_jobs', 'id'), COALESCE((SELECT MAX(id) FROM inference_jobs), 1));
SELECT setval(pg_get_serial_sequence('ai_analysis_result', 'id'), COALESCE((SELECT MAX(id) FROM ai_analysis_result), 1));
