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
          <div class="report-section" v-if="item.report">
            <div class="case-title">诊断报告</div>
            <div class="report-brief">
              <span>{{ item.report.reportNo }}</span>
              <span>{{ item.report.examinationType }} / {{ item.report.bodyPart }}</span>
              <el-button type="text" icon="el-icon-view" @click="openReport(item.report)">查看报告</el-button>
            </div>
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

    <el-dialog title="诊断报告详情" :visible.sync="reportDialog.visible" width="760px">
      <div v-if="reportDialog.data" class="patient-report-detail">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="报告编号">{{ reportDialog.data.reportNo }}</el-descriptions-item>
          <el-descriptions-item label="报告日期">{{ reportDialog.data.reportDate }}</el-descriptions-item>
          <el-descriptions-item label="检查类型">{{ reportDialog.data.examinationType }}</el-descriptions-item>
          <el-descriptions-item label="检查部位">{{ reportDialog.data.bodyPart }}</el-descriptions-item>
          <el-descriptions-item label="诊断医生">{{ reportDialog.data.doctorName }}</el-descriptions-item>
          <el-descriptions-item label="状态">已归档</el-descriptions-item>
        </el-descriptions>
        <div class="dialog-report-section">
          <h3>检查所见</h3>
          <p>{{ reportDialog.data.examinationFindings || '暂无' }}</p>
        </div>
        <div class="dialog-report-section highlight">
          <h3>诊断意见</h3>
          <p>{{ reportDialog.data.diagnosticOpinion || '暂无' }}</p>
        </div>
        <div class="dialog-report-section" v-if="reportDialog.data.medsamResult">
          <h3>影像标注归档</h3>
          <p>
            {{ getArchiveTitle(reportDialog.data.medsamResult) }}；
            {{ getPromptText(reportDialog.data.medsamResult) }}；
            人工标注 {{ getManualCount(reportDialog.data.medsamResult) }} 条；
            测量 {{ getMeasurementText(reportDialog.data.medsamResult) }}；
            数据文件 {{ getVolumeFile(reportDialog.data.medsamResult, 'source') }}；
            标注文件 {{ getVolumeFile(reportDialog.data.medsamResult, 'label') }}。
          </p>
        </div>
      </div>
      <span slot="footer">
        <el-button @click="reportDialog.visible = false">关闭</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import { getVisitRecords } from '@/api/appointment'
import { getToken } from '@/utils/auth'
import { getCookie } from '@/utils/cookies'

const REPORT_KEY = 'ylz_demo_reports'
const IMAGING_KEY = 'ylz_demo_imagings'

export default {
  name: 'visitRecords',
  data() {
    return {
      isDemo: false,
      recordList: [],
      reportDialog: {
        visible: false,
        data: null
      },
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
    getPatientIdByAccount() {
      const username = getCookie('username') || sessionStorage.getItem('accountID') || 'patient1'
      const map = { patient1: 30001, patient2: 30002, patient3: 30003, patient4: 30004 }
      return map[username] || 30001
    },
    getStoredReports() {
      let reports = []
      try {
        reports = JSON.parse(localStorage.getItem(REPORT_KEY) || '[]')
      } catch (e) {
        reports = []
      }
      if (reports.length) return reports
      reports = [
        { id: 20001, reportNo: 'YLZ-R-20260526001', imagingId: 10002, patientId: 30002, patientName: '李娜', gender: '女', age: 33, phone: '13810010002', doctorName: '林医生', reportDate: '2026-05-26 11:05:00', examinationType: 'CT', bodyPart: '头颅', clinicalDiagnosis: '头痛待查', examinationFindings: '头颅CT平扫示脑实质密度未见明显异常，脑室系统形态大小正常，中线结构居中。', diagnosticOpinion: '头颅CT未见明确急性异常征象。建议结合神经内科查体及随访。', treatment: '建议休息，监测血压；如头痛加重或伴呕吐、肢体无力，及时复诊。', reportStatus: 'submitted' },
        { id: 20002, reportNo: 'YLZ-R-20260524001', imagingId: 10004, patientId: 30004, patientName: '赵敏', gender: '女', age: 41, phone: '13810010004', doctorName: '韩医生', reportDate: '2026-05-24 15:00:00', examinationType: '超声', bodyPart: '腹部', clinicalDiagnosis: '右上腹不适', examinationFindings: '肝胆胰脾超声检查，胆囊壁稍毛糙，未见明显结石声影。', diagnosticOpinion: '胆囊壁轻度改变，建议结合肝胆功能检查。', treatment: '清淡饮食，必要时消化内科复诊。', reportStatus: 'submitted' }
      ]
      localStorage.setItem(REPORT_KEY, JSON.stringify(reports))
      return reports
    },
    getStoredImagings() {
      try {
        return JSON.parse(localStorage.getItem(IMAGING_KEY) || '[]')
      } catch (e) {
        return []
      }
    },
    getDemoRecords() {
      const patientId = this.getPatientIdByAccount()
      const imagings = this.getStoredImagings()
      const reportRecords = this.getStoredReports()
        .filter(item => Number(item.patientId) === Number(patientId))
        .map(item => {
          const imaging = imagings.find(img => Number(img.id) === Number(item.imagingId)) || {}
          return {
            id: 'report-' + item.id,
            cardId: getCookie('username') || 'patient1',
            doctorName: item.doctorName || '主治医生',
            specialName: item.bodyPart + '影像诊断',
            date: (item.reportDate || '').slice(0, 10),
            time: 1,
            status: 1,
            diagnosis: item.diagnosticOpinion,
            caseInfo: item.examinationFindings,
            report: Object.assign({}, item, { medsamResult: item.medsamResult || imaging.medsamResult || null })
          }
        })
      const baseRecords = [
        { id: 1, cardId: 'patient1', doctorName: '林知远', specialName: '呼吸内科', date: '2026-05-25', time: 2, status: 1, diagnosis: '上呼吸道感染', caseInfo: '患者因咳嗽、低热就诊。建议多饮水，按医嘱复诊。' },
        { id: 2, cardId: 'patient1', doctorName: '许明序', specialName: '骨科', date: '2026-05-20', time: 1, status: 1, diagnosis: '腰椎间盘突出', caseInfo: 'MRI提示腰椎退变，建议保守治疗并定期复查。' }
      ]
      return reportRecords.concat(baseRecords)
    },
    openReport(report) {
      this.reportDialog = {
        visible: true,
        data: report
      }
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
    },
    getArchiveTitle(result) {
      if (!result) return '影像标注归档'
      return result.workflowMode === 'manual-first' ? '人工分割标注归档' : 'MedSAM 分割归档'
    },
    getPromptText(result) {
      if (!result || !result.promptBox) return '暂无 Box Prompt'
      return `Box Prompt x=${result.promptBox.x}, y=${result.promptBox.y}, w=${result.promptBox.w}, h=${result.promptBox.h}`
    },
    getManualCount(result) {
      if (!result) return 0
      if (result.annotationMarks) return result.annotationMarks.filter(item => item.type !== 'ruler').length
      if (result.manualAnnotations) return result.manualAnnotations.length
      return 0
    },
    getMeasurementText(result) {
      if (!result || !result.measurements) return '暂无'
      return `${result.measurements.area || '-'} mm² / ${result.measurements.volume || '-'} cm³`
    },
    getVolumeFile(result, type) {
      if (!result) return '暂无'
      const meta = result.datasetMeta || {}
      const source = result.sourceVolume || meta.sourceVolume || {}
      const label = result.labelVolume || meta.labelVolume || {}
      return type === 'source' ? (source.fileName || 'lung_001.nii.gz') : (label.fileName || 'lung_001.nii（标注）.gz')
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

.report-section {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #eef2f0;
}

.report-brief {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
  background: #f0f9f5;
  border: 1px solid #d8eee5;
  border-radius: 8px;
  padding: 12px 16px;

  span {
    color: #24312d;
    font-size: 14px;
  }
}

.patient-report-detail {
  .dialog-report-section {
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
