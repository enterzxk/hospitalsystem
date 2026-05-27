<template>
  <div class="imaging-detail-page">
    <div class="page-header">
      <h2>影像详情</h2>
      <div class="header-actions">
        <el-button icon="el-icon-view" @click="openViewer">打开查看器</el-button>
        <el-button type="primary" icon="el-icon-edit" @click="handleDiagnose">
          {{ imagingData.diagnosisStatus === 'completed' ? '查看诊断报告' : '填写诊断报告' }}
        </el-button>
        <el-button icon="el-icon-back" @click="goBack">返回列表</el-button>
      </div>
    </div>
    <el-card>
      <el-descriptions title="基本信息" :column="2" border>
        <el-descriptions-item label="影像ID">{{ imagingData.id }}</el-descriptions-item>
        <el-descriptions-item label="患者姓名">{{ imagingData.patientName }}</el-descriptions-item>
        <el-descriptions-item label="性别/年龄">{{ imagingData.gender }} / {{ imagingData.age }}岁</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ imagingData.phone }}</el-descriptions-item>
        <el-descriptions-item label="影像类型">
          <el-tag>{{ imagingData.type }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="检查部位">{{ imagingData.bodyPart }}</el-descriptions-item>
        <el-descriptions-item label="上传时间">{{ imagingData.uploadTime }}</el-descriptions-item>
        <el-descriptions-item label="上传医生">{{ imagingData.doctorName }}</el-descriptions-item>
        <el-descriptions-item label="文件大小">{{ imagingData.fileSize }}</el-descriptions-item>
        <el-descriptions-item label="诊断状态">
          <el-tag :type="imagingData.diagnosisStatus === 'completed' ? 'success' : 'warning'">
            {{ imagingData.diagnosisStatus === 'completed' ? '已诊断' : '待诊断' }}
          </el-tag>
        </el-descriptions-item>
      </el-descriptions>
    </el-card>
    <el-card class="preview-card">
      <div slot="header">
        <span>影像预览</span>
      </div>
      <div class="preview-area">
        <div class="film-board">
          <div class="film-header">
            <span>{{ imagingData.type }}</span>
            <span>{{ imagingData.bodyPart }}</span>
          </div>
          <div class="scan-visual" :class="previewClass">
            <span class="scan-ring ring-one"></span>
            <span class="scan-ring ring-two"></span>
            <span class="scan-line"></span>
          </div>
          <div class="film-footer">
            <span>{{ imagingData.patientName }}</span>
            <span>{{ imagingData.uploadTime }}</span>
          </div>
        </div>
      </div>
    </el-card>
    <el-card class="remark-card">
      <div slot="header">
        <span>检查说明</span>
      </div>
      <p>{{ imagingData.remark || '暂无备注' }}</p>
    </el-card>
  </div>
</template>

<script>
const IMAGING_KEY = 'ylz_demo_imagings';

export default {
  name: 'imagingDetail',
  data() {
    return {
      imagingData: {}
    }
  },
  computed: {
    previewClass() {
      const type = this.imagingData.type || '';
      if (type === 'CT') return 'is-ct';
      if (type === 'MRI') return 'is-mri';
      if (type === '超声') return 'is-ultrasound';
      return 'is-xray';
    }
  },
  methods: {
    goBack() {
      this.$router.push('/imagingList');
    },
    loadData() {
      const list = JSON.parse(localStorage.getItem(IMAGING_KEY) || '[]');
      const id = Number(this.$route.query.id);
      this.imagingData = list.find(item => item.id === id) || list[0] || {};
    },
    handleDiagnose() {
      if (this.imagingData.diagnosisStatus === 'completed' && this.imagingData.reportId) {
        this.$router.push({ path: '/diagnosisDetail', query: { id: this.imagingData.reportId } });
        return;
      }
      this.$router.push({
        path: '/diagnosisWrite',
        query: { imagingId: this.imagingData.id, patientId: this.imagingData.patientId }
      });
    },
    openViewer() {
      if (!this.imagingData.id) return;
      this.$router.push({ path: '/imagingViewer', query: { id: this.imagingData.id } });
    }
  },
  created() {
    this.loadData();
  }
}
</script>

<style lang="scss" scoped>
.imaging-detail-page {
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

  .preview-card,
  .remark-card {
    margin-top: 20px;
  }

  .preview-area {
    min-height: 430px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #eef4f1;
    border-radius: 8px;
  }

  .film-board {
    width: min(620px, 92%);
    aspect-ratio: 4 / 3;
    border-radius: 10px;
    background: #0e1726;
    color: rgba(255, 255, 255, 0.78);
    padding: 18px;
    box-shadow: 0 18px 45px rgba(15, 23, 42, 0.28);
    display: flex;
    flex-direction: column;
  }

  .film-header,
  .film-footer {
    display: flex;
    justify-content: space-between;
    font-size: 13px;
    letter-spacing: 1px;
  }

  .scan-visual {
    position: relative;
    flex: 1;
    margin: 18px 0;
    border-radius: 8px;
    overflow: hidden;
    background:
      radial-gradient(circle at center, rgba(235, 245, 255, 0.42), rgba(89, 116, 148, 0.18) 32%, rgba(9, 18, 33, 0.92) 66%),
      repeating-linear-gradient(90deg, rgba(255, 255, 255, 0.035) 0 1px, transparent 1px 10px);

    &.is-ct {
      background:
        radial-gradient(circle, rgba(237, 242, 247, 0.5), rgba(100, 116, 139, 0.24) 38%, rgba(15, 23, 42, 0.92) 68%),
        repeating-linear-gradient(0deg, rgba(255, 255, 255, 0.04) 0 2px, transparent 2px 12px);
    }

    &.is-mri {
      background:
        radial-gradient(ellipse at center, rgba(218, 232, 255, 0.5), rgba(71, 85, 105, 0.28) 42%, rgba(2, 6, 23, 0.94) 70%),
        linear-gradient(135deg, rgba(32, 169, 120, 0.16), transparent);
    }

    &.is-ultrasound {
      background:
        radial-gradient(ellipse at 48% 30%, rgba(240, 253, 250, 0.42), rgba(15, 118, 110, 0.22) 36%, rgba(4, 47, 46, 0.92) 74%),
        repeating-linear-gradient(110deg, rgba(255, 255, 255, 0.05) 0 1px, transparent 1px 9px);
    }
  }

  .scan-ring {
    position: absolute;
    border: 1px solid rgba(255, 255, 255, 0.28);
    border-radius: 50%;
    inset: 18% 28%;
  }

  .ring-two {
    inset: 28% 37%;
  }

  .scan-line {
    position: absolute;
    left: 0;
    right: 0;
    top: 48%;
    height: 1px;
    background: rgba(255, 255, 255, 0.32);
  }

  .remark-card p {
    margin: 0;
    line-height: 1.8;
    color: #4b5563;
  }
}
</style>
