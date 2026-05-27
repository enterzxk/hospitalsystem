<template>
  <div class="visit-records">
    <div class="page-header">
      <h2><i class="el-icon-document"></i> 就诊记录</h2>
      <p>查看您的历史就诊信息</p>
    </div>

    <!-- 记录列表 -->
    <div class="record-cards">
      <div class="record-card" v-for="item in recordList" :key="item.id">
        <div class="card-header">
          <div class="header-left">
            <span class="record-date">{{ item.date }}</span>
            <el-tag :type="getStatusType(item.status)" size="small">{{ getStatusText(item.status) }}</el-tag>
          </div>
          <span class="record-time">{{ item.time === 1 ? '上午' : '下午' }}</span>
        </div>
        <div class="card-body">
          <div class="info-grid">
            <div class="info-item">
              <span class="label">医生</span>
              <span class="value">{{ item.doctorName || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="label">科室</span>
              <span class="value">{{ item.specialName || '-' }}</span>
            </div>
            <div class="info-item">
              <span class="label">就诊卡号</span>
              <span class="value">{{ item.cardId }}</span>
            </div>
            <div class="info-item">
              <span class="label">诊断结果</span>
              <span class="value">{{ item.diagnosis || '暂无' }}</span>
            </div>
          </div>
          <div class="case-section" v-if="item.caseInfo">
            <div class="case-title">病历信息</div>
            <div class="case-content">{{ item.caseInfo }}</div>
          </div>
        </div>
      </div>
      <div v-if="recordList.length === 0" class="empty-state">
        <i class="el-icon-document"></i>
        <p>暂无就诊记录</p>
      </div>
    </div>

    <!-- 分页 -->
    <div class="pagination-wrap" v-if="total > pageSize">
      <el-pagination background layout="prev, pager, next"
                     :total="total" :page-size="pageSize"
                     :current-page.sync="currentPage"
                     @current-change="loadRecords">
      </el-pagination>
    </div>
  </div>
</template>

<script>
import { getVisitRecords } from '@/api/appointment'
import { getToken } from '@/utils/auth'
import { getCookie } from '@/utils/cookies'

export default {
  name: 'visitRecords',
  data() {
    return {
      isDemo: false,
      recordList: [],
      currentPage: 1,
      pageSize: 10,
      total: 0
    }
  },
  created() {
    const token = getToken()
    this.isDemo = token && token.indexOf('demo-token') !== -1
    this.loadRecords()
  },
  methods: {
    getDemoRecords() {
      return [
        { id: 1, cardId: 'patient1', doctorName: '张医生', specialName: '内科', date: '2026-05-25', time: 2, status: 1, diagnosis: '上呼吸道感染', caseInfo: '患者因咳嗽、发热3天就诊。查体：咽部充血，双肺呼吸音清。诊断为上呼吸道感染，给予对症治疗。' },
        { id: 2, cardId: 'patient1', doctorName: '王医生', specialName: '骨科', date: '2026-05-20', time: 1, status: 1, diagnosis: '腰椎间盘突出', caseInfo: '患者因腰痛伴左下肢放射痛1月余就诊。MRI示L4/5椎间盘突出。建议保守治疗，注意休息。' },
        { id: 3, cardId: 'patient1', doctorName: '李医生', specialName: '外科', date: '2026-04-15', time: 1, status: 1, diagnosis: '慢性胆囊炎', caseInfo: '患者因右上腹反复疼痛就诊。B超示胆囊壁增厚。建议低脂饮食，定期复查。' }
      ]
    },
    loadRecords() {
      if (this.isDemo) {
        this.recordList = this.getDemoRecords()
        this.total = this.recordList.length
        return
      }
      const username = getCookie('username')
      const cardId = sessionStorage.getItem('accountID') || username
      getVisitRecords(cardId, this.currentPage, this.pageSize).then(res => {
        if (res.code === 200) {
          this.recordList = res.data ? res.data.list || [] : []
          this.total = res.data ? res.data.total || 0 : 0
        }
      }).catch(() => {})
    },
    getStatusType(status) {
      const map = { 0: 'warning', 1: 'success', 2: 'info' }
      return map[status] || 'info'
    },
    getStatusText(status) {
      const map = { 0: '待就诊', 1: '已完成', 2: '已取消' }
      return map[status] || '未知'
    }
  }
}
</script>

<style lang="scss" scoped>
$primary: #075f42;
$primary-light: #20a978;

.visit-records {
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

.record-cards {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.record-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
  overflow: hidden;
  transition: transform 0.3s;
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0,0,0,0.08);
  }
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  background: #f8faf9;
  border-bottom: 1px solid #eee;
  .header-left {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  .record-date {
    font-size: 15px;
    font-weight: 600;
    color: #333;
  }
  .record-time {
    font-size: 13px;
    color: #999;
  }
}

.card-body {
  padding: 20px 24px;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.info-item {
  .label {
    display: block;
    font-size: 12px;
    color: #999;
    margin-bottom: 4px;
  }
  .value {
    font-size: 14px;
    color: #333;
  }
}

.case-section {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #eee;
  .case-title {
    font-size: 14px;
    font-weight: 600;
    color: #333;
    margin-bottom: 8px;
  }
  .case-content {
    font-size: 14px;
    color: #666;
    line-height: 1.6;
    background: #f8faf9;
    padding: 12px 16px;
    border-radius: 8px;
  }
}

.empty-state {
  text-align: center;
  padding: 60px 20px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
  i {
    font-size: 48px;
    color: #ddd;
    display: block;
    margin-bottom: 16px;
  }
  p {
    color: #999;
    font-size: 14px;
  }
}

.pagination-wrap {
  display: flex;
  justify-content: center;
  padding: 20px 0;
}
</style>
