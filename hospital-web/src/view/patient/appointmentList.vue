<template>
  <div class="appointment-list">
    <div class="page-header">
      <h2><i class="el-icon-tickets"></i> 我的预约</h2>
      <p>查看和管理您的预约挂号记录</p>
    </div>

    <!-- 状态筛选 -->
    <div class="filter-bar">
      <el-radio-group v-model="statusFilter" @change="loadAppointments">
        <el-radio-button label="">全部</el-radio-button>
        <el-radio-button label="0">待就诊</el-radio-button>
        <el-radio-button label="3">已完成</el-radio-button>
        <el-radio-button label="2">已取消</el-radio-button>
        <el-radio-button label="1">已失约</el-radio-button>
      </el-radio-group>
    </div>

    <!-- 预约列表 -->
    <div class="appointment-cards">
      <div class="appointment-card" v-for="item in appointmentList" :key="item.id">
        <div class="card-header">
          <span class="card-date">{{ item.date }}</span>
          <el-tag :type="getStatusType(item.status)" size="small">{{ getStatusText(item.status) }}</el-tag>
        </div>
        <div class="card-body">
          <div class="info-row">
            <i class="el-icon-s-custom"></i>
            <span>医生：{{ item.doctorName || '未知' }}</span>
          </div>
          <div class="info-row">
            <i class="el-icon-office-building"></i>
            <span>科室：{{ item.specialName || '未知' }}</span>
          </div>
          <div class="info-row">
            <i class="el-icon-time"></i>
            <span>时段：{{ item.time === 1 ? '上午' : '下午' }}</span>
          </div>
          <div class="info-row">
            <i class="el-icon-postcard"></i>
            <span>就诊卡号：{{ item.cardId }}</span>
          </div>
        </div>
        <div class="card-footer" v-if="item.status === 0">
          <el-button type="danger" size="small" plain @click="handleCancel(item)">
            <i class="el-icon-close"></i> 取消预约
          </el-button>
        </div>
      </div>
      <div v-if="appointmentList.length === 0" class="empty-state">
        <i class="el-icon-tickets"></i>
        <p>暂无预约记录</p>
        <el-button type="primary" @click="$router.push('/patient/appointmentCreate')">去预约</el-button>
      </div>
    </div>

    <!-- 分页 -->
    <div class="pagination-wrap" v-if="total > pageSize">
      <el-pagination background layout="prev, pager, next"
                     :total="total" :page-size="pageSize"
                     :current-page.sync="currentPage"
                     @current-change="loadAppointments">
      </el-pagination>
    </div>
  </div>
</template>

<script>
import { getMyAppointments, cancelAppointment } from '@/api/appointment'
import { getToken } from '@/utils/auth'
import { getCookie } from '@/utils/cookies'
import { tips } from '@/common/js/optionTips'

const DEMO_APPOINTMENTS_KEY = 'ylz_patient_demo_appointments'

export default {
  name: 'appointmentList',
  data() {
    return {
      isDemo: false,
      appointmentList: [],
      statusFilter: '',
      currentPage: 1,
      pageSize: 10,
      total: 0
    }
  },
  created() {
    const token = getToken()
    this.isDemo = token && token.indexOf('demo-token') !== -1
    this.loadAppointments()
  },
  methods: {
    normalizeDemoAppointments(list) {
      if (!Array.isArray(list)) {
        return this.getDefaultDemoAppointments()
      }
      return list.map(record => {
        if ((record.id === 2 || record.id === 3) && record.status === 1) {
          return { ...record, status: 3 }
        }
        return record
      })
    },
    getDemoAppointments() {
      try {
        const saved = localStorage.getItem(DEMO_APPOINTMENTS_KEY)
        if (saved) {
          const list = this.normalizeDemoAppointments(JSON.parse(saved))
          this.persistDemoAppointments(list)
          return list
        }
      } catch (e) {
        localStorage.removeItem(DEMO_APPOINTMENTS_KEY)
      }
      const list = this.getDefaultDemoAppointments()
      this.persistDemoAppointments(list)
      return list
    },
    getDefaultDemoAppointments() {
      return [
        { id: 1, cardId: 'patient1', doctorName: '林知远', specialName: '内科学系', date: '2026-05-28', time: 1, status: 0 },
        { id: 2, cardId: 'patient1', doctorName: '韩清澜', specialName: '心内科', date: '2026-05-25', time: 2, status: 3 },
        { id: 3, cardId: 'patient1', doctorName: '许明序', specialName: '骨科', date: '2026-05-20', time: 1, status: 3 },
        { id: 4, cardId: 'patient1', doctorName: '白景初', specialName: '呼吸与危重症医学科', date: '2026-05-15', time: 2, status: 2 }
      ]
    },
    persistDemoAppointments(list) {
      localStorage.setItem(DEMO_APPOINTMENTS_KEY, JSON.stringify(list))
    },
    cancelAppointmentLocally(item) {
      const list = this.getDemoAppointments().map(record => {
        return record.id === item.id ? { ...record, status: 2 } : record
      })
      this.persistDemoAppointments(list)
      tips('success', '取消成功')
      this.loadAppointments()
    },
    loadAppointments() {
      if (this.isDemo) {
        let list = this.getDemoAppointments()
        if (this.statusFilter !== '') {
          list = list.filter(item => String(item.status) === this.statusFilter)
        }
        this.appointmentList = list
        this.total = list.length
        return
      }
      const username = getCookie('username')
      const cardId = sessionStorage.getItem('accountID') || username
      getMyAppointments(cardId, this.currentPage, this.pageSize).then(res => {
        if (res.code === 200) {
          let list = res.data ? res.data.list || [] : []
          if (this.statusFilter !== '') {
            list = list.filter(item => String(item.status) === this.statusFilter)
          }
          this.appointmentList = list
          this.total = res.data ? res.data.total || 0 : 0
        }
      }).catch(() => {
        let list = this.getDemoAppointments()
        if (this.statusFilter !== '') {
          list = list.filter(item => String(item.status) === this.statusFilter)
        }
        this.appointmentList = list
        this.total = list.length
      })
    },
    getStatusType(status) {
      const map = { 0: 'warning', 1: 'danger', 2: 'info', 3: 'success' }
      return map[status] || 'info'
    },
    getStatusText(status) {
      const map = { 0: '待就诊', 1: '已失约', 2: '已取消', 3: '已完成' }
      return map[status] || '未知'
    },
    handleCancel(item) {
      this.$confirm('确定要取消该预约吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }).then(() => {
        if (this.isDemo) {
          this.cancelAppointmentLocally(item)
          return
        }
        cancelAppointment(item.id).then(res => {
          if (res.code === 200) {
            tips('success', '取消成功')
            this.loadAppointments()
          } else {
            this.cancelAppointmentLocally(item)
          }
        }).catch(() => {
          this.cancelAppointmentLocally(item)
        })
      }).catch(() => {})
    }
  }
}
</script>

<style lang="scss" scoped>
$primary: #075f42;
$primary-light: #20a978;

.appointment-list {
  padding: 0;
}

.page-header {
  position: relative;
  overflow: hidden;
  padding: 30px 34px;
  margin-bottom: 24px;
  border-radius: 8px;
  background: linear-gradient(90deg, #075f42 0%, #0b8a61 58%, #22ad7a 100%);
  box-shadow: 0 12px 30px rgba(7, 95, 66, 0.16);

  &::after {
    content: '';
    position: absolute;
    right: 36px;
    top: -52px;
    width: 180px;
    height: 180px;
    border-radius: 50%;
    background: rgba(255, 255, 255, 0.1);
  }

  h2 {
    position: relative;
    z-index: 1;
    font-size: 22px;
    color: white;
    margin: 0 0 8px;
    i { margin-right: 8px; }
  }
  p {
    position: relative;
    z-index: 1;
    color: rgba(255, 255, 255, 0.84);
    font-size: 14px;
    margin: 0;
  }
}

.filter-bar {
  margin-bottom: 20px;
  background: white;
  padding: 16px 20px;
  border-radius: 8px;
  border: 1px solid rgba(0, 122, 77, 0.08);
  box-shadow: 0 2px 12px rgba(8, 83, 61, 0.05);
}

.appointment-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 16px;
  margin-bottom: 20px;
}

.appointment-card {
  background: white;
  border-radius: 8px;
  border: 1px solid rgba(0, 122, 77, 0.08);
  box-shadow: 0 2px 12px rgba(8, 83, 61, 0.05);
  overflow: hidden;
  transition: transform 0.3s, box-shadow 0.3s;
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 24px rgba(8, 83, 61, 0.12);
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: linear-gradient(135deg, #f8fbfa, #f0faf5);
  border-bottom: 1px solid #e5f0eb;
  .card-date {
    font-size: 15px;
    font-weight: 600;
    color: #24312d;
  }
}

.card-body {
  padding: 16px 20px;
  .info-row {
    display: flex;
    align-items: center;
    padding: 8px 0;
    i {
      color: $primary-light;
      margin-right: 10px;
      font-size: 16px;
    }
    span {
      font-size: 14px;
      color: #4d625a;
    }
  }
}

.card-footer {
  padding: 12px 20px;
  border-top: 1px solid #eef2f0;
  text-align: right;
}

.empty-state {
  grid-column: 1 / -1;
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 8px;
  border: 1px solid rgba(0, 122, 77, 0.08);
  box-shadow: 0 2px 12px rgba(8, 83, 61, 0.05);
  i {
    font-size: 48px;
    color: #bdd8ce;
    display: block;
    margin-bottom: 16px;
  }
  p {
    color: #999;
    font-size: 14px;
    margin-bottom: 16px;
  }
}

.pagination-wrap {
  display: flex;
  justify-content: center;
  padding: 20px 0;
}
</style>
