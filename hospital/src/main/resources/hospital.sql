-- PostgreSQL script aligned with the medical imaging platform document.
-- Structured data: PostgreSQL. Queue/cache: Redis. Binary assets: MinIO/NAS via URI columns.

-- ----------------------------
-- Table structure for hospital_clinic
-- ----------------------------
DROP TABLE IF EXISTS hospital_clinic CASCADE;
CREATE TABLE hospital_clinic
(
    id            bigserial NOT NULL,
    outpatient_id bigint                                                    NOT NULL,
    address       varchar(128)   NOT NULL,
    gmt_create    timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified  timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- Table structure for hospital_doctor
-- ----------------------------
DROP TABLE IF EXISTS hospital_doctor CASCADE;
CREATE TABLE hospital_doctor
(
    id            bigserial NOT NULL,
    name          varchar(32)    NOT NULL,
    gender        integer                                                       NOT NULL DEFAULT 1,
    job_title     varchar(32)    NOT NULL,
    specialty     varchar(512)   NOT NULL,
    special_id    bigint                                                    NOT NULL,
    outpatient_id bigint                                                    NOT NULL,
    gmt_create    timestamp                                                   NOT NULL,
    gmt_modified  timestamp                                                   NOT NULL,
    PRIMARY KEY (id)
);

-- ----------------------------
-- Table structure for hospital_info
-- ----------------------------
DROP TABLE IF EXISTS hospital_info CASCADE;
CREATE TABLE hospital_info
(
    id           bigserial NOT NULL,
    name         varchar(32)    NOT NULL,
    phone        varchar(32)    NULL DEFAULT NULL,
    address      varchar(128)   NULL DEFAULT NULL,
    description  varchar(512)   NULL DEFAULT NULL,
    picture      varchar(512)   NULL DEFAULT NULL,
    gmt_create   timestamp                                                   NOT NULL,
    gmt_modified timestamp                                                   NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT hospital_info_phone_uindex UNIQUE (phone)
);

-- ----------------------------
-- Table structure for hospital_outpatient
-- ----------------------------
DROP TABLE IF EXISTS hospital_outpatient CASCADE;
CREATE TABLE hospital_outpatient
(
    id           bigserial NOT NULL,
    name         varchar(32)   NOT NULL,
    special_id   bigint                                                   NOT NULL,
    gmt_create   timestamp                                                  NOT NULL,
    gmt_modified timestamp                                                  NOT NULL,
    PRIMARY KEY (id)
);

-- ----------------------------
-- Table structure for hospital_outpatient_relation
-- ----------------------------
DROP TABLE IF EXISTS hospital_outpatient_relation CASCADE;
CREATE TABLE hospital_outpatient_relation
(
    id            bigserial NOT NULL,
    hospital_id   bigint  NOT NULL,
    outpatient_id bigint  NOT NULL,
    gmt_create    timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- Table structure for hospital_special
-- ----------------------------
DROP TABLE IF EXISTS hospital_special CASCADE;
CREATE TABLE hospital_special
(
    id           bigserial NOT NULL,
    name         varchar(32)    NOT NULL,
    description  varchar(512)   NOT NULL,
    gmt_create   timestamp                                                   NOT NULL,
    gmt_modified timestamp                                                   NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT hospital_special_name_uindex UNIQUE (name)
);

-- ----------------------------
-- Table structure for hospital_special_relation
-- ----------------------------
DROP TABLE IF EXISTS hospital_special_relation CASCADE;
CREATE TABLE hospital_special_relation
(
    id           bigserial NOT NULL,
    hospital_id  bigint  NOT NULL,
    special_id   bigint  NOT NULL,
    gmt_create   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- Table structure for log_account_login
-- ----------------------------
DROP TABLE IF EXISTS log_account_login CASCADE;
CREATE TABLE log_account_login
(
    id           bigserial NOT NULL,
    account_id   bigint                                                   NOT NULL,
    account_name varchar(32)   NULL     DEFAULT NULL,
    ip_address   varchar(32)   NULL     DEFAULT NULL,
    gmt_create   timestamp                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- Table structure for log_operation
-- ----------------------------
DROP TABLE IF EXISTS log_operation CASCADE;
CREATE TABLE log_operation
(
    id           bigserial NOT NULL,
    account_name varchar(32)     NULL     DEFAULT NULL,
    start_time   bigint                                                     NULL     DEFAULT NULL,
    spend_time   integer                                                        NULL     DEFAULT NULL,
    description  varchar(512)    NULL     DEFAULT NULL,
    base_path    varchar(512)    NULL     DEFAULT NULL,
    uri          varchar(512)    NULL     DEFAULT NULL,
    url          varchar(512)    NULL     DEFAULT NULL,
    method       varchar(32)     NULL     DEFAULT NULL,
    ip_address   varchar(32)     NULL     DEFAULT NULL,
    parameter    varchar(3072)   NULL     DEFAULT NULL,
    result       text NULL,
    gmt_create   timestamp                                                    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp                                                    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- Table structure for power_account
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
-- Table structure for power_account_role_relation
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
-- Table structure for power_menu
-- ----------------------------
DROP TABLE IF EXISTS power_menu CASCADE;
CREATE TABLE power_menu
(
    id           bigserial NOT NULL,
    parent_id    bigint                                                   NULL     DEFAULT NULL,
    title        varchar(32)   NOT NULL,
    level        integer                                                      NOT NULL,
    sort         integer                                                      NOT NULL,
    name         varchar(32)   NOT NULL,
    icon         varchar(32)   NOT NULL,
    hidden       integer                                                      NOT NULL DEFAULT 1,
    gmt_create   timestamp                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT power_menu_name_uindex UNIQUE (name),
    CONSTRAINT power_menu_title_uindex UNIQUE (title)
);

-- ----------------------------
-- Table structure for power_resource
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
-- Table structure for power_resource_category
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
-- Table structure for power_role
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
-- Table structure for power_role_menu_relation
-- ----------------------------
DROP TABLE IF EXISTS power_role_menu_relation CASCADE;
CREATE TABLE power_role_menu_relation
(
    id           bigserial NOT NULL,
    role_id      bigint  NOT NULL,
    menu_id      bigint  NOT NULL,
    gmt_create   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- Table structure for power_role_resource_relation
-- ----------------------------
DROP TABLE IF EXISTS power_role_resource_relation CASCADE;
CREATE TABLE power_role_resource_relation
(
    id           bigserial NOT NULL,
    role_id      bigint  NOT NULL,
    resource_id  bigint  NOT NULL,
    gmt_create   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- Table structure for user_basic_info
-- ----------------------------
DROP TABLE IF EXISTS user_basic_info CASCADE;
CREATE TABLE user_basic_info
(
    id           bigserial NOT NULL,
    name         varchar(32)    NOT NULL,
    avatar_url   varchar(512)   NOT NULL,
    phone        varchar(32)    NOT NULL,
    gmt_create   timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT user_basic_info_phone_uindex UNIQUE (phone)
);

-- ----------------------------
-- Table structure for user_case
-- ----------------------------
DROP TABLE IF EXISTS user_case CASCADE;
CREATE TABLE user_case
(
    id             bigserial NOT NULL,
    card_id        bigint                                                    NOT NULL,
    appointment_id bigint                                                    NOT NULL,
    doctor_id      bigint                                                    NOT NULL,
    content        varchar(512)   NOT NULL,
    gmt_create     timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified   timestamp                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);
-- ----------------------------
-- Table structure for user_medical_card
-- ----------------------------
DROP TABLE IF EXISTS user_medical_card CASCADE;
CREATE TABLE user_medical_card
(
    id                    bigserial NOT NULL,
    name                  varchar(32)   NOT NULL,
    gender                integer                                                      NOT NULL DEFAULT 1,
    phone                 varchar(32)   NOT NULL,
    identification_number varchar(32)   NOT NULL,
    birth_date            timestamp                                                  NOT NULL,
    gmt_create            timestamp                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified          timestamp                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT user_medical_card_identification_number_uindex UNIQUE (identification_number)
);

-- ----------------------------
-- Table structure for user_medical_card_relation
-- ----------------------------
DROP TABLE IF EXISTS user_medical_card_relation CASCADE;
CREATE TABLE user_medical_card_relation
(
    id           bigserial NOT NULL,
    type         integer     NOT NULL,
    account_id   bigint  NOT NULL,
    card_id      bigint  NOT NULL,
    gmt_create   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- Table structure for visit_appointment
-- ----------------------------
DROP TABLE IF EXISTS visit_appointment CASCADE;
CREATE TABLE visit_appointment
(
    id           bigserial NOT NULL,
    plan_id      bigint  NOT NULL,
    card_id      bigint  NOT NULL,
    account_id   bigint  NOT NULL,
    time_period  integer     NOT NULL,
    status       integer     NOT NULL DEFAULT 0,
    gmt_create   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- Table structure for visit_blacklist
-- ----------------------------
DROP TABLE IF EXISTS visit_blacklist CASCADE;
CREATE TABLE visit_blacklist
(
    id           bigserial NOT NULL,
    card_id      bigint  NOT NULL,
    status       integer     NOT NULL DEFAULT 1,
    gmt_create   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- ----------------------------
-- Table structure for visit_plan
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
INSERT INTO hospital.power_account(id, name, password, status, login_time, gmt_create, gmt_modified)
VALUES (10000006, 'test', '$2a$10$im44.HgXDahyBbY2Wx2FA.ZSEmhDoycqYjMSzr.V8SuQkJlQR6XRS', 1, '2020-04-11 14:31:26',
        '2020-04-11 14:31:14', '2020-04-11 14:31:14');
INSERT INTO hospital.power_account(id, name, password, status, login_time, gmt_create, gmt_modified)
VALUES (10000001, 'doctor', '$2a$10$S.e7q.IBQtE3pqoZhfsRDexYFGwEXWxAhO4Wv09E9C6dUM2QX1Kvm', 1, '2020-04-19 15:37:08',
        '2020-03-27 02:46:21', '2020-03-29 03:04:56');
INSERT INTO hospital.power_account(id, name, password, status, login_time, gmt_create, gmt_modified)
VALUES (10000005, 'admin', '$2a$10$l0dSGURNp2Q9z2m3jea37.CV9.OH76qprHxIDklyJPK2EzEIg4m2W', 1, '2020-04-11 14:30:26',
        '2020-01-25 08:04:14', '2020-03-29 02:57:48');

INSERT INTO hospital.hospital_info(id, name, phone, address, description, picture, gmt_create,
                                       gmt_modified)
VALUES (1000, '广东省中医院', '020-123452', '广州大学城', '广东省中医院', 'http://image.yujian95.cn/FmxdyLFebwrEhId3tyb7AXo5Xryc',
        '2020-02-05 13:06:55', '2020-03-16 09:57:16');
INSERT INTO hospital.hospital_info(id, name, phone, address, description, picture, gmt_create,
                                       gmt_modified)
VALUES (1001, '顺德分院', '020-1234567', '广东省佛山市顺德区', '位于广东省佛山市顺德区',
        'http://image.yujian95.cn/FmHCxgk544aFLNg5WLu9ES4gWOo1', '2020-03-16 08:00:03', '2020-03-16 08:00:03');
INSERT INTO hospital.hospital_info(id, name, phone, address, description, picture, gmt_create,
                                       gmt_modified)
VALUES (1002, '白云分院', '020-1234568', '广东省广州市白云区', '位于广东省广州市白云区',
        'http://image.yujian95.cn/Fq-bSZSpZHGC0FlvAAgOP8XDYzBE', '2020-03-16 08:03:30', '2020-03-16 08:03:30');
INSERT INTO hospital.hospital_info(id, name, phone, address, description, picture, gmt_create,
                                       gmt_modified)
VALUES (1007, '越秀分院', '020-1234563', '广东省越秀区', '位于广东省越秀区', 'http://image.yujian95.cn/FmxdyLFebwrEhId3tyb7AXo5Xryc',
        '2020-03-22 04:53:40', '2020-03-22 04:53:40');

INSERT INTO hospital.hospital_special(id, name, description, gmt_create, gmt_modified)
VALUES (10000, '妇科', '女性妇科相关智联', '2020-03-20 03:54:25', '2020-03-20 03:54:25');
INSERT INTO hospital.hospital_special(id, name, description, gmt_create, gmt_modified)
VALUES (10006, '皮肤科', '皮肤相关治疗', '2020-03-20 04:14:07', '2020-03-20 04:14:07');
INSERT INTO hospital.hospital_special(id, name, description, gmt_create, gmt_modified)
VALUES (10008, '儿科', '儿童相关治疗', '2020-03-20 04:17:00', '2020-03-20 04:17:00');
INSERT INTO hospital.hospital_special(id, name, description, gmt_create, gmt_modified)
VALUES (10009, '眼科', '眼部相关治疗', '2020-03-20 06:53:22', '2020-03-20 06:53:22');
INSERT INTO hospital.hospital_special(id, name, description, gmt_create, gmt_modified)
VALUES (10010, '内科', '甲状腺等内科治疗', '2020-03-20 06:55:01', '2020-03-20 06:55:01');

INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10002, '儿童发热', 10008, '2020-03-20 07:02:52', '2020-03-20 07:02:52');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10003, '儿童牙科', 10008, '2020-03-20 07:03:03', '2020-03-20 07:03:03');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10004, '儿童外科擦伤', 10008, '2020-03-20 07:03:21', '2020-03-20 07:03:37');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10005, '普通门诊', 10000, '2020-03-20 07:04:14', '2020-03-20 07:04:14');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10006, '流产专科', 10000, '2020-03-20 07:07:32', '2020-03-20 07:07:32');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10007, '不孕症专科', 10000, '2020-03-20 07:07:54', '2020-03-20 07:07:54');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10008, '皮肤科', 10006, '2020-03-20 07:09:40', '2020-03-20 07:09:40');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10009, '脱发', 10006, '2020-03-20 07:09:44', '2020-03-20 07:09:44');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10010, '痤疮', 10006, '2020-03-20 07:09:50', '2020-03-20 07:09:50');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10011, '性病', 10006, '2020-03-20 07:09:59', '2020-03-20 07:09:59');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10012, '湿疹', 10006, '2020-03-20 07:10:06', '2020-03-20 07:10:06');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10013, '红斑狼疮', 10006, '2020-03-20 07:10:21', '2020-03-20 07:10:21');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10014, '妇科门诊', 10000, '2020-03-23 03:59:12', '2020-03-23 03:59:12');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10015, '普通眼科门诊', 10009, '2020-03-29 04:56:35', '2020-03-29 04:56:35');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10016, '近视眼', 10009, '2020-03-29 04:56:44', '2020-03-29 04:56:44');
INSERT INTO hospital.hospital_outpatient(id, name, special_id, gmt_create, gmt_modified)
VALUES (10017, '青光眼', 10009, '2020-03-29 04:56:53', '2020-03-29 04:56:53');

INSERT INTO hospital.hospital_special_relation(id, hospital_id, special_id, gmt_create, gmt_modified)
VALUES (4, 1000, 10008, '2020-03-20 08:38:59', '2020-03-20 08:38:59');
INSERT INTO hospital.hospital_special_relation(id, hospital_id, special_id, gmt_create, gmt_modified)
VALUES (5, 1000, 10000, '2020-03-20 09:01:10', '2020-03-20 09:01:10');
INSERT INTO hospital.hospital_special_relation(id, hospital_id, special_id, gmt_create, gmt_modified)
VALUES (6, 1001, 10000, '2020-03-20 09:04:41', '2020-03-20 09:04:41');
INSERT INTO hospital.hospital_special_relation(id, hospital_id, special_id, gmt_create, gmt_modified)
VALUES (8, 1000, 10006, '2020-03-29 04:42:18', '2020-03-29 04:42:18');
INSERT INTO hospital.hospital_special_relation(id, hospital_id, special_id, gmt_create, gmt_modified)
VALUES (9, 1001, 10009, '2020-03-29 04:43:33', '2020-03-29 04:43:33');
INSERT INTO hospital.hospital_special_relation(id, hospital_id, special_id, gmt_create, gmt_modified)
VALUES (10, 1001, 10010, '2020-03-29 04:43:36', '2020-03-29 04:43:36');
INSERT INTO hospital.hospital_special_relation(id, hospital_id, special_id, gmt_create, gmt_modified)
VALUES (11, 1002, 10008, '2020-03-29 04:43:45', '2020-03-29 04:43:45');
INSERT INTO hospital.hospital_special_relation(id, hospital_id, special_id, gmt_create, gmt_modified)
VALUES (12, 1002, 10010, '2020-03-29 04:43:49', '2020-03-29 04:43:49');

INSERT INTO hospital.hospital_outpatient_relation(id, hospital_id, outpatient_id, gmt_create, gmt_modified)
VALUES (7, 1000, 10009, '2020-03-29 04:45:32', '2020-03-29 04:45:32');
INSERT INTO hospital.hospital_outpatient_relation(id, hospital_id, outpatient_id, gmt_create, gmt_modified)
VALUES (8, 1000, 10010, '2020-03-29 04:45:37', '2020-03-29 04:45:37');
INSERT INTO hospital.hospital_outpatient_relation(id, hospital_id, outpatient_id, gmt_create, gmt_modified)
VALUES (9, 1000, 10005, '2020-03-29 05:01:46', '2020-03-29 05:01:46');
INSERT INTO hospital.hospital_outpatient_relation(id, hospital_id, outpatient_id, gmt_create, gmt_modified)
VALUES (10, 1000, 10006, '2020-03-29 05:01:49', '2020-03-29 05:01:49');
INSERT INTO hospital.hospital_outpatient_relation(id, hospital_id, outpatient_id, gmt_create, gmt_modified)
VALUES (11, 1000, 10007, '2020-03-29 05:01:51', '2020-03-29 05:01:51');
INSERT INTO hospital.hospital_outpatient_relation(id, hospital_id, outpatient_id, gmt_create, gmt_modified)
VALUES (12, 1000, 10014, '2020-03-29 05:01:54', '2020-03-29 05:01:54');
INSERT INTO hospital.hospital_outpatient_relation(id, hospital_id, outpatient_id, gmt_create, gmt_modified)
VALUES (13, 1000, 10002, '2020-03-29 05:08:29', '2020-03-29 05:08:29');
INSERT INTO hospital.hospital_outpatient_relation(id, hospital_id, outpatient_id, gmt_create, gmt_modified)
VALUES (14, 1000, 10003, '2020-03-29 05:08:32', '2020-03-29 05:08:32');
INSERT INTO hospital.hospital_outpatient_relation(id, hospital_id, outpatient_id, gmt_create, gmt_modified)
VALUES (15, 1001, 10005, '2020-03-31 10:18:28', '2020-03-31 10:18:28');
INSERT INTO hospital.hospital_outpatient_relation(id, hospital_id, outpatient_id, gmt_create, gmt_modified)
VALUES (16, 1001, 10006, '2020-03-31 10:19:20', '2020-03-31 10:19:20');

-- PostgreSQL sequence synchronization
SELECT setval(pg_get_serial_sequence('hospital_clinic', 'id'), COALESCE((SELECT MAX(id) FROM hospital_clinic), 1));
SELECT setval(pg_get_serial_sequence('hospital_doctor', 'id'), COALESCE((SELECT MAX(id) FROM hospital_doctor), 1));
SELECT setval(pg_get_serial_sequence('hospital_info', 'id'), COALESCE((SELECT MAX(id) FROM hospital_info), 1));
SELECT setval(pg_get_serial_sequence('hospital_outpatient', 'id'), COALESCE((SELECT MAX(id) FROM hospital_outpatient), 1));
SELECT setval(pg_get_serial_sequence('hospital_outpatient_relation', 'id'), COALESCE((SELECT MAX(id) FROM hospital_outpatient_relation), 1));
SELECT setval(pg_get_serial_sequence('hospital_special', 'id'), COALESCE((SELECT MAX(id) FROM hospital_special), 1));
SELECT setval(pg_get_serial_sequence('hospital_special_relation', 'id'), COALESCE((SELECT MAX(id) FROM hospital_special_relation), 1));
SELECT setval(pg_get_serial_sequence('log_account_login', 'id'), COALESCE((SELECT MAX(id) FROM log_account_login), 1));
SELECT setval(pg_get_serial_sequence('log_operation', 'id'), COALESCE((SELECT MAX(id) FROM log_operation), 1));
SELECT setval(pg_get_serial_sequence('power_account', 'id'), COALESCE((SELECT MAX(id) FROM power_account), 1));
SELECT setval(pg_get_serial_sequence('power_account_role_relation', 'id'), COALESCE((SELECT MAX(id) FROM power_account_role_relation), 1));
SELECT setval(pg_get_serial_sequence('power_menu', 'id'), COALESCE((SELECT MAX(id) FROM power_menu), 1));
SELECT setval(pg_get_serial_sequence('power_resource', 'id'), COALESCE((SELECT MAX(id) FROM power_resource), 1));
SELECT setval(pg_get_serial_sequence('power_resource_category', 'id'), COALESCE((SELECT MAX(id) FROM power_resource_category), 1));
SELECT setval(pg_get_serial_sequence('power_role', 'id'), COALESCE((SELECT MAX(id) FROM power_role), 1));
SELECT setval(pg_get_serial_sequence('power_role_menu_relation', 'id'), COALESCE((SELECT MAX(id) FROM power_role_menu_relation), 1));
SELECT setval(pg_get_serial_sequence('power_role_resource_relation', 'id'), COALESCE((SELECT MAX(id) FROM power_role_resource_relation), 1));
SELECT setval(pg_get_serial_sequence('user_basic_info', 'id'), COALESCE((SELECT MAX(id) FROM user_basic_info), 1));
SELECT setval(pg_get_serial_sequence('user_case', 'id'), COALESCE((SELECT MAX(id) FROM user_case), 1));
SELECT setval(pg_get_serial_sequence('user_medical_card', 'id'), COALESCE((SELECT MAX(id) FROM user_medical_card), 1));
SELECT setval(pg_get_serial_sequence('user_medical_card_relation', 'id'), COALESCE((SELECT MAX(id) FROM user_medical_card_relation), 1));
SELECT setval(pg_get_serial_sequence('visit_appointment', 'id'), COALESCE((SELECT MAX(id) FROM visit_appointment), 1));
SELECT setval(pg_get_serial_sequence('visit_blacklist', 'id'), COALESCE((SELECT MAX(id) FROM visit_blacklist), 1));
SELECT setval(pg_get_serial_sequence('visit_plan', 'id'), COALESCE((SELECT MAX(id) FROM visit_plan), 1));
