# 医院管理系统 (Hospital Management System)

一个现代化的医院管理系统，包含医学影像管理、AI辅助诊断、预约挂号等功能。

## 功能特性

### 四角色权限系统
- **管理员** - 系统管理、科室管理、医生管理
- **主治医生** - 患者诊断、报告开具
- **放射科医生** - 影像查看、人工标注、AI辅助分割
- **患者** - 预约挂号、查看报告

### 核心功能
- 医学影像查看器（支持 DICOM 格式）
- 人工标注工具（框选、画笔、擦除）
- MedSAM AI 分割（预留接口）
- 诊断报告管理
- 预约挂号系统
- 出诊计划管理

## 技术栈

### 后端
- Java 8+
- Spring Boot 2.1.6
- MyBatis + MySQL 8
- Redis
- Spring Security + JWT

### 前端
- Vue 2.5
- Element UI
- Vue Router 3
- Vuex 3

### AI 服务
- Python 3.9+
- Flask
- MedSAM (Segment Anything)

## 快速开始

### 1. 数据库初始化

```sql
-- 执行数据库脚本（按顺序执行）
source hospital/src/main/resources/rebuild_database_final.sql
```

### 2. 启动后端

```bash
cd hospital
mvn spring-boot:run
```

后端运行在 http://localhost:8080

### 3. 启动前端

```bash
cd hospital-web
npm install
npm run dev
```

前端运行在 http://localhost:8082

### 4. 启动 AI 服务（可选）

```bash
cd medsam-service
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

AI 服务运行在 http://localhost:5000

## 测试账号

| 账号 | 密码 | 角色 |
|------|------|------|
| admin | 123456 | 管理员 |
| doctor1 | 123456 | 主治医生 |
| radiologist1 | 123456 | 放射科医生 |
| patient1 | 123456 | 患者 |

## 项目结构

```
├── hospital/                    # 后端 Spring Boot 项目
│   ├── src/main/java/          # Java 源码
│   │   └── cn.yujian95.hospital
│   │       ├── controller/     # 控制器
│   │       ├── service/        # 服务层
│   │       ├── mapper/         # MyBatis 映射
│   │       └── entity/         # 实体类
│   └── src/main/resources/     # 配置文件
│
├── hospital-web/                # 前端 Vue 项目
│   ├── src/
│   │   ├── api/                # API 接口
│   │   ├── view/               # 页面组件
│   │   ├── router/             # 路由配置
│   │   └── store/              # Vuex 状态管理
│   └── package.json
│
├── medsam-service/              # AI 分割服务
│   ├── app.py                  # Flask 应用
│   ├── requirements.txt        # Python 依赖
│   └── Dockerfile              # Docker 配置
│
└── README.md
```

## API 接口

### 认证
- `GET /power/account/login` - 登录
- `GET /power/account/info` - 获取用户信息

### 影像管理
- `POST /imaging/info/create` - 创建影像
- `GET /imaging/info/list` - 获取影像列表
- `GET /imaging/info/{id}` - 获取影像详情

### 标注管理
- `POST /imaging/annotation/create` - 创建标注
- `GET /imaging/annotation/list/{imagingId}` - 获取标注列表

### 诊断报告
- `POST /diagnosis/report/create` - 创建报告
- `GET /diagnosis/report/list` - 获取报告列表

## License

MIT License
