<template>
  <div class="diagnosis-detail-page">
    <div class="page-header">
      <h2>诊断报告详情</h2>
      <div class="header-actions">
        <el-button icon="el-icon-picture-outline" @click="viewImaging">查看片子</el-button>
        <el-button icon="el-icon-edit" @click="handleEdit">编辑报告</el-button>
        <el-button icon="el-icon-printer" @click="handlePrint">打印报告</el-button>
        <el-button icon="el-icon-back" @click="goBack">返回列表</el-button>
      </div>
    </div>
    <el-card>
      <el-descriptions title="基本信息" :column="2" border>
        <el-descriptions-item label="报告编号">{{ diagnosisData.reportNo }}</el-descriptions-item>
        <el-descriptions-item label="患者姓名">{{ diagnosisData.patientName }}</el-descriptions-item>
        <el-descriptions-item label="性别/年龄">{{ diagnosisData.gender }} / {{ diagnosisData.age }}岁</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ diagnosisData.phone }}</el-descriptions-item>
        <el-descriptions-item label="诊断医生">{{ diagnosisData.doctorName }}</el-descriptions-item>
        <el-descriptions-item label="报告日期">{{ diagnosisData.reportDate }}</el-descriptions-item>
        <el-descriptions-item label="检查类型">{{ diagnosisData.examinationType }}</el-descriptions-item>
        <el-descriptions-item label="检查部位">{{ diagnosisData.bodyPart }}</el-descriptions-item>
        <el-descriptions-item label="状态" :span="2">
          <el-tag :type="diagnosisData.reportStatus === 'submitted' ? 'success' : 'info'">
            {{ diagnosisData.reportStatus === 'submitted' ? '已上传' : '草稿' }}
          </el-tag>
        </el-descriptions-item>
      </el-descriptions>
    </el-card>
    <el-card class="content-card">
      <div slot="header">
        <span>云岚宗医院影像诊断报告</span>
      </div>
      <div class="report-section">
        <h3>临床诊断</h3>
        <p>{{ diagnosisData.clinicalDiagnosis || '暂无' }}</p>
      </div>
      <div class="report-section">
        <h3>检查所见</h3>
        <p>{{ diagnosisData.examinationFindings || '暂无' }}</p>
      </div>
      <div class="report-section highlight">
        <h3>诊断意见</h3>
        <p>{{ diagnosisData.diagnosticOpinion || '暂无' }}</p>
      </div>
      <div class="report-section">
        <h3>处理建议</h3>
        <p>{{ diagnosisData.treatment || '暂无' }}</p>
      </div>
    </el-card>
    <el-card class="imaging-card">
      <div slot="header">
        <span>关联影像</span>
      </div>
      <div class="imaging-item" v-if="imagingData.id" @click="viewImaging">
        <i class="el-icon-picture-outline"></i>
        <span>{{ imagingData.type }} - {{ imagingData.bodyPart }} - {{ imagingData.uploadTime }}</span>
      </div>
      <div class="no-imaging" v-else>暂无关联影像</div>
    </el-card>
  </div>
</template>

<script>
const IMAGING_KEY = 'ylz_demo_imagings';
const REPORT_KEY = 'ylz_demo_reports';

export default {
  name: 'diagnosisDetail',
  data() {
    return {
      diagnosisData: {},
      imagingData: {}
    }
  },
  methods: {
    goBack() {
      this.$router.push('/diagnosisList');
    },
    loadData() {
      const reports = JSON.parse(localStorage.getItem(REPORT_KEY) || '[]');
      const imagings = JSON.parse(localStorage.getItem(IMAGING_KEY) || '[]');
      const id = Number(this.$route.query.id);
      this.diagnosisData = reports.find(item => item.id === id) || reports[0] || {};
      this.imagingData = imagings.find(item => item.id === this.diagnosisData.imagingId) || {};
    },
    viewImaging() {
      if (this.diagnosisData.imagingId) {
        this.$router.push({ path: '/imagingDetail', query: { id: this.diagnosisData.imagingId } });
      }
    },
    handleEdit() {
      if (this.diagnosisData.id) {
        this.$router.push({ path: '/diagnosisWrite', query: { id: this.diagnosisData.id } });
      }
    },
    handlePrint() {
      window.print();
    }
  },
  created() {
    this.loadData();
  }
}
</script>

<style lang="scss" scoped>
.diagnosis-detail-page {
  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;

    h2 {
      margin: 0;
      font-size: 20px;
      color: #333;
    }
  }

  .header-actions {
    display: flex;
    gap: 10px;
  }

  .content-card,
  .imaging-card {
    margin-top: 20px;
  }

  .report-section {
    padding: 18px 20px;
    border-bottom: 1px solid #eef2f7;

    &:last-child {
      border-bottom: none;
    }

    h3 {
      margin: 0 0 10px;
      font-size: 16px;
      color: #075f42;
    }

    p {
      margin: 0;
      color: #374151;
      line-height: 1.9;
      white-space: pre-wrap;
    }

    &.highlight {
      background: #f0f9f5;
      border-radius: 8px;
    }
  }

  .imaging-item {
    display: inline-flex;
    align-items: center;
    padding: 12px 20px;
    background: #f5f7fa;
    border-radius: 8px;
    cursor: pointer;
    transition: background 0.3s;

    &:hover {
      background: #e9f5ef;
    }

    i {
      font-size: 24px;
      color: #20a978;
      margin-right: 10px;
    }

    span {
      font-size: 14px;
      color: #333;
    }
  }

  .no-imaging {
    color: #999;
    text-align: center;
    padding: 40px;
  }
}
</style>
