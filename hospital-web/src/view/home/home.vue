<!--首页仪表盘-->

<template>
  <div class="dashboard-page">
    <!-- ========== 患者专属首页 ========== -->
    <template v-if="isPatient">
      <!-- 顶部欢迎区 + Banner 图 -->
      <div class="patient-hero-new" :style="patientHeroStyle">
        <div class="hero-left">
          <div class="hero-welcome">
            <span class="welcome-badge">患者专属</span>
            <h1>您好，{{ displayName }}</h1>
            <p>欢迎使用云岚宗医院智慧预约挂号系统</p>
            <div class="hero-date-row">
              <i class="el-icon-time"></i>
              <span>{{ currentTime }}</span>
            </div>
          </div>
          <div class="hero-btn-group">
            <el-button type="primary" class="hero-main-btn" @click="$router.push('/patient/appointmentCreate')">
              <i class="el-icon-date"></i> 立即预约挂号
            </el-button>
            <el-button class="hero-sub-btn" @click="$router.push('/patient/appointmentList')">
              <i class="el-icon-tickets"></i> 我的预约
            </el-button>
          </div>
        </div>
        <div class="hero-right">
          <img :src="appointmentBanner" alt="预约挂号" class="hero-banner-img">
        </div>
      </div>

      <!-- 四大服务入口 -->
      <div class="patient-service-grid">
        <div class="svc-card" v-for="(svc, idx) in patientServices" :key="idx"
             @click="$router.push(svc.route)">
          <div class="svc-icon-wrap" :style="{ background: svc.bg }">
            <i :class="svc.icon"></i>
          </div>
          <h3>{{ svc.title }}</h3>
          <p>{{ svc.desc }}</p>
          <span class="svc-link">立即进入 <i class="el-icon-arrow-right"></i></span>
        </div>
      </div>

      <!-- 就诊须知 -->
      <div class="patient-notice-section">
        <div class="section-header-bar">
          <div class="header-bar-line"></div>
          <h3><i class="el-icon-info"></i> 就诊须知</h3>
        </div>
        <div class="notice-grid">
          <div class="notice-card" v-for="(item, idx) in noticeItems" :key="idx">
            <div class="notice-num-badge">{{ idx + 1 }}</div>
            <p>{{ item }}</p>
          </div>
        </div>
      </div>

      <!-- 医院信息 -->
      <div class="patient-info-section">
        <div class="section-header-bar">
          <div class="header-bar-line"></div>
          <h3><i class="el-icon-office-building"></i> 医院信息</h3>
        </div>
        <div class="info-grid-new">
          <div class="info-block" v-for="(info, idx) in hospitalInfos" :key="idx">
            <div class="info-block-icon">
              <i :class="info.icon"></i>
            </div>
            <div class="info-block-text">
              <span class="info-block-label">{{ info.label }}</span>
              <span class="info-block-value">{{ info.value }}</span>
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- ========== 管理员/医生仪表盘 ========== -->
    <template v-else>
      <!-- 欢迎信息 -->
      <div class="welcome-section">
        <div class="welcome-card">
          <div class="welcome-info">
            <h2>欢迎回来，{{ displayName }}</h2>
            <p>{{ roleText }} | 云岚宗医院智慧预约挂号管理系统</p>
          </div>
          <div class="welcome-time">
            <i class="el-icon-time"></i>
            <span>{{ currentTime }}</span>
          </div>
        </div>
      </div>

      <!-- 统计卡片 -->
      <div class="stats-section">
        <div class="stat-card" v-for="(stat, index) in stats" :key="index">
          <div class="stat-icon" :style="{ background: stat.color }">
            <i :class="stat.icon"></i>
          </div>
          <div class="stat-info">
            <div class="stat-number">{{ stat.value }}</div>
            <div class="stat-label">{{ stat.label }}</div>
          </div>
        </div>
      </div>

      <!-- 快捷操作 -->
      <div class="quick-actions">
        <h3 class="section-title">快捷操作</h3>
        <div class="action-grid">
          <div class="action-item" v-for="(action, index) in quickActions" :key="index"
               @click="handleAction(action.route)">
            <div class="action-icon" :style="{ background: action.color }">
              <i :class="action.icon"></i>
            </div>
            <span>{{ action.title }}</span>
          </div>
        </div>
      </div>

      <!-- 用户信息卡片 -->
      <div class="info-section">
        <div class="info-card">
          <h3 class="card-title">
            <i class="el-icon-user"></i>
            个人信息
          </h3>
          <div class="info-content">
            <div class="info-row">
              <span class="info-label">账号：</span>
              <span class="info-value">{{ accountIdentify }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">姓名：</span>
              <span class="info-value">{{ infoForm.name || '-' }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">性别：</span>
              <span class="info-value">{{ infoForm.gender === 1 ? '男' : infoForm.gender === 2 ? '女' : '-' }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">职称：</span>
              <span class="info-value">{{ infoForm.jobTitle || '-' }}</span>
            </div>
          </div>
          <el-button type="primary" class="change-password-btn" @click="dialogFormVisible = true">
            <i class="el-icon-lock"></i> 修改密码
          </el-button>
        </div>

        <!-- 系统信息 -->
        <div class="info-card">
          <h3 class="card-title">
            <i class="el-icon-info"></i>
            系统信息
          </h3>
          <div class="info-content">
            <div class="info-row">
              <span class="info-label">系统版本：</span>
              <span class="info-value">V2.0.0</span>
            </div>
            <div class="info-row">
              <span class="info-label">当前角色：</span>
              <span class="info-value">{{ roleText }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">上次登录：</span>
              <span class="info-value">{{ lastLoginTime }}</span>
            </div>
          </div>
        </div>
      </div>
    </template>

    <!-- 修改密码弹窗 -->
    <el-dialog title="修改密码" :visible.sync="dialogFormVisible" width="400px"
               @close="cancelModal" v-loading="isLoading">
      <el-form ref="passwordForm" :rules="rules" :model="passwordForm" label-width="100px">
        <el-form-item label="旧密码：" prop="password">
          <el-input v-model="passwordForm.password" type="password" placeholder="请输入旧密码"></el-input>
        </el-form-item>
        <el-form-item label="新密码：" prop="newPassword">
          <el-input v-model="passwordForm.newPassword" type="password" placeholder="请输入新密码"></el-input>
        </el-form-item>
        <el-form-item label="确认新密码：" prop="confirmPassword">
          <el-input v-model="passwordForm.confirmPassword" type="password" placeholder="请再次确认密码"></el-input>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="cancelModal">取 消</el-button>
        <el-button type="primary" @click="updatePassword('passwordForm')">确 定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import {getCookie} from "@/utils/cookies";
import {getDoctorInfo} from "@/api/doctor";
import {tips} from "@/common/js/optionTips";
import {updatePassword} from "@/api/login";
import {getToken} from "@/utils/auth";
import SHA256 from 'js-sha256';
import appointmentBanner from '@/assets/appointment-banner.png';
import hospitalHero from '../../../../医院背景图.png';

export default {
  name: "home",
  data() {
    return {
      infoForm: {},
      accountIdentify: '',
      currentTime: '',
      currentDate: '',
      lastLoginTime: '2024-12-15 08:30:00',
      dialogFormVisible: false,
      passwordForm: {
        password: '',
        newPassword: '',
        confirmPassword: ''
      },
      rules: {
        password: [{required: true, message: '请输入旧密码', trigger: 'blur'}],
        newPassword: [{required: true, message: '请输入新密码', trigger: 'blur'}],
        confirmPassword: [{required: true, message: '请再次确认密码', trigger: 'blur'}]
      },
      isLoading: false,
      stats: [
        { label: '今日预约', value: '128', icon: 'el-icon-date', color: '#2980b9' },
        { label: '待诊患者', value: '45', icon: 'el-icon-user', color: '#27ae60' },
        { label: '完成诊断', value: '89', icon: 'el-icon-check', color: '#e67e22' },
        { label: '影像报告', value: '32', icon: 'el-icon-document', color: '#9b59b6' }
      ],
      quickActions: [],
      appointmentBanner,
      noticeItems: [
        '请携带有效身份证件和就诊卡按时到达医院',
        '预约成功后如需取消，请提前24小时操作',
        '初诊患者请提前15分钟到达，填写病历信息',
        '复诊患者请携带既往检查报告和病历资料'
      ],
      hospitalInfos: [
        { icon: 'el-icon-office-building', label: '医院名称', value: '云岚宗医院' },
        { icon: 'el-icon-location-outline', label: '医院地址', value: '云岚市青澜区云岚宗大道88号' },
        { icon: 'el-icon-phone', label: '咨询电话', value: '0571-8808-6677' },
        { icon: 'el-icon-time', label: '门诊时间', value: '周一至周五 8:00-17:00' }
      ],
      patientServices: [
        { title: '预约挂号', desc: '在线选择科室和医生，预约就诊时间', bg: 'linear-gradient(135deg, #075f42, #20a978)', route: '/patient/appointmentCreate', icon: 'el-icon-date' },
        { title: '我的预约', desc: '查看和管理您的预约挂号记录', bg: 'linear-gradient(135deg, #007a4d, #2ecc71)', route: '/patient/appointmentList', icon: 'el-icon-tickets' },
        { title: '就诊记录', desc: '查看历史就诊信息和诊断结果', bg: 'linear-gradient(135deg, #2980b9, #3498db)', route: '/patient/visitRecords', icon: 'el-icon-document' },
        { title: '个人信息', desc: '查看和管理您的个人资料', bg: 'linear-gradient(135deg, #8e6bb0, #a57fd4)', route: '/patient/profile', icon: 'el-icon-user' }
      ]
    }
  },
  computed: {
    displayName() {
      return this.infoForm.name || this.accountIdentify || '用户';
    },
    isPatient() {
      return this.accountIdentify && this.accountIdentify.startsWith('patient');
    },
    isDemo() {
      const token = getToken();
      return token && token.indexOf('demo-token') !== -1;
    },
    patientHeroStyle() {
      return {
        backgroundImage: `linear-gradient(90deg, rgba(0, 87, 63, 0.92), rgba(0, 125, 88, 0.72), rgba(32, 169, 120, 0.22)), url(${hospitalHero})`
      };
    },
    roleText() {
      const id = this.accountIdentify;
      if (id === 'admin') return '系统管理员';
      if (id && id.startsWith('radiologist')) return '放射科医生';
      if (id && id.startsWith('doctor')) return '主治医生';
      if (id && id.startsWith('patient')) return '患者';
      return '用户';
    }
  },
  methods: {
    updateTime() {
      const now = new Date();
      const year = now.getFullYear();
      const month = String(now.getMonth() + 1).padStart(2, '0');
      const day = String(now.getDate()).padStart(2, '0');
      const hours = String(now.getHours()).padStart(2, '0');
      const minutes = String(now.getMinutes()).padStart(2, '0');
      const seconds = String(now.getSeconds()).padStart(2, '0');
      this.currentTime = `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
      this.currentDate = `${year}年${month}月${day}日`;
    },
    loadQuickActions() {
      const role = this.accountIdentify;
      if (role === 'admin') {
        this.quickActions = [
          { title: '医院管理', icon: 'el-icon-office-building', color: '#2980b9', route: '/hospitalDetail' },
          { title: '医生管理', icon: 'el-icon-s-custom', color: '#27ae60', route: '/doctorDetail' },
          { title: '患者管理', icon: 'el-icon-user', color: '#e67e22', route: '/patientList' },
          { title: '专科管理', icon: 'el-icon-guide', color: '#9b59b6', route: '/departmentDetail' },
          { title: '影像管理', icon: 'el-icon-picture', color: '#e74c3c', route: '/imagingList' },
          { title: '诊断管理', icon: 'el-icon-document-checked', color: '#1abc9c', route: '/diagnosisList' }
        ];
      } else if (role && role.startsWith('radiologist')) {
        this.quickActions = [
          { title: '放射科工作台', icon: 'el-icon-monitor', color: '#2980b9', route: '/radiologistDashboard' },
          { title: '影像管理', icon: 'el-icon-picture', color: '#27ae60', route: '/imagingList' },
          { title: '影像查看器', icon: 'el-icon-view', color: '#e67e22', route: '/imagingViewer' },
          { title: '诊断报告', icon: 'el-icon-document', color: '#9b59b6', route: '/diagnosisReports' }
        ];
      } else if (role && role.startsWith('doctor')) {
        this.quickActions = [
          { title: '患者管理', icon: 'el-icon-user', color: '#2980b9', route: '/appointDetail' },
          { title: '出诊管理', icon: 'el-icon-s-cooperation', color: '#27ae60', route: '/outCallDetail' },
          { title: '影像管理', icon: 'el-icon-picture', color: '#e67e22', route: '/imagingList' },
          { title: '诊断管理', icon: 'el-icon-document-checked', color: '#9b59b6', route: '/diagnosisList' }
        ];
      }
    },
    handleAction(route) {
      this.$router.push(route);
    },
    cancelModal() {
      this.dialogFormVisible = false;
      this.passwordForm.password = '';
      this.passwordForm.newPassword = '';
      this.passwordForm.confirmPassword = '';
      this.$nextTick(() => {
        if (this.$refs['passwordForm']) {
          this.$refs['passwordForm'].clearValidate();
        }
      });
    },
    updatePassword(formName) {
      this.$refs[formName].validate((valid) => {
        if (valid) {
          if (this.passwordForm.newPassword === this.passwordForm.confirmPassword) {
            this.isLoading = true;
            updatePassword({
              accountId: sessionStorage.getItem('accountID'),
              newPassword: SHA256(this.passwordForm.newPassword),
              password: SHA256(this.passwordForm.password)
            }).then(res => {
              if (res.code === 200) {
                this.isLoading = false;
                tips('success', '修改成功');
                this.dialogFormVisible = false;
              } else if (res.code === 404) {
                this.isLoading = false;
                tips('error', '原密码错误');
              }
            }).catch(() => {
              this.isLoading = false;
              tips('error', '更新密码失败');
            });
          } else {
            this.$message.error('新密码两次输入不一致');
          }
        }
      });
    },
    getDoctorInfo() {
      const account = sessionStorage.getItem('accountID');
      if (!account) return;
      getDoctorInfo(parseInt(account)).then(res => {
        if (res.code === 200) {
          this.infoForm = res.data;
        }
      }).catch(() => {});
    }
  },
  created() {
    this.accountIdentify = getCookie('username') || 'admin';

    // demo 模式：跳过 API 调用，直接加载
    if (this.isDemo) {
      this.loadQuickActions();
      this.updateTime();
      this.timer = setInterval(this.updateTime, 1000);
      return;
    }

    const loadDashboard = () => {
      this.accountIdentify = getCookie('username') || this.accountIdentify || 'admin';
      if (!this.isPatient && this.accountIdentify !== 'admin') {
        this.getDoctorInfo();
      }
      this.loadQuickActions();
    };
    this.$store.dispatch('GetInfo').then(loadDashboard).catch(() => {
      this.accountIdentify = getCookie('username') || 'admin';
      this.loadQuickActions();
    });
    this.updateTime();
    this.timer = setInterval(this.updateTime, 1000);
  },
  beforeDestroy() {
    if (this.timer) {
      clearInterval(this.timer);
    }
  }
}
</script>

<style lang="scss" scoped>
$primary-color: #075f42;
$primary-light: #20a978;

.dashboard-page {
  padding: 0;
}

/* ========== 患者专属首页 ========== */

.patient-hero-new {
  display: flex;
  align-items: center;
  background: linear-gradient(135deg, #075f42 0%, #0a7e58 50%, #20a978 100%);
  background-size: cover;
  background-position: center;
  border-radius: 8px;
  padding: 40px 44px;
  margin-bottom: 28px;
  position: relative;
  overflow: hidden;
  box-shadow: 0 12px 36px rgba(7, 95, 66, 0.25);
  min-height: 280px;

  &::before {
    content: '';
    position: absolute;
    width: 320px;
    height: 320px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.04);
    top: -120px;
    left: -80px;
  }
  &::after {
    content: '';
    position: absolute;
    width: 200px;
    height: 200px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.03);
    bottom: -60px;
    right: 30%;
  }
}

.hero-left {
  flex: 1;
  position: relative;
  z-index: 2;
  padding-right: 40px;
}

.hero-welcome {
  margin-bottom: 28px;

  .welcome-badge {
    display: inline-block;
    padding: 5px 14px;
    background: rgba(255, 255, 255, 0.18);
    border: 1px solid rgba(255, 255, 255, 0.25);
    border-radius: 20px;
    color: white;
    font-size: 12px;
    font-weight: 500;
    letter-spacing: 1px;
    margin-bottom: 16px;
    backdrop-filter: blur(8px);
  }
  h1 {
    font-size: 30px;
    color: white;
    margin: 0 0 10px;
    font-weight: 700;
    text-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
  }
  p {
    font-size: 16px;
    color: rgba(255, 255, 255, 0.88);
    margin: 0 0 14px;
    font-weight: 400;
  }
  .hero-date-row {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 14px;
    color: rgba(255, 255, 255, 0.75);
    i { font-size: 15px; }
  }
}

.hero-btn-group {
  display: flex;
  gap: 14px;

  .hero-main-btn {
    padding: 14px 32px;
    font-size: 15px;
    font-weight: 600;
    border-radius: 8px;
    background: white;
    color: $primary-color;
    border: none;
    box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
    transition: all 0.3s;
    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 24px rgba(0, 0, 0, 0.2);
      background: #f0faf5;
    }
  }
  .hero-sub-btn {
    padding: 14px 28px;
    font-size: 15px;
    border-radius: 8px;
    background: rgba(255, 255, 255, 0.15);
    color: white;
    border: 1px solid rgba(255, 255, 255, 0.35);
    backdrop-filter: blur(8px);
    transition: all 0.3s;
    &:hover {
      background: rgba(255, 255, 255, 0.28);
      border-color: rgba(255, 255, 255, 0.55);
    }
  }
}

.hero-right {
  flex-shrink: 0;
  width: 280px;
  height: 220px;
  position: relative;
  z-index: 2;

  .hero-banner-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    border-radius: 8px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.18);
  }
}

/* 四大服务入口 */
.patient-service-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 28px;
}

.svc-card {
  background: white;
  border-radius: 8px;
  padding: 28px 22px 24px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  border: 1px solid rgba(0, 122, 77, 0.08);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);

  &:hover {
    transform: translateY(-6px);
    box-shadow: 0 14px 34px rgba(8, 83, 61, 0.14);
    border-color: rgba(0, 122, 77, 0.18);
  }

  .svc-icon-wrap {
    width: 60px;
    height: 60px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 16px;
    i {
      font-size: 28px;
      color: white;
    }
  }

  h3 {
    font-size: 16px;
    color: #24312d;
    margin: 0 0 8px;
    font-weight: 600;
  }

  p {
    font-size: 13px;
    color: #60726b;
    margin: 0 0 14px;
    line-height: 1.5;
  }

  .svc-link {
    font-size: 13px;
    color: $primary-light;
    font-weight: 500;
    display: inline-flex;
    align-items: center;
    gap: 4px;
    transition: gap 0.2s;
    i { font-size: 12px; }
  }

  &:hover .svc-link {
    gap: 8px;
    color: $primary-color;
  }
}

/* 就诊须知 */
.patient-notice-section,
.patient-info-section {
  background: white;
  border-radius: 8px;
  padding: 28px 30px;
  margin-bottom: 24px;
  border: 1px solid rgba(0, 122, 77, 0.06);
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.04);
}

.section-header-bar {
  display: flex;
  align-items: center;
  margin-bottom: 22px;
  padding-bottom: 16px;
  border-bottom: 1px solid #eef2f0;

  .header-bar-line {
    width: 4px;
    height: 20px;
    background: linear-gradient(180deg, #007a4d, #20a978);
    border-radius: 2px;
    margin-right: 12px;
  }

  h3 {
    font-size: 17px;
    color: #24312d;
    margin: 0;
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 8px;
    i {
      color: $primary-light;
      font-size: 18px;
    }
  }
}

.notice-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 14px;
}

.notice-card {
  display: flex;
  align-items: flex-start;
  gap: 14px;
  padding: 16px 18px;
  background: linear-gradient(135deg, #f8fbfa, #f0faf5);
  border-radius: 8px;
  border: 1px solid rgba(0, 122, 77, 0.06);
  transition: all 0.25s;

  &:hover {
    background: linear-gradient(135deg, #f0faf5, #e8f5ee);
    transform: translateX(4px);
    box-shadow: 0 4px 16px rgba(8, 83, 61, 0.08);
  }

  .notice-num-badge {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    background: linear-gradient(135deg, #007a4d, #20a978);
    color: white;
    font-size: 13px;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    margin-top: 1px;
  }

  p {
    font-size: 14px;
    color: #4d625a;
    margin: 0;
    line-height: 1.6;
  }
}

/* 医院信息 */
.info-grid-new {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.info-block {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 16px 18px;
  background: linear-gradient(135deg, #f8fbfa, #f0faf5);
  border-radius: 8px;
  border: 1px solid rgba(0, 122, 77, 0.06);
  transition: all 0.25s;

  &:hover {
    background: linear-gradient(135deg, #f0faf5, #e8f5ee);
    transform: translateX(4px);
  }

  .info-block-icon {
    width: 44px;
    height: 44px;
    border-radius: 8px;
    background: linear-gradient(135deg, #007a4d, #20a978);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    i {
      font-size: 20px;
      color: white;
    }
  }

  .info-block-text {
    display: flex;
    flex-direction: column;
    gap: 3px;

    .info-block-label {
      font-size: 12px;
      color: #60726b;
    }
    .info-block-value {
      font-size: 14px;
      color: #24312d;
      font-weight: 500;
    }
  }
}

/* ========== 管理员/医生样式 ========== */

.welcome-section {
  margin-bottom: 20px;
}

.welcome-card {
  background: linear-gradient(135deg, $primary-color, $primary-light);
  border-radius: 12px;
  padding: 30px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: white;
}

.welcome-info {
  h2 {
    font-size: 24px;
    margin: 0 0 8px;
    font-weight: 600;
  }
  p {
    font-size: 14px;
    margin: 0;
    opacity: 0.9;
  }
}

.welcome-time {
  display: flex;
  align-items: center;
  font-size: 14px;
  opacity: 0.9;
  i {
    margin-right: 8px;
    font-size: 18px;
  }
}

.stats-section {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  display: flex;
  align-items: center;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
  transition: transform 0.3s, box-shadow 0.3s;
  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
  }
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16px;
  i {
    font-size: 28px;
    color: white;
  }
}

.stat-info {
  .stat-number {
    font-size: 28px;
    font-weight: 600;
    color: #333;
    line-height: 1;
    margin-bottom: 4px;
  }
  .stat-label {
    font-size: 13px;
    color: #999;
  }
}

.quick-actions {
  background: white;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 20px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
}

.section-title {
  font-size: 16px;
  color: #333;
  margin: 0 0 20px;
  font-weight: 600;
  display: flex;
  align-items: center;
  &::before {
    content: '';
    width: 4px;
    height: 16px;
    background: $primary-light;
    border-radius: 2px;
    margin-right: 10px;
  }
}

.action-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 20px;
}

.action-item {
  text-align: center;
  padding: 20px 10px;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.3s;
  &:hover {
    background: #f5f7fa;
    transform: translateY(-2px);
  }
  .action-icon {
    width: 52px;
    height: 52px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 12px;
    i {
      font-size: 24px;
      color: white;
    }
  }
  span {
    font-size: 14px;
    color: #666;
  }
}

.info-section {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.info-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.05);
}

.card-title {
  font-size: 16px;
  color: #333;
  margin: 0 0 20px;
  font-weight: 600;
  display: flex;
  align-items: center;
  padding-bottom: 15px;
  border-bottom: 1px solid #eee;
  i {
    color: $primary-light;
    margin-right: 8px;
  }
}

.info-content {
  margin-bottom: 20px;
}

.info-row {
  display: flex;
  padding: 12px 0;
  border-bottom: 1px solid #f5f5f5;
  &:last-child {
    border-bottom: none;
  }
}

.info-label {
  width: 100px;
  color: #999;
  font-size: 14px;
}

.info-value {
  flex: 1;
  color: #333;
  font-size: 14px;
}

.change-password-btn {
  background: linear-gradient(135deg, $primary-color, $primary-light);
  border: none;
  &:hover {
    background: linear-gradient(135deg, #06643f, #159464);
  }
}

.dialog-footer {
  text-align: right;
}
</style>
