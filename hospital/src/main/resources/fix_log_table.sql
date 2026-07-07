-- PostgreSQL script aligned with the medical imaging platform document.
-- Structured data: PostgreSQL. Queue/cache: Redis. Binary assets: MinIO/NAS via URI columns.

-- 修复 log_account_login 表结构
DROP TABLE IF EXISTS log_account_login CASCADE;
CREATE TABLE log_account_login
(
    id           bigserial NOT NULL,
    account_id   bigint NULL DEFAULT NULL,
    account_name varchar(64) NOT NULL,
    ip_address   varchar(64) NULL DEFAULT NULL,
    gmt_create   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- 修复 log_operation 表结构
DROP TABLE IF EXISTS log_operation CASCADE;
CREATE TABLE log_operation
(
    id           bigserial NOT NULL,
    account_id   bigint NULL DEFAULT NULL,
    account_name varchar(64) NULL DEFAULT NULL,
    operation    varchar(64) NOT NULL,
    description  varchar(255) NULL DEFAULT NULL,
    ip_address   varchar(64) NULL DEFAULT NULL,
    gmt_create   timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gmt_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

-- PostgreSQL sequence synchronization
SELECT setval(pg_get_serial_sequence('log_account_login', 'id'), COALESCE((SELECT MAX(id) FROM log_account_login), 1));
SELECT setval(pg_get_serial_sequence('log_operation', 'id'), COALESCE((SELECT MAX(id) FROM log_operation), 1));
