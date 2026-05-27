<template>
  <div class="patient-profile">
    <div class="page-header">
      <h2><i class="el-icon-user"></i> 个人信息</h2>
      <p>查看您的个人资料和就诊卡信息</p>
    </div>

    <div class="profile-grid">
      <!-- 基本信息 -->
      <div class="profile-card">
        <div class="card-title">
          <i class="el-icon-user"></i>
          基本信息
        </div>
        <div class="card-body">
          <div class="info-row">
            <span class="label">账号</span>
            <span class="value">{{ username }}</span>
          </div>
          <div class="info-row">
            <span class="label">姓名</span>
            <span class="value">{{ patientInfo.name || '-' }}</span>
          </div>
          <div class="info-row">
            <span class="label">性别</span>
            <span class="value">{{ patientInfo.gender === 1 ? '男' : patientInfo.gender === 2 ? '女' : '-' }}</span>
          </div>
          <div class="info-row">
            <span class="label">年龄</span>
            <span class="value">{{ patientInfo.age || '-' }}</span>
          </div>
          <div class="info-row">
            <span class="label">电话</span>
            <span class="value">{{ patientInfo.phone || '-' }}</span>
          </div>
          <div class="info-row">
            <span class="label">身份证号</span>
            <span class="value">{{ patientInfo.idCard || '-' }}</span>
          </div>
          <div class="info-row">
            <span class="label">地址</span>
            <span class="value">{{ patientInfo.address || '-' }}</span>
          </div>
        </div>
      </div>

      <!-- 就诊卡信息 -->
      <div class="profile-card">
        <div class="card-title">
          <i class="el-icon-postcard"></i>
          就诊卡信息
        </div>
        <div class="card-body">
          <div class="info-row">
            <span class="label">就诊卡号</span>
            <span class="value highlight">{{ cardInfo.cardId || username }}</span>
          </div>
          <div class="info-row">
            <span class="label">办卡日期</span>
            <span class="value">{{ cardInfo.createTime || '-' }}</span>
          </div>
          <div class="info-row">
            <span class="label">卡状态</span>
            <span class="value">
              <el-tag :type="cardInfo.status === 1 ? 'success' : 'danger'" size="small">
                {{ cardInfo.status === 1 ? '正常' : '已挂失' }}
              </el-tag>
            </span>
          </div>
          <div class="info-row">
            <span class="label">余额</span>
            <span class="value highlight">¥{{ cardInfo.balance || '0.00' }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 修改密码 -->
    <div class="profile-card" style="margin-top: 20px;">
      <div class="card-title">
        <i class="el-icon-lock"></i>
        修改密码
      </div>
      <div class="card-body">
        <el-form ref="passwordForm" :model="passwordForm" :rules="rules" label-width="100px" style="max-width: 400px;">
          <el-form-item label="旧密码" prop="password">
            <el-input v-model="passwordForm.password" type="password" placeholder="请输入旧密码"></el-input>
          </el-form-item>
          <el-form-item label="新密码" prop="newPassword">
            <el-input v-model="passwordForm.newPassword" type="password" placeholder="请输入新密码"></el-input>
          </el-form-item>
          <el-form-item label="确认密码" prop="confirmPassword">
            <el-input v-model="passwordForm.confirmPassword" type="password" placeholder="请再次输入新密码"></el-input>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="updatePwd">确认修改</el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script>
import { getPatientInfo, getMedicalCard } from '@/api/appointment'
import { updatePassword } from '@/api/login'
import { getToken } from '@/utils/auth'
import { getCookie } from '@/utils/cookies'
import { tips } from '@/common/js/optionTips'
import SHA256 from 'js-sha256'

export default {
  name: 'patientProfile',
  data() {
    return {
      isDemo: false,
      username: '',
      patientInfo: {},
      cardInfo: {},
      loading: false,
      passwordForm: {
        password: '',
        newPassword: '',
        confirmPassword: ''
      },
      rules: {
        password: [{ required: true, message: '请输入旧密码', trigger: 'blur' }],
        newPassword: [{ required: true, message: '请输入新密码', trigger: 'blur' }],
        confirmPassword: [{ required: true, message: '请再次确认密码', trigger: 'blur' }]
      }
    }
  },
  created() {
    const token = getToken()
    this.isDemo = token && token.indexOf('demo-token') !== -1
    this.username = getCookie('username') || ''
    if (this.isDemo) {
      this.patientInfo = { name: '演示患者', gender: 1, age: 28, phone: '13800138000', idCard: '330100199501011234', address: '云岚市青澜区云岚宗大道88号' }
      this.cardInfo = { cardId: this.username, createTime: '2024-01-15', status: 1, balance: '500.00' }
    } else {
      this.loadPatientInfo()
      this.loadCardInfo()
    }
  },
  methods: {
    loadPatientInfo() {
      const cardId = sessionStorage.getItem('accountID') || this.username
      getPatientInfo(cardId).then(res => {
        if (res.code === 200) {
          this.patientInfo = res.data || {}
        }
      }).catch(() => {})
    },
    loadCardInfo() {
      const cardId = sessionStorage.getItem('accountID') || this.username
      getMedicalCard(cardId).then(res => {
        if (res.code === 200) {
          this.cardInfo = res.data || {}
        }
      }).catch(() => {})
    },
    updatePwd() {
      this.$refs.passwordForm.validate(valid => {
        if (!valid) return
        if (this.passwordForm.newPassword !== this.passwordForm.confirmPassword) {
          tips('error', '两次输入的密码不一致')
          return
        }
        this.loading = true
        updatePassword({
          accountId: sessionStorage.getItem('accountID'),
          newPassword: SHA256(this.passwordForm.newPassword),
          password: SHA256(this.passwordForm.password)
        }).then(res => {
          this.loading = false
          if (res.code === 200) {
            tips('success', '密码修改成功')
            this.passwordForm = { password: '', newPassword: '', confirmPassword: '' }
          } else if (res.code === 404) {
            tips('error', '原密码错误')
          }
        }).catch(() => {
          this.loading = false
          tips('error', '修改密码失败')
        })
      })
    }
  }
}
</script>

<style lang="scss" scoped>
$primary: #075f42;
$primary-light: #20a978;

.patient-profile {
  padding: 20px;
}

.page-header {
  margin-bottom: 24px;
  h2 {
    font-size: 22px;
    color: $primary;
    margin: 0 0 8px;
    i { margin-right: 8px; }
  }
  p { color: #999; font-size: 14px; margin: 0; }
}

.profile-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(360px, 1fr));
  gap: 20px;
}

.profile-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
  overflow: hidden;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  padding: 18px 24px;
  background: #f8faf9;
  border-bottom: 1px solid #eee;
  i {
    color: $primary-light;
    margin-right: 8px;
  }
}

.card-body {
  padding: 20px 24px;
}

.info-row {
  display: flex;
  padding: 12px 0;
  border-bottom: 1px solid #f5f5f5;
  &:last-child {
    border-bottom: none;
  }
  .label {
    width: 100px;
    color: #999;
    font-size: 14px;
    flex-shrink: 0;
  }
  .value {
    flex: 1;
    color: #333;
    font-size: 14px;
    &.highlight {
      color: $primary;
      font-weight: 600;
    }
  }
}
</style>
