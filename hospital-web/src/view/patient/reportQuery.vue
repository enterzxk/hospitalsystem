<template>
  <div class="report-query">
    <div class="page-header">
      <h2><i class="el-icon-s-check"></i> 报告查询</h2>
      <p>查看您的诊断报告和检查结果</p>
    </div>

    <!-- 筛选栏 -->
    <div class="filter-bar">
      <el-input
        v-model="searchKeyword"
        placeholder="搜索报告编号/检查类型"
        prefix-icon="el-icon-search"
        clearable
        style="width: 300px"
      />
      <el-select v-model="filterType" placeholder="检查类型" clearable style="width: 150px; margin-left: 10px;">
        <el-option label="全部" value="" />
        <el-option label="CT" value="CT" />
        <el-option label="MRI" value="MRI" />
        <el-option label="超声" value="超声" />
        <el-option label="X光" value="X光" />
      </el-select>
    </div>

    <!-- 报告列表 -->
    <div class="report-cards">
      <div class="report-card" v-for="item in filteredList" :key="item.id">
        <div class="card-header">
          <div class="header-left">
            <span class="report-no">{{ item.reportNo }}</span>
            <el-tag size="small" :type="item.reportStatus === 'submitted' ? 'success' : 'info'">
              {{ item.reportStatus === 'submitted' ? '已归档' : '待审核' }}
            </el-tag>
          </div>
          <span class="report-date">{{ item.reportDate }}</span>
        </div>
        <div class="card-body">
          <div class="info-grid">
            <div class="info-item">
              <span class="label">检查类型</span>
              <span class="value">{{ item.examinationType }}</span>
            </div>
            <div class="info-item">
              <span class="label">检查部位</span>
              <span class="value">{{ item.bodyPart }}</span>
            </div>
            <div class="info-item">
              <span class="label">诊断医生</span>
              <span class="value">{{ item.doctorName }}</span>
            </div>
            <div class="info-item">
              <span class="label">临床诊断</span>
              <span class="value">{{ item.clinicalDiagnosis || '-' }}</span>
            </div>
          </div>
          <div class="opinion-section">
            <div class="opinion-title">诊断意见</div>
            <div class="opinion-content">{{ item.diagnosticOpinion || '暂无' }}</div>
          </div>
        </div>
        <div class="card-footer">
          <el-button type="primary" size="small" icon="el-icon-view" @click="viewDetail(item)">查看详情</el-button>
        </div>
      </div>

      <div v-if="filteredList.length === 0" class="empty-state">
        <i class="el-icon-s-check"></i>
        <p>暂无诊断报告</p>
      </div>
    </div>

    <!-- 详情弹窗 -->
    <el-dialog title="诊断报告详情" :visible.sync="detailVisible" width="760px">
      <div v-if="currentReport" class="report-detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="报告编号">{{ currentReport.reportNo }}</el-descriptions-item>
          <el-descriptions-item label="报告日期">{{ currentReport.reportDate }}</el-descriptions-item>
          <el-descriptions-item label="检查类型">{{ currentReport.examinationType }}</el-descriptions-item>
          <el-descriptions-item label="检查部位">{{ currentReport.bodyPart }}</el-descriptions-item>
          <el-descriptions-item label="诊断医生">{{ currentReport.doctorName }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="currentReport.reportStatus === 'submitted' ? 'success' : 'info'" size="small">
              {{ currentReport.reportStatus === 'submitted' ? '已归档' : '待审核' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="临床诊断" :span="2">{{ currentReport.clinicalDiagnosis || '-' }}</el-descriptions-item>
        </el-descriptions>

        <div class="dialog-section">
          <h3>检查所见</h3>
          <p>{{ currentReport.examinationFindings || '暂无' }}</p>
        </div>
        <div class="dialog-section highlight">
          <h3>诊断意见</h3>
          <p>{{ currentReport.diagnosticOpinion || '暂无' }}</p>
        </div>
        <div class="dialog-section" v-if="currentReport.treatment">
          <h3>治疗建议</h3>
          <p>{{ currentReport.treatment }}</p>
        </div>
      </div>
      <span slot="footer">
        <el-button @click="detailVisible = false">关闭</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import { getVisitRecords } from '@/api/appointment'
import { getToken } from '@/utils/auth'
import { getCookie } from '@/utils/cookies'

const REPORT_KEY = 'ylz_demo_reports'

export default {
  name: 'reportQuery',
  data() {
    return {
      isDemo: false,
      reportList: [],
      searchKeyword: '',
      filterType: '',
      detailVisible: false,
      currentReport: null
    }
  },
  computed: {
    filteredList() {
      return this.reportList.filter(item => {
        const matchKeyword = !this.searchKeyword ||
          item.reportNo.includes(this.searchKeyword) ||
          item.examinationType.includes(this.searchKeyword)
        const matchType = !this.filterType || item.examinationType === this.filterType
        return matchKeyword && matchType
      })
    }
  },
  created() {
    const token = getToken()
    this.isDemo = token && token.indexOf('demo-token') !== -1
    this.loadReports()
  },
  methods: {
    getPatientIdByAccount() {
      const username = getCookie('username') || sessionStorage.getItem('accountID') || 'patient1'
      const map = { patient1: 30001, patient2: 30002, patient3: 30003, patient4: 30004 }
      return map[username] || 30001
    },
    getDemoReports() {
      const patientId = this.getPatientIdByAccount()
      let reports = []
      try {
        reports = JSON.parse(localStorage.getItem(REPORT_KEY) || '[]')
      } catch (e) {
        reports = []
      }
      if (!reports.length) {
        reports = [
          { id: 20001, reportNo: 'YLZ-R-20260526001', imagingId: 10002, patientId: 30002, patientName: '李娜', gender: '女', age: 33, phone: '13810010002', doctorName: '林医生', reportDate: '2026-05-26 11:05:00', examinationType: 'CT', bodyPart: '头颅', clinicalDiagnosis: '头痛待查', examinationFindings: '头颅CT平扫示脑实质密度未见明显异常，脑室系统形态大小正常，中线结构居中。', diagnosticOpinion: '头颅CT未见明确急性异常征象。建议结合神经内科查体及随访。', treatment: '建议休息，监测血压；如头痛加重或伴呕吐、肢体无力，及时复诊。', reportStatus: 'submitted' },
          { id: 20002, reportNo: 'YLZ-R-20260524001', imagingId: 10004, patientId: 30004, patientName: '赵敏', gender: '女', age: 41, phone: '13810010004', doctorName: '韩医生', reportDate: '2026-05-24 15:00:00', examinationType: '超声', bodyPart: '腹部', clinicalDiagnosis: '右上腹不适', examinationFindings: '肝胆胰脾超声检查，胆囊壁稍毛糙，未见明显结石声影。', diagnosticOpinion: '胆囊壁轻度改变，建议结合肝胆功能检查。', treatment: '清淡饮食，必要时消化内科复诊。', reportStatus: 'submitted' },
          { id: 20003, reportNo: 'YLZ-R-20260528001', imagingId: 10001, patientId: 30001, patientName: '张明', gender: '男', age: 46, phone: '13810010001', doctorName: '沈放射', reportDate: '2026-05-28 14:30:00', examinationType: 'CT', bodyPart: '胸部', clinicalDiagnosis: '咳嗽伴胸痛', examinationFindings: '右肺上叶见一大小约2.3cm×1.8cm结节影，边缘毛糙，分叶征阳性。纵隔未见明显肿大淋巴结。', diagnosticOpinion: '右肺上叶结节，建议进一步检查排除恶性可能。', treatment: '建议完善增强CT及肿瘤标志物检查，必要时穿刺活检。', reportStatus: 'submitted' }
        ]
        localStorage.setItem(REPORT_KEY, JSON.stringify(reports))
      }
      return reports.filter(item => Number(item.patientId) === Number(patientId))
    },
    loadReports() {
      if (this.isDemo) {
        this.reportList = this.getDemoReports()
        return
      }
      const username = getCookie('username')
      const cardId = sessionStorage.getItem('accountID') || username
      getVisitRecords(cardId, 1, 50).then(res => {
        if (res.code === 200 && res.data && res.data.list) {
          this.reportList = res.data.list
            .filter(item => item.report)
            .map(item => item.report)
        }
      }).catch(() => {
        this.reportList = this.getDemoReports()
      })
    },
    viewDetail(row) {
      this.currentReport = row
      this.detailVisible = true
    }
  }
}
</script>

<style lang="scss" scoped>
$primary: #075f42;
$primary-light: #20a978;

.report-query {
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

.filter-bar {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  background: white;
  padding: 16px 20px;
  border-radius: 8px;
  border: 1px solid rgba(0, 122, 77, 0.08);
  box-shadow: 0 2px 12px rgba(8, 83, 61, 0.05);
}

.report-cards {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.report-card {
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
  .report-no {
    font-size: 15px;
    font-weight: 600;
    color: #333;
  }
  .report-date {
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

.opinion-section {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #eee;
  .opinion-title {
    font-size: 14px;
    font-weight: 600;
    color: #333;
    margin-bottom: 8px;
  }
  .opinion-content {
    font-size: 14px;
    color: #666;
    line-height: 1.6;
    background: #f8faf9;
    padding: 12px 16px;
    border-radius: 8px;
  }
}

.card-footer {
  padding: 12px 24px;
  border-top: 1px solid #eee;
  text-align: right;
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

.report-detail {
  .dialog-section {
    margin-top: 16px;
    padding: 16px;
    background: #f8faf9;
    border-radius: 8px;

    h3 {
      margin: 0 0 10px;
      color: $primary;
      font-size: 15px;
    }

    p {
      margin: 0;
      color: #4b5563;
      line-height: 1.8;
      white-space: pre-wrap;
    }

    &.highlight {
      background: #f0f9f5;
      border: 1px solid #d8eee5;
    }
  }
}
</style>
