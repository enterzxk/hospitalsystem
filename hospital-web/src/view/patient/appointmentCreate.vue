<template>
  <div class="appointment-create">
    <div class="page-header">
      <h2><i class="el-icon-date"></i> 预约挂号</h2>
      <p>请选择科室、医生和就诊时间完成预约</p>
    </div>

    <!-- 步骤条 -->
    <el-steps :active="currentStep" finish-status="success" align-center class="steps-bar">
      <el-step title="选择科室" icon="el-icon-office-building"></el-step>
      <el-step title="选择医生" icon="el-icon-s-custom"></el-step>
      <el-step title="选择时间" icon="el-icon-time"></el-step>
      <el-step title="确认预约" icon="el-icon-check"></el-step>
    </el-steps>

    <!-- 步骤1：选择科室 -->
    <div class="step-content" v-show="currentStep === 0">
      <div class="section-card">
        <h3>选择专科</h3>
        <div class="dept-grid">
          <div class="dept-item" v-for="item in specialList" :key="item.id"
               :class="{ active: selectedSpecial === item.id }"
               @click="selectSpecial(item)">
            <i class="el-icon-office-building"></i>
            <span>{{ item.name }}</span>
          </div>
          <div v-if="specialList.length === 0" class="empty-tip">
            <i class="el-icon-office-building"></i>
            <p>暂无专科数据</p>
          </div>
        </div>
      </div>
      <div class="section-card" v-if="selectedSpecial">
        <h3>选择门诊</h3>
        <div class="dept-grid">
          <div class="dept-item" v-for="item in outpatientList" :key="item.id"
               :class="{ active: selectedOutpatient === item.id }"
               @click="selectOutpatient(item)">
            <i class="el-icon-s-cooperation"></i>
            <span>{{ item.name }}</span>
          </div>
          <div v-if="outpatientList.length === 0" class="empty-tip">
            <i class="el-icon-s-cooperation"></i>
            <p>该专科下暂无门诊</p>
          </div>
        </div>
      </div>
      <div class="step-actions">
        <el-button type="primary" :disabled="!selectedOutpatient" @click="nextStep" size="medium">
          下一步 <i class="el-icon-arrow-right"></i>
        </el-button>
      </div>
    </div>

    <!-- 步骤2：选择医生 -->
    <div class="step-content" v-show="currentStep === 1">
      <div class="section-card">
        <h3>选择医生</h3>
        <div class="doctor-grid">
          <div class="doctor-card" v-for="doc in doctorList" :key="doc.id"
               :class="{ active: selectedDoctor && selectedDoctor.id === doc.id }"
               @click="selectDoctor(doc)">
            <div class="doctor-avatar">
              <i class="el-icon-s-custom"></i>
            </div>
            <div class="doctor-info">
              <div class="doctor-name">{{ doc.name }}</div>
              <div class="doctor-title">{{ doc.jobTitle || '医师' }}</div>
              <div class="doctor-desc">{{ doc.description || '暂无简介' }}</div>
            </div>
          </div>
          <div v-if="doctorList.length === 0" class="empty-tip">
            <i class="el-icon-s-custom"></i>
            <p>该门诊暂无可预约的医生</p>
          </div>
        </div>
      </div>
      <div class="step-actions">
        <el-button @click="prevStep" size="medium"><i class="el-icon-arrow-left"></i> 上一步</el-button>
        <el-button type="primary" :disabled="!selectedDoctor" @click="nextStep" size="medium">
          下一步 <i class="el-icon-arrow-right"></i>
        </el-button>
      </div>
    </div>

    <!-- 步骤3：选择时间 -->
    <div class="step-content" v-show="currentStep === 2">
      <div class="section-card">
        <h3>选择就诊日期</h3>
        <el-date-picker v-model="selectedDate" type="date" placeholder="选择日期"
                        :picker-options="datePickerOptions" value-format="yyyy-MM-dd"
                        @change="loadVisitPlans" class="date-picker">
        </el-date-picker>
      </div>
      <div class="section-card" v-if="selectedDate">
        <h3>选择时段</h3>
        <div class="time-grid">
          <div class="time-item" v-for="plan in visitPlans" :key="plan.id"
               :class="{ active: selectedPlan && selectedPlan.id === plan.id, disabled: plan.currentNum >= plan.maxNum }"
               @click="selectPlan(plan)">
            <div class="time-label">{{ plan.time === 1 ? '上午' : '下午' }}</div>
            <div class="time-info">
              <span>剩余号源：{{ plan.maxNum - plan.currentNum }}</span>
            </div>
          </div>
          <div v-if="visitPlans.length === 0" class="empty-tip">
            <i class="el-icon-time"></i>
            <p>该日期暂无出诊安排</p>
          </div>
        </div>
      </div>
      <div class="step-actions">
        <el-button @click="prevStep" size="medium"><i class="el-icon-arrow-left"></i> 上一步</el-button>
        <el-button type="primary" :disabled="!selectedPlan" @click="nextStep" size="medium">
          下一步 <i class="el-icon-arrow-right"></i>
        </el-button>
      </div>
    </div>

    <!-- 步骤4：确认预约 -->
    <div class="step-content" v-show="currentStep === 3">
      <div class="section-card confirm-card">
        <h3>确认预约信息</h3>
        <div class="confirm-info">
          <div class="confirm-row">
            <span class="label"><i class="el-icon-office-building"></i> 专科</span>
            <span class="value">{{ selectedSpecialName }}</span>
          </div>
          <div class="confirm-row">
            <span class="label"><i class="el-icon-s-cooperation"></i> 门诊</span>
            <span class="value">{{ selectedOutpatientName }}</span>
          </div>
          <div class="confirm-row">
            <span class="label"><i class="el-icon-s-custom"></i> 医生</span>
            <span class="value">{{ selectedDoctor ? selectedDoctor.name : '' }}</span>
          </div>
          <div class="confirm-row">
            <span class="label"><i class="el-icon-date"></i> 日期</span>
            <span class="value">{{ selectedDate }}</span>
          </div>
          <div class="confirm-row">
            <span class="label"><i class="el-icon-time"></i> 时段</span>
            <span class="value">{{ selectedPlan ? (selectedPlan.time === 1 ? '上午' : '下午') : '' }}</span>
          </div>
        </div>
      </div>
      <div class="step-actions">
        <el-button @click="prevStep" size="medium"><i class="el-icon-arrow-left"></i> 上一步</el-button>
        <el-button type="primary" :loading="submitting" @click="submitAppointment" size="medium">
          <i class="el-icon-check"></i> 确认预约
        </el-button>
      </div>
    </div>
  </div>
</template>

<script>
import { getSpecialList, getOutpatientList, getDoctorList, getVisitPlanByDept, createAppointment } from '@/api/appointment'
import { getToken } from '@/utils/auth'
import { getCookie } from '@/utils/cookies'
import { tips } from '@/common/js/optionTips'

const DEMO_APPOINTMENTS_KEY = 'ylz_patient_demo_appointments'

export default {
  name: 'appointmentCreate',
  data() {
    return {
      isDemo: false,
      currentStep: 0,
      specialList: [],
      outpatientList: [],
      doctorList: [],
      visitPlans: [],
      selectedSpecial: null,
      selectedSpecialName: '',
      selectedOutpatient: null,
      selectedOutpatientName: '',
      selectedDoctor: null,
      selectedDate: '',
      selectedPlan: null,
      submitting: false,
      datePickerOptions: {
        disabledDate(date) {
          return date < new Date(new Date().setHours(0, 0, 0, 0))
        }
      }
    }
  },
  created() {
    const token = getToken()
    this.isDemo = token && token.indexOf('demo-token') !== -1
    this.loadSpecialList()
  },
  methods: {
    // Demo 数据
    getDemoSpecials() {
      return [
        { id: 1, name: '内科' },
        { id: 2, name: '外科' },
        { id: 3, name: '儿科' },
        { id: 4, name: '妇产科' },
        { id: 5, name: '骨科' },
        { id: 6, name: '眼科' },
        { id: 7, name: '口腔科' },
        { id: 8, name: '皮肤科' }
      ]
    },
    getDemoOutpatients(specialId) {
      const data = {
        1: [{ id: 101, name: '普通内科门诊' }, { id: 102, name: '心血管内科门诊' }, { id: 103, name: '呼吸内科门诊' }],
        2: [{ id: 201, name: '普通外科门诊' }, { id: 202, name: '神经外科门诊' }],
        3: [{ id: 301, name: '儿内科门诊' }, { id: 302, name: '儿外科门诊' }],
        4: [{ id: 401, name: '妇科门诊' }, { id: 402, name: '产科门诊' }],
        5: [{ id: 501, name: '骨科门诊' }, { id: 502, name: '关节外科门诊' }],
        6: [{ id: 601, name: '眼科门诊' }],
        7: [{ id: 701, name: '口腔内科门诊' }, { id: 702, name: '口腔外科门诊' }],
        8: [{ id: 801, name: '皮肤科门诊' }]
      }
      return data[specialId] || []
    },
    getDemoDoctors() {
      return [
        { id: 1, name: '张医生', jobTitle: '主任医师', description: '从医30年，擅长心血管疾病诊治' },
        { id: 2, name: '李医生', jobTitle: '副主任医师', description: '擅长呼吸系统疾病诊治' },
        { id: 3, name: '王医生', jobTitle: '主治医师', description: '专注内科常见病诊疗' }
      ]
    },
    getDemoPlans() {
      return [
        { id: 1, doctorId: 1, time: 1, maxNum: 30, currentNum: 12 },
        { id: 2, doctorId: 1, time: 2, maxNum: 20, currentNum: 8 },
        { id: 3, doctorId: 2, time: 1, maxNum: 25, currentNum: 25 },
        { id: 4, doctorId: 2, time: 2, maxNum: 20, currentNum: 5 },
        { id: 5, doctorId: 3, time: 1, maxNum: 30, currentNum: 18 },
        { id: 6, doctorId: 3, time: 2, maxNum: 20, currentNum: 3 }
      ]
    },
    loadSpecialList() {
      if (this.isDemo) {
        this.specialList = this.getDemoSpecials()
        return
      }
      getSpecialList().then(res => {
        if (res.code === 200) {
          this.specialList = res.data || []
        }
      }).catch(() => {
        // API 失败时使用 demo 数据
        this.specialList = this.getDemoSpecials()
      })
    },
    selectSpecial(item) {
      this.selectedSpecial = item.id
      this.selectedSpecialName = item.name
      this.selectedOutpatient = null
      this.selectedOutpatientName = ''
      this.selectedDoctor = null
      this.selectedDate = ''
      this.selectedPlan = null
      if (this.isDemo) {
        this.outpatientList = this.getDemoOutpatients(item.id)
        return
      }
      getOutpatientList(item.id).then(res => {
        if (res.code === 200) {
          this.outpatientList = res.data || []
        }
      }).catch(() => {
        this.outpatientList = this.getDemoOutpatients(item.id)
      })
    },
    selectOutpatient(item) {
      this.selectedOutpatient = item.id
      this.selectedOutpatientName = item.name
      this.selectedDoctor = null
      this.selectedDate = ''
      this.selectedPlan = null
      if (this.isDemo) {
        this.doctorList = this.getDemoDoctors()
        return
      }
      getDoctorList(this.selectedSpecial, item.id, 1, 50).then(res => {
        if (res.code === 200) {
          this.doctorList = res.data ? res.data.list || [] : []
        }
      }).catch(() => {
        this.doctorList = this.getDemoDoctors()
      })
    },
    selectDoctor(doc) {
      this.selectedDoctor = doc
      this.selectedDate = ''
      this.selectedPlan = null
    },
    loadVisitPlans() {
      if (!this.selectedDoctor || !this.selectedDate) return
      this.selectedPlan = null
      if (this.isDemo) {
        this.visitPlans = this.getDemoPlans().filter(p => p.doctorId === this.selectedDoctor.id)
        return
      }
      getVisitPlanByDept(this.selectedSpecial, this.selectedOutpatient, this.selectedDate, 1, 50).then(res => {
        if (res.code === 200) {
          const plans = res.data ? res.data.list || [] : []
          this.visitPlans = plans.filter(p => p.doctorId === this.selectedDoctor.id)
        }
      }).catch(() => {
        this.visitPlans = this.getDemoPlans().filter(p => p.doctorId === this.selectedDoctor.id)
      })
    },
    selectPlan(plan) {
      if (plan.currentNum >= plan.maxNum) {
        tips('warning', '该时段号源已满')
        return
      }
      this.selectedPlan = plan
    },
    nextStep() {
      if (this.currentStep < 3) this.currentStep++
    },
    prevStep() {
      if (this.currentStep > 0) this.currentStep--
    },
    submitAppointment() {
      const username = getCookie('username')
      const cardId = sessionStorage.getItem('accountID') || username

      if (this.isDemo) {
        const saved = localStorage.getItem(DEMO_APPOINTMENTS_KEY)
        const list = saved ? JSON.parse(saved) : []
        list.unshift({
          id: Date.now(),
          cardId,
          doctorName: this.selectedDoctor.name,
          specialName: this.selectedSpecialName,
          date: this.selectedDate,
          time: this.selectedPlan.time,
          status: 0
        })
        localStorage.setItem(DEMO_APPOINTMENTS_KEY, JSON.stringify(list))
        tips('success', '预约成功！（演示模式）')
        this.$router.push('/patient/appointmentList')
        return
      }

      this.submitting = true
      createAppointment({
        cardId: cardId,
        planId: this.selectedPlan.id,
        doctorId: this.selectedDoctor.id,
        date: this.selectedDate,
        time: this.selectedPlan.time
      }).then(res => {
        this.submitting = false
        if (res.code === 200) {
          tips('success', '预约成功！')
          this.$router.push('/patient/appointmentList')
        }
      }).catch(() => {
        this.submitting = false
        tips('error', '预约失败，请重试')
      })
    }
  }
}
</script>

<style lang="scss" scoped>
$primary: #075f42;
$primary-light: #20a978;

.appointment-create {
  padding: 0;
}

.page-header {
  margin-bottom: 24px;
  h2 {
    font-size: 22px;
    color: $primary;
    margin: 0 0 8px;
    i { margin-right: 8px; }
  }
  p {
    color: #999;
    font-size: 14px;
    margin: 0;
  }
}

.steps-bar {
  margin-bottom: 28px;
  padding: 24px;
  background: white;
  border-radius: 14px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.04);
  border: 1px solid #eef2f0;
}

.section-card {
  background: white;
  border-radius: 14px;
  padding: 24px;
  margin-bottom: 20px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.04);
  border: 1px solid #eef2f0;
  h3 {
    font-size: 16px;
    color: #333;
    margin: 0 0 18px;
    padding-bottom: 14px;
    border-bottom: 1px solid #eee;
    font-weight: 600;
  }
}

.dept-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 12px;
}

.dept-item {
  padding: 18px 14px;
  border: 2px solid #eef2f0;
  border-radius: 12px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s;
  background: #fafcfb;
  i {
    font-size: 26px;
    color: #aab5ae;
    display: block;
    margin-bottom: 10px;
  }
  span {
    font-size: 14px;
    color: #555;
    font-weight: 500;
  }
  &:hover {
    border-color: $primary-light;
    background: #f0faf5;
    i { color: $primary-light; }
  }
  &.active {
    border-color: $primary;
    background: linear-gradient(135deg, $primary, $primary-light);
    box-shadow: 0 4px 14px rgba(7, 95, 66, 0.2);
    i, span { color: white; }
  }
}

.doctor-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 14px;
}

.doctor-card {
  display: flex;
  padding: 18px;
  border: 2px solid #eef2f0;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s;
  background: #fafcfb;
  &:hover {
    border-color: $primary-light;
    box-shadow: 0 4px 14px rgba(0,0,0,0.06);
    background: #f8faf9;
  }
  &.active {
    border-color: $primary;
    background: #f0faf5;
    box-shadow: 0 4px 14px rgba(7, 95, 66, 0.12);
  }
}

.doctor-avatar {
  width: 54px;
  height: 54px;
  border-radius: 14px;
  background: linear-gradient(135deg, $primary, $primary-light);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 14px;
  flex-shrink: 0;
  i { font-size: 26px; color: white; }
}

.doctor-info {
  flex: 1;
  overflow: hidden;
  .doctor-name {
    font-size: 16px;
    font-weight: 600;
    color: #333;
    margin-bottom: 4px;
  }
  .doctor-title {
    font-size: 13px;
    color: $primary;
    margin-bottom: 6px;
    font-weight: 500;
  }
  .doctor-desc {
    font-size: 12px;
    color: #999;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
}

.date-picker {
  width: 260px;
}

.time-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 12px;
}

.time-item {
  padding: 18px 20px;
  border: 2px solid #eef2f0;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s;
  background: #fafcfb;
  &:hover:not(.disabled) {
    border-color: $primary-light;
    background: #f0faf5;
  }
  &.active {
    border-color: $primary;
    background: #f0faf5;
    .time-label { color: $primary; }
  }
  &.disabled {
    opacity: 0.5;
    cursor: not-allowed;
    background: #f5f5f5;
  }
  .time-label {
    font-size: 16px;
    font-weight: 600;
    color: #333;
    margin-bottom: 6px;
  }
  .time-info {
    font-size: 13px;
    color: #999;
  }
}

.confirm-card {
  .confirm-info {
    max-width: 440px;
  }
  .confirm-row {
    display: flex;
    padding: 14px 0;
    border-bottom: 1px solid #f5f5f5;
    .label {
      width: 100px;
      color: #999;
      font-size: 14px;
      display: flex;
      align-items: center;
      gap: 6px;
      i { color: $primary-light; }
    }
    .value {
      flex: 1;
      color: #333;
      font-size: 14px;
      font-weight: 500;
    }
  }
}

.step-actions {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-top: 24px;
  padding: 20px;
  background: white;
  border-radius: 14px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.04);
  border: 1px solid #eef2f0;
}

.empty-tip {
  grid-column: 1 / -1;
  text-align: center;
  color: #999;
  padding: 40px;
  font-size: 14px;
  i {
    font-size: 36px;
    color: #ddd;
    display: block;
    margin-bottom: 10px;
  }
  p { margin: 0; }
}
</style>
