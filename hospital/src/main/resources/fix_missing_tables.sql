-- PostgreSQL script aligned with the medical imaging platform document.
-- Structured data: PostgreSQL. Queue/cache: Redis. Binary assets: MinIO/NAS via URI columns.

-- 修复缺失的数据库表
-- 仅创建影像管理和标注功能所需的表
-- ----------------------------
-- 出诊计划表（修复之前的报错）
-- ----------------------------
DROP TABLE IF EXISTS visit_plan CASCADE;
CREATE TABLE visit_plan (
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
-- 影像资料表
-- ----------------------------
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
    symptoms varchar(512) NULL DEFAULT NULL,
    diagnosis varchar(512) NULL DEFAULT NULL,
    treatment_plan varchar(512) NULL DEFAULT NULL,
    prescription text NULL,
    visit_status integer NOT NULL DEFAULT 0,
    gmt_create timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- 影像标注表（人工标注数据存储）
-- ----------------------------
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

-- PostgreSQL sequence synchronization
SELECT setval(pg_get_serial_sequence('visit_plan', 'id'), COALESCE((SELECT MAX(id) FROM visit_plan), 1));
SELECT setval(pg_get_serial_sequence('medical_imaging', 'id'), COALESCE((SELECT MAX(id) FROM medical_imaging), 1));
SELECT setval(pg_get_serial_sequence('diagnosis_report', 'id'), COALESCE((SELECT MAX(id) FROM diagnosis_report), 1));
SELECT setval(pg_get_serial_sequence('report_imaging_relation', 'id'), COALESCE((SELECT MAX(id) FROM report_imaging_relation), 1));
SELECT setval(pg_get_serial_sequence('visit_record', 'id'), COALESCE((SELECT MAX(id) FROM visit_record), 1));
SELECT setval(pg_get_serial_sequence('imaging_annotation', 'id'), COALESCE((SELECT MAX(id) FROM imaging_annotation), 1));
