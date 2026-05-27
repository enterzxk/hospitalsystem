-- 修复 log_account_login 表结构
DROP TABLE IF EXISTS `log_account_login`;
CREATE TABLE `log_account_login`
(
    `id`           bigint(20) NOT NULL AUTO_INCREMENT COMMENT '日志编号',
    `account_id`   bigint(20) NULL DEFAULT NULL COMMENT '账号编号',
    `account_name` varchar(64) NOT NULL COMMENT '登录账号',
    `ip_address`   varchar(64) NULL DEFAULT NULL COMMENT '登录IP',
    `gmt_create`   datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '登录日志表' ROW_FORMAT = Dynamic;

-- 修复 log_operation 表结构（匹配 mapper XML）
DROP TABLE IF EXISTS `log_operation`;
CREATE TABLE `log_operation`
(
    `id`           bigint(20) NOT NULL AUTO_INCREMENT COMMENT '日志编号',
    `account_name` varchar(64) NULL DEFAULT NULL COMMENT '操作账号',
    `start_time`   bigint(20) NULL DEFAULT NULL COMMENT '开始时间',
    `spend_time`   int(11) NULL DEFAULT NULL COMMENT '花费时间',
    `description`  varchar(255) NULL DEFAULT NULL COMMENT '操作描述',
    `base_path`    varchar(255) NULL DEFAULT NULL COMMENT '基础路径',
    `uri`          varchar(255) NULL DEFAULT NULL COMMENT '请求URI',
    `url`          varchar(255) NULL DEFAULT NULL COMMENT '请求URL',
    `method`       varchar(10) NULL DEFAULT NULL COMMENT '请求方法',
    `ip_address`   varchar(64) NULL DEFAULT NULL COMMENT '操作IP',
    `parameter`    text NULL COMMENT '请求参数',
    `result`       text NULL COMMENT '返回结果',
    `gmt_create`   datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '操作日志表' ROW_FORMAT = Dynamic;
