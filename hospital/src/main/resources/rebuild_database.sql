-- =====================================================
-- 使用正确的 hospital.sql 重建数据库
-- =====================================================

-- 先删除数据库（如果存在）
DROP DATABASE IF EXISTS `hospital`;

-- 重新创建数据库
CREATE DATABASE `hospital` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- 使用数据库
USE `hospital`;

-- 禁用外键检查
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- 以下内容来自 hospital.sql（与代码匹配的正确版本）
-- =====================================================

-- ----------------------------
-- 菜单表
-- ----------------------------
DROP TABLE IF EXISTS `power_menu`;
CREATE TABLE `power_menu`
(
    `id`          bigint(20)                                                   NOT NULL AUTO_INCREMENT COMMENT '菜单编号',
    `parent_id`   bigint(20)                                                   NULL DEFAULT 0 COMMENT '父菜单编号',
    `create_time` datetime(0)                                                  NULL DEFAULT NULL COMMENT '创建时间',
    `title`       varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '菜单名称',
    `level`       int(11)                                                      NOT NULL DEFAULT 0 COMMENT '菜单层级',
    `sort`        int(11)                                                      NOT NULL DEFAULT 0 COMMENT '排序 越小越靠前',
    `name`        varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '前端路由名称',
    `icon`        varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '前端图标',
    `hidden`      int(11)                                                      NOT NULL DEFAULT 1 COMMENT '前端是否隐藏 1：隐藏；0：显示',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 22
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '后台菜单表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 资源表
-- ----------------------------
DROP TABLE IF EXISTS `power_resource`;
CREATE TABLE `power_resource`
(
    `id`           bigint(20)                                                   NOT NULL AUTO_INCREMENT COMMENT '资源编号',
    `category_id`  bigint(20)                                                   NOT NULL COMMENT '资源分类编号',
    `name`         varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '资源名称',
    `url`          varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '资源URL',
    `description`  varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '资源描述',
    `gmt_create`   datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `power_resource_url_uindex` (`url`) USING BTREE,
    UNIQUE INDEX `power_resource_name_uindex` (`name`) USING BTREE,
    INDEX `power_resource_power_resource_category_id_fk` (`category_id`) USING BTREE,
    CONSTRAINT `power_resource_power_resource_category_id_fk` FOREIGN KEY (`category_id`) REFERENCES `power_resource_category` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10000
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '后台资源表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 资源分类表
-- ----------------------------
DROP TABLE IF EXISTS `power_resource_category`;
CREATE TABLE `power_resource_category`
(
    `id`           bigint(20)                                                   NOT NULL AUTO_INCREMENT COMMENT '分类编号',
    `name`         varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分类名称',
    `sort`         int(11)                                                      NOT NULL DEFAULT 1 COMMENT '分类排序 数值越小，越靠前',
    `gmt_create`   datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `power_resource_category_name_uindex` (`name`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10000
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '权限资源分类表 '
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 角色表
-- ----------------------------
DROP TABLE IF EXISTS `power_role`;
CREATE TABLE `power_role`
(
    `id`           bigint(20)                                                   NOT NULL AUTO_INCREMENT COMMENT '角色编号',
    `name`         varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '英文名称',
    `chinese_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '中文名称',
    `admin_count`  int(11)                                                      NOT NULL DEFAULT 0 COMMENT '用户数目',
    `sort`         int(11)                                                      NOT NULL DEFAULT 0 COMMENT '排序 越小越靠前',
    `status`       int(11)                                                      NOT NULL DEFAULT 1 COMMENT '角色状态 1：启用，0：禁用',
    `gmt_create`   datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `power_role_name_uindex` (`name`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 5
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '权限角色表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 账号信息表
-- ----------------------------
DROP TABLE IF EXISTS `power_account`;
CREATE TABLE `power_account`
(
    `id`           bigint(20)                                                    NOT NULL AUTO_INCREMENT COMMENT '编号',
    `name`         varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '登录账号 唯一',
    `password`     varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录密码 使用md5加密',
    `status`       int(11)                                                       NOT NULL DEFAULT 1 COMMENT '账号状态 1：正常，0：锁定',
    `login_time`   datetime(0)                                                   NULL     DEFAULT NULL COMMENT '最后登录时间',
    `gmt_create`   datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `power_account_name_uindex` (`name`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10000004
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '账号信息表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 账号角色关系表
-- ----------------------------
DROP TABLE IF EXISTS `power_account_role_relation`;
CREATE TABLE `power_account_role_relation`
(
    `id`           bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '账号角色关系编号',
    `account_id`   bigint(20)  NOT NULL COMMENT '账号编号',
    `role_id`      bigint(20)  NOT NULL COMMENT '角色编号',
    `gmt_create`   datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `power_account_role_relation_power_role_id_fk` (`role_id`) USING BTREE,
    INDEX `power_account_role_relation_power_account_id_fk` (`account_id`) USING BTREE,
    CONSTRAINT `power_account_role_relation_power_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `power_account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `power_account_role_relation_power_role_id_fk` FOREIGN KEY (`role_id`) REFERENCES `power_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 2
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '账号角色关系表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 角色菜单关系表
-- ----------------------------
DROP TABLE IF EXISTS `power_role_menu_relation`;
CREATE TABLE `power_role_menu_relation`
(
    `id`          bigint(20) NOT NULL AUTO_INCREMENT COMMENT '关系编号',
    `role_id`     bigint(20) NOT NULL COMMENT '角色编号',
    `menu_id`     bigint(20) NOT NULL COMMENT '菜单编号',
    `gmt_create`  datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `power_role_menu_relation_power_role_id_fk` (`role_id`) USING BTREE,
    INDEX `power_role_menu_relation_power_menu_id_fk` (`menu_id`) USING BTREE,
    CONSTRAINT `power_role_menu_relation_power_role_id_fk` FOREIGN KEY (`role_id`) REFERENCES `power_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `power_role_menu_relation_power_menu_id_fk` FOREIGN KEY (`menu_id`) REFERENCES `power_menu` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10013
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '角色菜单关系表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 角色资源关系表
-- ----------------------------
DROP TABLE IF EXISTS `power_role_resource_relation`;
CREATE TABLE `power_role_resource_relation`
(
    `id`          bigint(20) NOT NULL AUTO_INCREMENT COMMENT '关系编号',
    `role_id`     bigint(20) NOT NULL COMMENT '角色编号',
    `resource_id` bigint(20) NOT NULL COMMENT '资源编号',
    `gmt_create`  datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `power_role_resource_relation_power_role_id_fk` (`role_id`) USING BTREE,
    INDEX `power_role_resource_relation_power_resource_id_fk` (`resource_id`) USING BTREE,
    CONSTRAINT `power_role_resource_relation_power_role_id_fk` FOREIGN KEY (`role_id`) REFERENCES `power_role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `power_role_resource_relation_power_resource_id_fk` FOREIGN KEY (`resource_id`) REFERENCES `power_resource` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10013
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '角色资源关系表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 医院信息表
-- ----------------------------
DROP TABLE IF EXISTS `hospital_info`;
CREATE TABLE `hospital_info`
(
    `id`           bigint(20)                                                    NOT NULL AUTO_INCREMENT COMMENT '医院编号',
    `name`         varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '医院名称',
    `phone`        varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '医院电话',
    `address`      varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '医院地址',
    `description`  varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '医院描述',
    `picture`      varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '医院图片',
    `gmt_create`   datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10003
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '医院信息表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 医院科室表
-- ----------------------------
DROP TABLE IF EXISTS `hospital_special`;
CREATE TABLE `hospital_special`
(
    `id`           bigint(20)                                                    NOT NULL AUTO_INCREMENT COMMENT '科室编号',
    `hospital_id`  bigint(20)                                                    NOT NULL COMMENT '所属医院',
    `name`         varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '科室名称',
    `icon`         varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '科室图标',
    `description`  varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '科室描述',
    `sort`         int(11)                                                       NOT NULL DEFAULT 0 COMMENT '排序 越小越靠前',
    `status`       int(11)                                                       NOT NULL DEFAULT 1 COMMENT '科室状态 1：启用，0：禁用',
    `gmt_create`   datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `hospital_special_hospital_info_id_fk` (`hospital_id`) USING BTREE,
    CONSTRAINT `hospital_special_hospital_info_id_fk` FOREIGN KEY (`hospital_id`) REFERENCES `hospital_info` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10010
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '医院科室表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 医生信息表
-- ----------------------------
DROP TABLE IF EXISTS `hospital_doctor`;
CREATE TABLE `hospital_doctor`
(
    `id`              bigint(20)                                                    NOT NULL AUTO_INCREMENT COMMENT '医生编号',
    `account_id`      bigint(20)                                                    NULL     DEFAULT NULL COMMENT '关联账号',
    `hospital_id`     bigint(20)                                                    NOT NULL COMMENT '所属医院',
    `special_id`      bigint(20)                                                    NULL     DEFAULT NULL COMMENT '所属科室',
    `name`            varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '医生名称',
    `professional`    varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '职称',
    `hospital_name`   varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '所属医院名称',
    `special_name`    varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '所属科室名称',
    `expertise`       varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '擅长',
    `picture`         varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '医生头像',
    `pinyin`          varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '名称拼音',
    `good_rate`       int(11)                                                       NULL     DEFAULT 100 COMMENT '好评率',
    `service_count`   int(11)                                                       NULL     DEFAULT 0 COMMENT '服务人次',
    `sort`            int(11)                                                       NOT NULL DEFAULT 0 COMMENT '排序 越小越靠前',
    `status`          int(11)                                                       NOT NULL DEFAULT 1 COMMENT '账号状态 1：正常，0：锁定',
    `gmt_create`      datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified`    datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `hospital_doctor_hospital_info_id_fk` (`hospital_id`) USING BTREE,
    INDEX `hospital_doctor_hospital_special_id_fk` (`special_id`) USING BTREE,
    CONSTRAINT `hospital_doctor_hospital_info_id_fk` FOREIGN KEY (`hospital_id`) REFERENCES `hospital_info` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `hospital_doctor_hospital_special_id_fk` FOREIGN KEY (`special_id`) REFERENCES `hospital_special` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10015
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '医院医生表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 门诊信息表
-- ----------------------------
DROP TABLE IF EXISTS `hospital_outpatient`;
CREATE TABLE `hospital_outpatient`
(
    `id`           bigint(20)                                                    NOT NULL AUTO_INCREMENT COMMENT '门诊编号',
    `hospital_id`  bigint(20)                                                    NOT NULL COMMENT '所属医院',
    `name`         varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '门诊名称',
    `phone`        varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '门诊电话',
    `address`      varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '门诊地址',
    `description`  varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '门诊描述',
    `picture`      varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '门诊图片',
    `status`       int(11)                                                       NOT NULL DEFAULT 1 COMMENT '账号状态 1：正常，0：锁定',
    `gmt_create`   datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `hospital_outpatient_hospital_info_id_fk` (`hospital_id`) USING BTREE,
    CONSTRAINT `hospital_outpatient_hospital_info_id_fk` FOREIGN KEY (`hospital_id`) REFERENCES `hospital_info` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10004
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '门诊信息表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 诊室信息表
-- ----------------------------
DROP TABLE IF EXISTS `hospital_clinic`;
CREATE TABLE `hospital_clinic`
(
    `id`             bigint(20)                                                    NOT NULL AUTO_INCREMENT COMMENT '诊室编号',
    `outpatient_id`  bigint(20)                                                    NOT NULL COMMENT '所属门诊',
    `name`           varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '诊室名称',
    `address`        varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '诊室地址',
    `status`         int(11)                                                       NOT NULL DEFAULT 1 COMMENT '诊室状态 1：正常，0：锁定',
    `gmt_create`     datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified`   datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `hospital_clinic_hospital_outpatient_id_fk` (`outpatient_id`) USING BTREE,
    CONSTRAINT `hospital_clinic_hospital_outpatient_id_fk` FOREIGN KEY (`outpatient_id`) REFERENCES `hospital_outpatient` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10004
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '诊室信息表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 出诊信息表
-- ----------------------------
DROP TABLE IF EXISTS `visit_plan`;
CREATE TABLE `visit_plan`
(
    `id`            bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '出诊编号',
    `hospital_id`   bigint(20)  NOT NULL COMMENT '医院编号',
    `special_id`    bigint(20)  NOT NULL COMMENT '专科编号',
    `outpatient_id` bigint(20)  NOT NULL COMMENT '门诊编号',
    `clinic_id`     bigint(20)  NOT NULL COMMENT '诊室编号',
    `doctor_id`     bigint(20)  NOT NULL COMMENT '医生编号',
    `time`          int(11)     NOT NULL DEFAULT 1 COMMENT '时间段 1：上午，2：下午',
    `day`           datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '出诊日期',
    `gmt_create`    datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified`  datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `visit_plan_hospital_clinic_id_fk` (`clinic_id`) USING BTREE,
    INDEX `visit_plan_hospital_doctor_id_fk` (`doctor_id`) USING BTREE,
    INDEX `visit_plan_hospital_info_id_fk` (`hospital_id`) USING BTREE,
    INDEX `visit_plan_hospital_special_id_fk` (`special_id`) USING BTREE,
    INDEX `visit_plan_hospital_outpatient_id_fk` (`outpatient_id`) USING BTREE,
    CONSTRAINT `visit_plan_hospital_clinic_id_fk` FOREIGN KEY (`clinic_id`) REFERENCES `hospital_clinic` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `visit_plan_hospital_doctor_id_fk` FOREIGN KEY (`doctor_id`) REFERENCES `hospital_doctor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `visit_plan_hospital_info_id_fk` FOREIGN KEY (`hospital_id`) REFERENCES `hospital_info` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `visit_plan_hospital_outpatient_id_fk` FOREIGN KEY (`outpatient_id`) REFERENCES `hospital_outpatient` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `visit_plan_hospital_special_id_fk` FOREIGN KEY (`special_id`) REFERENCES `hospital_special` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10042
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '出诊信息表 '
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 患者就诊卡表
-- ----------------------------
DROP TABLE IF EXISTS `user_medical_card`;
CREATE TABLE `user_medical_card`
(
    `id`           bigint(20)                                                    NOT NULL AUTO_INCREMENT COMMENT '就诊卡编号',
    `account_id`   bigint(20)                                                    NOT NULL COMMENT '关联账号',
    `real_name`    varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '真实姓名',
    `id_card`      varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '身份证号码',
    `phone`        varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '手机号码',
    `gender`       int(11)                                                       NOT NULL DEFAULT 1 COMMENT '性别 1：男，2：女',
    `birthday`     datetime(0)                                                   NULL     DEFAULT NULL COMMENT '出生日期',
    `gmt_create`   datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `user_medical_card_power_account_id_fk` (`account_id`) USING BTREE,
    CONSTRAINT `user_medical_card_power_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `power_account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10006
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '患者就诊卡表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 用户基本信息表
-- ----------------------------
DROP TABLE IF EXISTS `user_basic_info`;
CREATE TABLE `user_basic_info`
(
    `id`           bigint(20)                                                    NOT NULL AUTO_INCREMENT COMMENT '用户编号',
    `account_id`   bigint(20)                                                    NOT NULL COMMENT '关联账号',
    `name`         varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '用户昵称',
    `icon`         varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '用户头像',
    `gender`       int(11)                                                       NOT NULL DEFAULT 1 COMMENT '性别 1：男，2：女',
    `age`          int(11)                                                       NULL     DEFAULT NULL COMMENT '年龄',
    `phone`        varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '手机号',
    `gmt_create`   datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `user_basic_info_power_account_id_fk` (`account_id`) USING BTREE,
    CONSTRAINT `user_basic_info_power_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `power_account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10004
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '用户基本信息表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 用户病案表
-- ----------------------------
DROP TABLE IF EXISTS `user_case`;
CREATE TABLE `user_case`
(
    `id`             bigint(20)                                                    NOT NULL AUTO_INCREMENT COMMENT '病案编号',
    `account_id`     bigint(20)                                                    NOT NULL COMMENT '关联账号',
    `medical_id`     bigint(20)                                                    NOT NULL COMMENT '就诊卡编号',
    `real_name`      varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '真实姓名',
    `id_card`        varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '身份证号码',
    `phone`          varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '手机号码',
    `gender`         int(11)                                                       NOT NULL DEFAULT 1 COMMENT '性别 1：男，2：女',
    `birthday`       datetime(0)                                                   NULL     DEFAULT NULL COMMENT '出生日期',
    `blood_type`     varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '血型',
    `allergy_history` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '过敏史',
    `gmt_create`     datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified`   datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `user_case_power_account_id_fk` (`account_id`) USING BTREE,
    INDEX `user_case_user_medical_card_id_fk` (`medical_id`) USING BTREE,
    CONSTRAINT `user_case_power_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `power_account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `user_case_user_medical_card_id_fk` FOREIGN KEY (`medical_id`) REFERENCES `user_medical_card` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10003
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '用户病案表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 就诊卡关系表
-- ----------------------------
DROP TABLE IF EXISTS `user_medical_card_relation`;
CREATE TABLE `user_medical_card_relation`
(
    `id`             bigint(20) NOT NULL AUTO_INCREMENT COMMENT '关系编号',
    `account_id`     bigint(20) NOT NULL COMMENT '账号编号',
    `medical_id`     bigint(20) NOT NULL COMMENT '就诊卡编号',
    `is_default`     int(11)    NOT NULL DEFAULT 0 COMMENT '是否默认 1：是，0：否',
    `gmt_create`     datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified`   datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `user_medical_card_relation_user_medical_card_id_fk` (`medical_id`) USING BTREE,
    INDEX `user_medical_card_relation_power_account_id_fk` (`account_id`) USING BTREE,
    CONSTRAINT `user_medical_card_relation_power_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `power_account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `user_medical_card_relation_user_medical_card_id_fk` FOREIGN KEY (`medical_id`) REFERENCES `user_medical_card` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10005
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '用户与就诊卡关系表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 预约挂号表
-- ----------------------------
DROP TABLE IF EXISTS `visit_appointment`;
CREATE TABLE `visit_appointment`
(
    `id`              bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '预约编号',
    `account_id`      bigint(20)  NOT NULL COMMENT '用户账号',
    `medical_id`      bigint(20)  NULL     DEFAULT NULL COMMENT '就诊卡编号',
    `plan_id`         bigint(20)  NOT NULL COMMENT '出诊编号',
    `real_name`       varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '真实姓名',
    `id_card`         varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '身份证号码',
    `phone`           varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '手机号码',
    `appointment_status` int(11) NOT NULL DEFAULT 1 COMMENT '预约状态 1：待就诊，2：已就诊，3：爽约，4：已取消',
    `is_system`       int(11)     NOT NULL DEFAULT 0 COMMENT '是否系统预约 1：是，0：否',
    `gmt_create`      datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified`    datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `visit_appointment_visit_plan_id_fk` (`plan_id`) USING BTREE,
    INDEX `visit_appointment_power_account_id_fk` (`account_id`) USING BTREE,
    INDEX `visit_appointment_user_medical_card_id_fk` (`medical_id`) USING BTREE,
    CONSTRAINT `visit_appointment_power_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `power_account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `visit_appointment_user_medical_card_id_fk` FOREIGN KEY (`medical_id`) REFERENCES `user_medical_card` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `visit_appointment_visit_plan_id_fk` FOREIGN KEY (`plan_id`) REFERENCES `visit_plan` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10010
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '预约挂号表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 黑名单表
-- ----------------------------
DROP TABLE IF EXISTS `visit_blacklist`;
CREATE TABLE `visit_blacklist`
(
    `id`             bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '黑名单编号',
    `account_id`     bigint(20)  NOT NULL COMMENT '用户账号',
    `medical_id`     bigint(20)  NOT NULL COMMENT '就诊卡编号',
    `real_name`      varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '真实姓名',
    `id_card`        varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '身份证号码',
    `phone`          varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '手机号码',
    `appointment_count` int(11)  NOT NULL DEFAULT 0 COMMENT '爽约次数',
    `reason`         varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '拉黑原因',
    `gmt_create`     datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified`   datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `visit_blacklist_visit_plan_id_fk` (`medical_id`) USING BTREE,
    INDEX `visit_blacklist_power_account_id_fk` (`account_id`) USING BTREE,
    CONSTRAINT `visit_blacklist_power_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `power_account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `visit_blacklist_user_medical_card_id_fk` FOREIGN KEY (`medical_id`) REFERENCES `user_medical_card` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10004
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '黑名单表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 操作日志表
-- ----------------------------
DROP TABLE IF EXISTS `log_operation`;
CREATE TABLE `log_operation`
(
    `id`          bigint(20)                                                    NOT NULL AUTO_INCREMENT COMMENT '日志编号',
    `name`        varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '操作名称',
    `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '操作描述',
    `ip`          varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '操作IP',
    `account`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '操作账号',
    `gmt_create`  datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10000023
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '操作日志表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 登录日志表
-- ----------------------------
DROP TABLE IF EXISTS `log_account_login`;
CREATE TABLE `log_account_login`
(
    `id`          bigint(20)                                                    NOT NULL AUTO_INCREMENT COMMENT '日志编号',
    `ip`          varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NULL     DEFAULT NULL COMMENT '登录IP',
    `account`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '登录账号',
    `gmt_create`  datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10000041
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '登录日志表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 门诊关系表
-- ----------------------------
DROP TABLE IF EXISTS `hospital_outpatient_relation`;
CREATE TABLE `hospital_outpatient_relation`
(
    `id`            bigint(20) NOT NULL AUTO_INCREMENT COMMENT '关系编号',
    `outpatient_id` bigint(20) NOT NULL COMMENT '门诊编号',
    `special_id`    bigint(20) NOT NULL COMMENT '科室编号',
    `gmt_create`    datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified`  datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `hospital_outpatient_relation_hospital_outpatient_id_fk` (`outpatient_id`) USING BTREE,
    INDEX `hospital_outpatient_relation_hospital_special_id_fk` (`special_id`) USING BTREE,
    CONSTRAINT `hospital_outpatient_relation_hospital_outpatient_id_fk` FOREIGN KEY (`outpatient_id`) REFERENCES `hospital_outpatient` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `hospital_outpatient_relation_hospital_special_id_fk` FOREIGN KEY (`special_id`) REFERENCES `hospital_special` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10008
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '门诊关系表'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- 医生关系表
-- ----------------------------
DROP TABLE IF EXISTS `hospital_special_relation`;
CREATE TABLE `hospital_special_relation`
(
    `id`           bigint(20) NOT NULL AUTO_INCREMENT COMMENT '关系编号',
    `doctor_id`    bigint(20) NOT NULL COMMENT '医生编号',
    `special_id`   bigint(20) NOT NULL COMMENT '科室编号',
    `gmt_create`   datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `hospital_special_relation_hospital_doctor_id_fk` (`doctor_id`) USING BTREE,
    INDEX `hospital_special_relation_hospital_special_id_fk` (`special_id`) USING BTREE,
    CONSTRAINT `hospital_special_relation_hospital_doctor_id_fk` FOREIGN KEY (`doctor_id`) REFERENCES `hospital_doctor` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `hospital_special_relation_hospital_special_id_fk` FOREIGN KEY (`special_id`) REFERENCES `hospital_special` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB
  AUTO_INCREMENT = 10014
  CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_general_ci COMMENT = '医生关系表'
  ROW_FORMAT = Dynamic;

-- =====================================================
-- 新增表：患者信息、影像、诊断报告等
-- =====================================================

-- 患者信息表
DROP TABLE IF EXISTS `patient_info`;
CREATE TABLE `patient_info` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '患者编号',
    `account_id` bigint(20) NULL DEFAULT NULL COMMENT '关联账号',
    `name` varchar(32) NOT NULL COMMENT '患者姓名',
    `gender` int(11) NOT NULL DEFAULT 1 COMMENT '性别：1，男；2，女',
    `phone` varchar(16) NULL DEFAULT NULL COMMENT '手机号',
    `id_card` varchar(18) NULL DEFAULT NULL COMMENT '身份证号',
    `birth_date` date NULL DEFAULT NULL COMMENT '出生日期',
    `address` varchar(128) NULL DEFAULT NULL COMMENT '地址',
    `blood_type` varchar(4) NULL DEFAULT NULL COMMENT '血型',
    `allergy_history` varchar(512) NULL DEFAULT NULL COMMENT '过敏史',
    `medical_history` varchar(512) NULL DEFAULT NULL COMMENT '病史',
    `gmt_create` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10001 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '患者信息表' ROW_FORMAT = Dynamic;

-- 影像资料表
DROP TABLE IF EXISTS `medical_imaging`;
CREATE TABLE `medical_imaging` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '影像编号',
    `patient_id` bigint(20) NOT NULL COMMENT '患者编号',
    `doctor_id` bigint(20) NOT NULL COMMENT '上传医生编号',
    `hospital_id` bigint(20) NOT NULL COMMENT '医院编号',
    `imaging_type` varchar(32) NOT NULL COMMENT '影像类型：X光、CT、MRI、B超等',
    `body_part` varchar(64) NOT NULL COMMENT '检查部位',
    `file_path` varchar(512) NOT NULL COMMENT '文件路径',
    `file_name` varchar(128) NOT NULL COMMENT '文件名',
    `file_size` bigint(20) NULL DEFAULT NULL COMMENT '文件大小(字节)',
    `description` varchar(512) NULL DEFAULT NULL COMMENT '影像描述',
    `diagnosis_status` int(11) NOT NULL DEFAULT 0 COMMENT '诊断状态：0，待诊断；1，已诊断',
    `gmt_create` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `idx_patient_id` (`patient_id`) USING BTREE,
    INDEX `idx_doctor_id` (`doctor_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10001 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '影像资料表' ROW_FORMAT = Dynamic;

-- 诊断报告表
DROP TABLE IF EXISTS `diagnosis_report`;
CREATE TABLE `diagnosis_report` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '报告编号',
    `patient_id` bigint(20) NOT NULL COMMENT '患者编号',
    `doctor_id` bigint(20) NOT NULL COMMENT '诊断医生编号',
    `hospital_id` bigint(20) NOT NULL COMMENT '医院编号',
    `special_id` bigint(20) NULL DEFAULT NULL COMMENT '专科编号',
    `report_no` varchar(32) NOT NULL COMMENT '报告编号',
    `patient_name` varchar(32) NOT NULL COMMENT '患者姓名',
    `gender` int(11) NULL DEFAULT 1 COMMENT '性别：1，男；2，女',
    `age` int(11) NULL DEFAULT NULL COMMENT '年龄',
    `id_card` varchar(18) NULL DEFAULT NULL COMMENT '身份证号',
    `phone` varchar(16) NULL DEFAULT NULL COMMENT '联系电话',
    `examination_type` varchar(32) NOT NULL COMMENT '检查类型',
    `body_part` varchar(64) NOT NULL COMMENT '检查部位',
    `clinical_diagnosis` varchar(512) NULL DEFAULT NULL COMMENT '临床诊断',
    `examination_findings` text NOT NULL COMMENT '检查所见',
    `diagnostic_opinion` text NOT NULL COMMENT '诊断意见',
    `report_status` int(11) NOT NULL DEFAULT 0 COMMENT '报告状态：0，草稿；1，已提交；2，已审核',
    `report_date` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '报告日期',
    `reviewer_id` bigint(20) NULL DEFAULT NULL COMMENT '审核医生编号',
    `review_time` datetime(0) NULL DEFAULT NULL COMMENT '审核时间',
    `review_opinion` varchar(512) NULL DEFAULT NULL COMMENT '审核意见',
    `gmt_create` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `report_no` (`report_no`) USING BTREE,
    INDEX `idx_patient_id` (`patient_id`) USING BTREE,
    INDEX `idx_doctor_id` (`doctor_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10001 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '诊断报告表' ROW_FORMAT = Dynamic;

-- 报告影像关联表
DROP TABLE IF EXISTS `report_imaging_relation`;
CREATE TABLE `report_imaging_relation` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '关系编号',
    `report_id` bigint(20) NOT NULL COMMENT '报告编号',
    `imaging_id` bigint(20) NOT NULL COMMENT '影像编号',
    `gmt_create` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `uk_report_imaging` (`report_id`, `imaging_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '报告影像关联表' ROW_FORMAT = Dynamic;

-- 就诊记录表
DROP TABLE IF EXISTS `visit_record`;
CREATE TABLE `visit_record` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '就诊编号',
    `patient_id` bigint(20) NOT NULL COMMENT '患者编号',
    `doctor_id` bigint(20) NOT NULL COMMENT '医生编号',
    `hospital_id` bigint(20) NOT NULL COMMENT '医院编号',
    `special_id` bigint(20) NULL DEFAULT NULL COMMENT '专科编号',
    `outpatient_id` bigint(20) NULL DEFAULT NULL COMMENT '门诊编号',
    `visit_date` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '就诊日期',
    `symptoms` varchar(512) NULL DEFAULT NULL COMMENT '症状描述',
    `diagnosis` varchar(512) NULL DEFAULT NULL COMMENT '初步诊断',
    `treatment_plan` varchar(512) NULL DEFAULT NULL COMMENT '治疗方案',
    `prescription` text NULL COMMENT '处方',
    `visit_status` int(11) NOT NULL DEFAULT 0 COMMENT '就诊状态：0，候诊中；1，就诊中；2，已完成',
    `gmt_create` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `gmt_modified` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `idx_patient_id` (`patient_id`) USING BTREE,
    INDEX `idx_doctor_id` (`doctor_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10001 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '就诊记录表' ROW_FORMAT = Dynamic;

-- 影像标注表
DROP TABLE IF EXISTS `imaging_annotation`;
CREATE TABLE `imaging_annotation` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '标注编号',
    `imaging_id` bigint(20) NOT NULL COMMENT '影像编号',
    `doctor_id` bigint(20) NOT NULL COMMENT '标注医生编号',
    `annotation_type` varchar(32) NOT NULL COMMENT '标注类型：point/rect/freehand/brush',
    `annotation_data` text NOT NULL COMMENT '标注数据(JSON)',
    `label` varchar(64) NULL DEFAULT NULL COMMENT '标注标签',
    `color` varchar(16) NULL DEFAULT '#FF0000' COMMENT '标注颜色',
    `gmt_create` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    PRIMARY KEY (`id`) USING BTREE,
    INDEX `idx_imaging_id` (`imaging_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10001 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '影像标注表' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================
-- 初始化数据
-- =====================================================

-- 初始化角色
INSERT INTO `power_role` (`id`, `name`, `chinese_name`, `admin_count`, `sort`, `status`, `gmt_create`, `gmt_modified`) VALUES
(1, 'admin', '系统管理员', 0, 1, 1, NOW(), NOW()),
(2, 'doctor', '医生', 0, 2, 1, NOW(), NOW()),
(3, 'patient', '患者', 0, 3, 1, NOW(), NOW()),
(4, 'radiologist', '放射科医生', 0, 4, 1, NOW(), NOW());

-- 初始化测试账号
INSERT INTO `power_account` (`id`, `name`, `password`, `status`, `login_time`, `gmt_create`, `gmt_modified`) VALUES
(1000, 'admin', '$2a$10$PmoMm5QCsVEddE3yw1F/aez3a/0slKfgA8i/ydTsgHeuI6t9v93gW', 1, NULL, NOW(), NOW()),
(1001, 'doctor1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1002, 'doctor2', '$2a$10$e5kPah/Adaf59rhYv8UUpuydluURQ2jlV3WxDEDs2bsMgzJpxmt1u', 1, NULL, NOW(), NOW()),
(1003, 'patient1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1004, 'patient2', '$2a$10$Ah0XaOc/uEDQjvWzySygieTRfHuzHcv1NCTebrtNfu.uS4b/Av6SS', 1, NULL, NOW(), NOW()),
(1005, 'doctor3', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1006, 'patient3', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1007, 'patient4', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW()),
(1008, 'radiologist1', '$2a$10$Y8JczZW5a8R0ajygnhNYHO3wbrtNChG8Np7otitAMn0g43p5UT9ZC', 1, NULL, NOW(), NOW());

-- 初始化账号角色关联
INSERT INTO `power_account_role_relation` (`account_id`, `role_id`, `gmt_create`, `gmt_modified`) VALUES
(1000, 1, NOW(), NOW()),
(1001, 2, NOW(), NOW()),
(1002, 2, NOW(), NOW()),
(1005, 2, NOW(), NOW()),
(1003, 3, NOW(), NOW()),
(1004, 3, NOW(), NOW()),
(1006, 3, NOW(), NOW()),
(1007, 3, NOW(), NOW()),
(1008, 4, NOW(), NOW());

-- 初始化医院信息
INSERT INTO `hospital_info` (`id`, `name`, `phone`, `address`, `description`, `picture`, `gmt_create`, `gmt_modified`) VALUES
(1000, '云岚宗医院', '0571-8808-6677', '云岚市青澜区云岚宗大道88号', '云岚宗医院是一所虚构的现代化综合医疗中心，提供门诊、住院、影像诊断、报告查询和慢病随访服务。', NULL, NOW(), NOW()),
(1001, '云岚宗医院城北院区', '0571-8808-6688', '云岚市北杉区清溪路66号', '云岚宗医院城北院区聚焦康复医学、慢病管理和社区连续照护。', NULL, NOW(), NOW()),
(1002, '云岚宗医院临研中心', '0571-8808-6699', '云岚市青澜区知行路18号', '云岚宗医院临研中心负责临床研究、医学教学和多学科协作诊疗。', NULL, NOW(), NOW());

-- 初始化科室
INSERT INTO `hospital_special` (`id`, `hospital_id`, `name`, `icon`, `description`, `sort`, `status`, `gmt_create`, `gmt_modified`) VALUES
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
INSERT INTO `hospital_doctor` (`id`, `account_id`, `hospital_id`, `special_id`, `name`, `professional`, `hospital_name`, `special_name`, `expertise`, `picture`, `pinyin`, `good_rate`, `service_count`, `sort`, `status`, `gmt_create`, `gmt_modified`) VALUES
(1000, 1001, 1000, 1000, '张医生', '主任医师', '云岚宗医院', '内科', '擅长内科常见病、多发病的诊治', NULL, 'zhangyisheng', 98, 1000, 1, 1, NOW(), NOW()),
(1001, 1002, 1000, 1001, '李医生', '副主任医师', '云岚宗医院', '外科', '擅长外科手术', NULL, 'liyisheng', 95, 800, 2, 1, NOW(), NOW()),
(1002, 1005, 1000, 1004, '王放射', '主治医师', '云岚宗医院', '放射科', '擅长CT、MRI影像诊断', NULL, 'wangfangshe', 97, 500, 3, 1, NOW(), NOW());

-- 初始化门诊
INSERT INTO `hospital_outpatient` (`id`, `hospital_id`, `name`, `phone`, `address`, `description`, `picture`, `status`, `gmt_create`, `gmt_modified`) VALUES
(1000, 1000, '门诊一部', '0571-8808-6677', '云岚宗医院主楼1楼', '综合门诊', NULL, 1, NOW(), NOW()),
(1001, 1000, '门诊二部', '0571-8808-6678', '云岚宗医院主楼2楼', '专科门诊', NULL, 1, NOW(), NOW()),
(1002, 1000, '急诊部', '0571-8808-6699', '云岚宗医院急诊楼', '急诊服务', NULL, 1, NOW(), NOW()),
(1003, 1000, '体检中心', '0571-8808-6680', '云岚宗医院体检楼', '健康体检', NULL, 1, NOW(), NOW());

-- 初始化诊室
INSERT INTO `hospital_clinic` (`id`, `outpatient_id`, `name`, `address`, `status`, `gmt_create`, `gmt_modified`) VALUES
(1000, 1000, '101诊室', '门诊一部101', 1, NOW(), NOW()),
(1001, 1000, '102诊室', '门诊一部102', 1, NOW(), NOW()),
(1002, 1001, '201诊室', '门诊二部201', 1, NOW(), NOW()),
(1003, 1002, '急诊1诊室', '急诊部1', 1, NOW(), NOW());

-- 初始化出诊计划
INSERT INTO `visit_plan` (`id`, `hospital_id`, `special_id`, `outpatient_id`, `clinic_id`, `doctor_id`, `time`, `day`, `gmt_create`, `gmt_modified`) VALUES
(1000, 1000, 1000, 1000, 1000, 1000, 1, DATE_ADD(NOW(), INTERVAL 1 DAY), NOW(), NOW()),
(1001, 1000, 1001, 1001, 1002, 1001, 1, DATE_ADD(NOW(), INTERVAL 1 DAY), NOW(), NOW()),
(1002, 1000, 1004, 1000, 1001, 1002, 2, DATE_ADD(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
(1003, 1000, 1000, 1000, 1000, 1000, 2, DATE_ADD(NOW(), INTERVAL 2 DAY), NOW(), NOW()),
(1004, 1000, 1001, 1001, 1002, 1001, 1, DATE_ADD(NOW(), INTERVAL 3 DAY), NOW(), NOW());
