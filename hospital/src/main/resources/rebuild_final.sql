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
