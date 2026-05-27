-- 修复缺失的数据库表
-- 仅创建影像管理和标注功能所需的表

SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 出诊计划表（修复之前的报错）
-- ----------------------------
DROP TABLE IF EXISTS `visit_plan`;
CREATE TABLE `visit_plan` (
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
    INDEX `idx_hospital_id` (`hospital_id`) USING BTREE,
    INDEX `idx_doctor_id` (`doctor_id`) USING BTREE,
    INDEX `idx_special_id` (`special_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10001 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '出诊信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- 影像资料表
-- ----------------------------
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

-- ----------------------------
-- 诊断报告表
-- ----------------------------
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

-- ----------------------------
-- 报告影像关联表
-- ----------------------------
DROP TABLE IF EXISTS `report_imaging_relation`;
CREATE TABLE `report_imaging_relation` (
    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '关系编号',
    `report_id` bigint(20) NOT NULL COMMENT '报告编号',
    `imaging_id` bigint(20) NOT NULL COMMENT '影像编号',
    `gmt_create` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `uk_report_imaging` (`report_id`, `imaging_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '报告影像关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- 就诊记录表
-- ----------------------------
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

-- ----------------------------
-- 影像标注表（人工标注数据存储）
-- ----------------------------
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
