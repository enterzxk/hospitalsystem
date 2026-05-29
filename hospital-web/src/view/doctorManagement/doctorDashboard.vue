<template>
  <div class="doctor-dashboard">
    <div class="dashboard-header">
      <h2>主治医生工作台</h2>
      <div class="header-info">
        <el-tag type="success">在线</el-tag>
        <span class="doctor-name">{{ doctorName }}</span>
      </div>
    </div>

    <el-row :gutter="20">
      <!-- 左侧：待诊断患者 -->
      <el-col :span="10">
        <el-card class="task-card">
          <div slot="header" class="card-header">
            <span>待诊断患者</span>
            <el-badge :value="pendingPatients.length" type="danger">
              <el-button size="mini" type="primary" @click="refreshPending">刷新</el-button>
            </el-badge>
          </div>
          <div class="task-list">
            <div
              v-for="item in pendingPatients"
              :key="item.id"
              class="task-item"
              :class="{ active: selectedPatient && selectedPatient.id === item.id }"
              @click="selectPatient(item)"
            >
              <div class="task-info">
                <div class="patient-name">{{ item.patientName }}</div>
                <div class="task-meta">
                  <el-tag size="mini" :type="item.urgency === '紧急' ? 'danger' : 'info'">{{ item.urgency }}</el-tag>
                  <span>{{ item.department }}</span>
                  <span class="time">{{ item.date }}</span>
                </div>
              </div>
              <el-button size="mini" type="primary" icon="el-icon-view">查看</el-button>
            </div>
            <div v-if="pendingPatients.length === 0" class="empty-tip">
              暂无待诊断患者
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 中间：患者详情 -->
      <el-col :span="14">
        <el-card class="detail-card">
          <div slot="header" class="card-header">
            <span>患者详情</span>
          </div>
          <div v-if="selectedPatient" class="patient-detail">
            <el-descriptions :column="2" border>
              <el-descriptions-item label="患者姓名">{{ selectedPatient.patientName }}</el-descriptions-item>
              <el-descriptions-item label="性别">{{ selectedPatient.gender }}</el-descriptions-item>
              <el-descriptions-item label="年龄">{{ selectedPatient.age }}岁</el-descriptions-item>
              <el-descriptions-item label="联系方式">{{ selectedPatient.phone }}</el-descriptions-item>
              <el-descriptions-item label="就诊科室">{{ selectedPatient.department }}</el-descriptions-item>
              <el-descriptions-item label="紧急程度">
                <el-tag :type="selectedPatient.urgency === '紧急' ? 'danger' : 'info'">{{ selectedPatient.urgency }}</el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="症状描述" :span="2">{{ selectedPatient.symptoms }}</el-descriptions-item>
            </el-descriptions>

            <div class="radiology-section" v-if="selectedPatient.radiologyResult">
              <h4>放射科诊断结果</h4>
              <el-card shadow="never" class="radiology-result">
                <div class="result-header">
                  <span class="result-type">{{ selectedPatient.radiologyResult.type }}</span>
                  <span class="result-date">{{ selectedPatient.radiologyResult.date }}</span>
                </div>
                <div class="result-content">
                  <p><strong>检查所见：</strong>{{ selectedPatient.radiologyResult.findings }}</p>
                  <p><strong>诊断意见：</strong>{{ selectedPatient.radiologyResult.opinion }}</p>
                </div>
                <div class="result-images" v-if="selectedPatient.radiologyResult.images">
                  <span class="image-tag" v-for="(img, idx) in selectedPatient.radiologyResult.images" :key="idx">
                    <i class="el-icon-picture-outline"></i> {{ img }}
                  </span>
                </div>
              </el-card>
            </div>
            <div v-else class="no-radiology">
              <i class="el-icon-warning"></i>
              <span>暂无放射科诊断结果</span>
            </div>

            <div class="action-buttons">
              <el-button type="primary" icon="el-icon-edit" @click="openDiagnosis">填写诊断</el-button>
              <el-button type="info" icon="el-icon-document" @click="viewHistory">查看病历</el-button>
            </div>
          </div>
          <div v-else class="empty-detail">
            <i class="el-icon-user"></i>
            <p>请选择要查看的患者</p>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
const DEMO_PATIENTS = [
  {
    id: 1,
    patientName: '张明',
    gender: '男',
    age: 46,
    phone: '13810010001',
    department: '呼吸内科',
    urgency: '紧急',
    date: '2026-05-29',
    symptoms: '咳嗽伴胸痛两周，加重3天。既往有吸烟史20年。',
    radiologyResult: {
      type: 'CT',
      date: '2026-05-28',
      findings: '右肺上叶见一大小约2.3cm×1.8cm结节影，边缘毛糙，分叶征阳性。纵隔未见明显肿大淋巴结。',
      opinion: '右肺上叶结节，建议进一步检查排除恶性可能。',
      images: ['lung_001.nii.gz']
    }
  },
  {
    id: 2,
    patientName: '李娜',
    gender: '女',
    age: 33,
    phone: '13810010002',
    department: '神经内科',
    urgency: '普通',
    date: '2026-05-29',
    symptoms: '头痛一周，呈搏动性，伴有恶心。无发热、无意识障碍。',
    radiologyResult: {
      type: 'MRI',
      date: '2026-05-27',
      findings: '头颅MRI平扫未见明显异常信号影。脑室系统形态正常，中线结构居中。',
      opinion: '头颅MRI未见明显异常。建议结合临床，必要时进一步检查。',
      images: []
    }
  },
  {
    id: 3,
    patientName: '周强',
    gender: '男',
    age: 58,
    phone: '13810010003',
    department: '骨科',
    urgency: '普通',
    date: '2026-05-28',
    symptoms: '腰痛伴左下肢放射痛3个月，弯腰加重。直腿抬高试验阳性。',
    radiologyResult: null
  },
  {
    id: 4,
    patientName: '陈晨',
    gender: '男',
    age: 27,
    phone: '13810010005',
    department: '呼吸内科',
    urgency: '紧急',
    date: '2026-05-29',
    symptoms: '胸闷气短2天，活动后加重。无发热、无咳痰。',
    radiologyResult: {
      type: 'CT',
      date: '2026-05-28',
      findings: '双肺纹理增粗，右肺下叶见片状模糊影，边界不清。',
      opinion: '右肺下叶炎症可能大，建议抗感染治疗后复查。',
      images: ['chest_002.nii.gz']
    }
  }
]

export default {
  name: 'doctorDashboard',
  data() {
    return {
      doctorName: '医生',
      pendingPatients: [],
      selectedPatient: null
    }
  },
  created() {
    this.loadPendingPatients()
    this.doctorName = sessionStorage.getItem('username') || '医生'
  },
  methods: {
    loadPendingPatients() {
      this.pendingPatients = DEMO_PATIENTS
    },
    refreshPending() {
      this.loadPendingPatients()
      this.$message.success('列表已刷新')
    },
    selectPatient(item) {
      this.selectedPatient = item
    },
    openDiagnosis() {
      if (!this.selectedPatient) return
      this.$router.push({
        path: '/diagnosisWrite',
        query: { patientId: this.selectedPatient.id }
      })
    },
    viewHistory() {
      if (!this.selectedPatient) return
      this.$message.info('病历查看功能开发中')
    }
  }
}
</script>

<style lang="scss" scoped>
.doctor-dashboard {
  padding: 20px;
  background: #f5f7fa;
  min-height: 100vh;
}

.dashboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;

  h2 {
    margin: 0;
    font-size: 22px;
    color: #333;
  }

  .header-info {
    display: flex;
    align-items: center;
    gap: 10px;

    .doctor-name {
      font-size: 16px;
      color: #666;
    }
  }
}

.task-card,
.detail-card {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.task-list {
  max-height: 600px;
  overflow-y: auto;
}

.task-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  border: 1px solid #eee;
  border-radius: 8px;
  margin-bottom: 10px;
  cursor: pointer;
  transition: all 0.3s;

  &:hover {
    border-color: #409eff;
    background: #f5f7fa;
  }

  &.active {
    border-color: #409eff;
    background: #ecf5ff;
  }

  .task-info {
    flex: 1;

    .patient-name {
      font-size: 16px;
      font-weight: bold;
      color: #333;
      margin-bottom: 5px;
    }

    .task-meta {
      display: flex;
      align-items: center;
      gap: 10px;
      font-size: 13px;
      color: #999;

      .time {
        margin-left: auto;
      }
    }
  }
}

.empty-tip {
  text-align: center;
  color: #999;
  padding: 40px 0;
}

.patient-detail {
  padding: 10px;
}

.radiology-section {
  margin-top: 20px;

  h4 {
    margin: 0 0 10px;
    color: #409eff;
    font-size: 16px;
  }
}

.radiology-result {
  background: #f8f9fa;

  .result-header {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;

    .result-type {
      font-weight: bold;
      color: #333;
    }

    .result-date {
      color: #999;
      font-size: 13px;
    }
  }

  .result-content {
    p {
      margin: 8px 0;
      line-height: 1.6;
      color: #555;
    }
  }

  .result-images {
    margin-top: 10px;
    display: flex;
    gap: 10px;

    .image-tag {
      padding: 4px 10px;
      background: #e1f3d8;
      border-radius: 4px;
      font-size: 12px;
      color: #67c23a;

      i {
        margin-right: 4px;
      }
    }
  }
}

.no-radiology {
  margin-top: 20px;
  padding: 20px;
  text-align: center;
  background: #fdf6ec;
  border-radius: 8px;
  color: #e6a23c;

  i {
    font-size: 24px;
    margin-bottom: 8px;
    display: block;
  }
}

.action-buttons {
  margin-top: 20px;
  display: flex;
  gap: 10px;
}

.empty-detail {
  text-align: center;
  padding: 80px 0;
  color: #999;

  i {
    font-size: 48px;
    margin-bottom: 10px;
  }
}
</style>
