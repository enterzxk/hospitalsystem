# hospital-web

> 医院管理系统前端 — 基于 Vue 2.5 + Element UI + Webpack 3 的多角色 PC 管理系统

原项目地址：https://gitee.com/yyyangyx/appointment-admin

## 介绍

本项目是医院管理系统的前端部分，采用 Vue 2 + Webpack 3 + Vuex + Element UI + SCSS 技术栈开发。系统支持**四角色权限隔离**：管理员、主治医生、放射科医生、患者，每个角色拥有独立的路由、菜单和功能模块。

### 核心功能

- **管理员端** — 医院管理、科室管理、医生管理、患者管理、影像管理、诊断管理、排版管理
- **主治医生端** — 医生工作台、患者预约管理、出诊计划、影像查看、诊断报告撰写
- **放射科医生端** — 放射科工作台、DICOM 影像查看器、Canvas 标注工具（框选/画笔/擦除）、AI 辅助分割
- **患者端** — 预约挂号（多步骤向导）、我的预约、就诊记录、报告查询、缴费记录、科室介绍、个人信息

## 技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| Node.js | **16.20.2** | 运行环境（**必须是 16.x**，不兼容 18/20/24） |
| Vue.js | 2.5 | 前端框架 |
| Element UI | 2.13+ | UI 组件库 |
| Vue Router | 3.x | 路由管理（4 套角色路由） |
| Vuex | 3.x | 状态管理 |
| Axios | 0.19 | HTTP 客户端 |
| Webpack | 3.6 | 模块打包工具 |
| SCSS (Sass) | 1.32 | CSS 预处理器 |
| Cornerstone.js | 2.6 | DICOM 医学影像渲染引擎 |
| DICOM Parser | 1.8 | DICOM 文件解析库 |
| Three.js | 0.184 | 3D 渲染（影像查看器） |
| js-cookie | 2.2 | Cookie 管理 |
| js-sha256 | 0.9 | 密码加密（前端 SHA256 哈希） |
| NProgress | 0.2 | 页面加载进度条 |

## 界面预览

### 大厅首页

![大厅界面](../前端展示/大厅界面1.png)

### 患者界面

![患者界面](../前端展示/患者界面.png)

### 放射科医生界面（DICOM 查看器 + AI 分割）

![放射科医生界面](../前端展示/放射科医生界面.png)

## 架构说明

### 四套路由体系

```
permission.js 根据用户名前缀动态注入路由：
  admin         → systemRouterMap      （管理员）
  doctor*       → doctorRouterMap      （主治医生）
  radiologist*  → radiologistRouterMap  （放射科医生）
  patient*      → patientRouterMap     （患者）
```

### 项目结构

```
hospital-web/
├── src/
│   ├── api/                    # API 接口封装
│   │   ├── login.js            # 登录认证
│   │   ├── doctor.js           # 医生管理
│   │   ├── appointment.js      # 预约挂号
│   │   ├── imaging.js          # 影像管理
│   │   ├── diagnosis.js        # 诊断报告
│   │   └── annotation.js       # 标注管理
│   ├── view/                   # 页面组件
│   │   ├── login/              # 登录页
│   │   ├── home/               # 首页仪表板
│   │   ├── hospitalManagement/ # 医院管理
│   │   ├── departmentManagement/ # 科室管理
│   │   ├── doctorManagement/   # 医生管理
│   │   ├── patientManagement/  # 患者管理
│   │   ├── imagingManagement/  # 影像管理
│   │   │   ├── imagingList.vue       # 影像列表
│   │   │   ├── imagingViewer.vue     # 影像查看器（Canvas）
│   │   │   ├── imagingUpload.vue     # 影像上传
│   │   │   └── radiologistDashboard.vue # 放射科工作台
│   │   ├── diagnosisManagement/ # 诊断管理
│   │   ├── patient/            # 患者端页面
│   │   │   ├── appointmentCreate.vue  # 预约挂号向导
│   │   │   ├── appointmentList.vue    # 我的预约
│   │   │   ├── visitRecords.vue       # 就诊记录
│   │   │   ├── reportQuery.vue        # 报告查询
│   │   │   ├── paymentRecords.vue     # 缴费记录
│   │   │   ├── departmentIntroduction.vue # 科室介绍
│   │   │   └── patientProfile.vue     # 个人信息
│   │   ├── public/             # 公共页面（大厅）
│   │   └── 404/                # 404 页面
│   ├── layout/                 # 布局组件
│   │   └── layout.vue          # 主布局（顶栏 + 侧边栏 + 内容区）
│   ├── router/index.js         # 路由配置（4 套路由）
│   ├── permission.js           # 权限控制（角色路由分发）
│   ├── store/                  # Vuex 状态管理
│   ├── utils/                  # 工具函数
│   └── assets/                 # 静态资源
├── package.json
└── webpack.config.js
```

### 前端关键特性

- **SCSS 主题系统** — 统一的 `$primary-color: #075f42` 医疗绿色主题
- **DICOM 影像查看器** — Cornerstone.js 渲染，支持多系列/切片切换、Canvas 遮罩层标注
- **人工标注工具** — 框选（矩形）、画笔（自由绘制）、擦除、撤销/重做
- **Webpack 代理** — 开发环境 API 请求代理至 `localhost:8080/hospital`
- **响应式侧边栏** — 支持折叠/展开，根据角色动态生成菜单

## 安装与运行

```bash
# 克隆项目
git clone https://github.com/enterzxk/hospitalsystem.git
cd hospitalsystem/hospital-web

# ⚠️ 必须使用 Node.js 16.x
nvm use 16.20.2

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 生产构建
npm run build
```

启动后访问：http://localhost:8082

## 测试账号

| 账号 | 密码 | 角色 |
|------|------|------|
| `admin` | `123456` | 管理员 |
| `doctor1` | `123456` | 主治医生 |
| `radiologist1` | `123456` | 放射科医生 |
| `patient1` | `123456` | 患者 |

## 常见问题

### npm install 报错 `Can't find Python executable "python"`

```bash
npm config set sass_binary_site https://npm.taobao.org/mirrors/node-sass/
npm install node-sass
```

### 启动报错 `Node.js version incompatible`

项目要求 Node.js 16.x，使用 nvm-windows 切换：

```bash
nvm use 16.20.2
node -v  # 应显示 v16.20.2
```

## 相关项目

| 项目 | 仓库 | 说明 |
|------|------|------|
| hospital | https://github.com/enterzxk/hospitalsystem | 后端 Spring Boot 项目 |
| hospital-web | 本仓库 | 前端 Vue 管理系统 |
| medsam-service | 本仓库 medsam-service/ | AI 分割服务（Python Flask） |

## Contributors

| 贡献者 | GitHub | 贡献内容 |
|--------|--------|---------|
| **enterzxk** | [@enterzxk](https://github.com/enterzxk) | 项目维护者 — 前端重构、角色权限系统、患者功能、影像标注、AI 集成 |
| **YuJian95** | [@YuJian95](https://github.com/YuJian95) | 原项目作者 — 后端架构、数据库设计、基础功能 |

## License

MIT License
