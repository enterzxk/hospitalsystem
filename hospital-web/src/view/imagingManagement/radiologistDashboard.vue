<template>
  <div class="radiologist-dashboard">
    <div class="dashboard-header">
      <h2>放射科医生工作台</h2>
      <div class="header-info">
        <el-tag type="success">在线</el-tag>
        <span class="doctor-name">{{ doctorName }}</span>
      </div>
    </div>

    <el-row :gutter="20">
      <!-- 左侧：待诊断列表 -->
      <el-col :span="8">
        <el-card class="task-card">
          <div slot="header" class="card-header">
            <span>待诊断影像</span>
            <el-badge :value="pendingList.length" type="danger">
              <el-button size="mini" type="primary" @click="refreshPending">刷新</el-button>
            </el-badge>
          </div>
          <div class="task-list">
            <div
              v-for="item in pendingList"
              :key="item.id"
              class="task-item"
              :class="{ active: selectedImaging && selectedImaging.id === item.id }"
              @click="selectImaging(item)"
            >
              <div class="task-info">
                <div class="patient-name">{{ item.patientName }}</div>
                <div class="task-meta">
                  <el-tag size="mini">{{ item.type }}</el-tag>
                  <span>{{ item.bodyPart }}</span>
                  <span class="time">{{ item.uploadTime }}</span>
                </div>
              </div>
              <el-button size="mini" type="primary" icon="el-icon-view">查看</el-button>
            </div>
            <div v-if="pendingList.length === 0" class="empty-tip">
              暂无待诊断影像
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- 中间：影像预览 -->
      <el-col :span="10">
        <el-card class="preview-card">
          <div slot="header" class="card-header">
            <span>影像预览</span>
            <el-button-group>
              <el-button size="mini" @click="prevSlice">上一层</el-button>
              <el-button size="mini">{{ currentSlice + 1 }} / {{ totalSlices }}</el-button>
              <el-button size="mini" @click="nextSlice">下一层</el-button>
            </el-button-group>
          </div>
          <div class="preview-area" v-if="selectedImaging">
            <div class="film-board">
              <div class="film-header">
                <span>{{ selectedImaging.type }}</span>
                <span>{{ selectedImaging.bodyPart }}</span>
              </div>
              <div class="scan-visual" :class="previewClass">
                <span class="scan-ring ring-one"></span>
                <span class="scan-ring ring-two"></span>
                <span class="scan-line"></span>
              </div>
              <div class="film-footer">
                <span>{{ selectedImaging.patientName }}</span>
                <span>{{ selectedImaging.uploadTime }}</span>
              </div>
            </div>
            <div class="preview-actions">
              <el-button type="primary" icon="el-icon-view" @click="openViewer">打开查看器</el-button>
            </div>
          </div>
          <div v-else class="empty-preview">
            <i class="el-icon-picture-outline"></i>
            <p>请选择要查看的影像</p>
          </div>
        </el-card>
      </el-col>

      <!-- 右侧：快捷操作 -->
      <el-col :span="6">
        <el-card class="action-card">
          <div slot="header">
            <span>快捷操作</span>
          </div>
          <div class="action-list">
            <el-button class="action-btn" @click="goToUpload">
              <i class="el-icon-upload2"></i>
              <span>上传影像</span>
            </el-button>
            <el-button class="action-btn" @click="goToViewerList">
              <i class="el-icon-view"></i>
              <span>影像浏览</span>
            </el-button>
          </div>
        </el-card>

        <el-card class="tumor-card" style="margin-top: 20px">
          <div slot="header">
            <span>肿瘤切片参考</span>
          </div>
          <div class="tumor-reference">
            <div class="tumor-slice">
              <div class="slice-visual lung-slice">
                <div class="slice-overlay">
                  <span class="slice-label">肺窗</span>
                </div>
                <div class="tumor-region"></div>
              </div>
              <span class="slice-title">肺部 CT 薄层</span>
            </div>
            <div class="tumor-slice">
              <div class="slice-visual brain-slice">
                <div class="slice-overlay">
                  <span class="slice-label">增强</span>
                </div>
                <div class="tumor-region brain-region"></div>
              </div>
              <span class="slice-title">头颅 MRI</span>
            </div>
            <div class="tumor-info">
              <div class="info-row">
                <span class="info-label">标注工具</span>
                <span class="info-value">框选 / 画笔 / 擦除</span>
              </div>
              <div class="info-row">
                <span class="info-label">AI 辅助</span>
                <span class="info-value">MedSAM 一键分割</span>
              </div>
              <div class="info-row">
                <span class="info-label">导出格式</span>
                <span class="info-value">JSON / NIfTI Mask</span>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
import { getImagingList } from '@/api/imaging'

const IMAGING_KEY = 'ylz_demo_imagings'
const defaultImagings = [
  { id: 10001, patientId: 30001, patientName: '张明', gender: '男', age: 46, phone: '13810010001', type: 'CT', bodyPart: '胸部', uploadTime: '2026-05-26 09:20:00', doctorName: '沈放射', fileSize: '114.8MB', diagnosisStatus: 'pending', radiologyStatus: '待标注', remark: '胸部 CT 肺窗薄层扫描，已导入 lung_001.nii.gz，需完成肺部病灶人工标注。' },
  { id: 10002, patientId: 30002, patientName: '李娜', gender: '女', age: 33, phone: '13810010002', type: 'CT', bodyPart: '头颅', uploadTime: '2026-05-26 10:15:00', doctorName: '林医生', fileSize: '18.4MB', diagnosisStatus: 'completed', reportId: 20001, remark: '头痛一周，头颅CT平扫。' },
  { id: 10003, patientId: 30003, patientName: '周强', gender: '男', age: 58, phone: '13810010003', type: 'MRI', bodyPart: '腰椎', uploadTime: '2026-05-25 15:40:00', doctorName: '韩医生', fileSize: '35.6MB', diagnosisStatus: 'pending', remark: '腰痛伴左下肢放射痛。' },
  { id: 10005, patientId: 30005, patientName: '陈晨', gender: '男', age: 27, phone: '13810010005', type: 'CT', bodyPart: '胸部', uploadTime: '2026-05-23 11:30:00', doctorName: '林医生', fileSize: '22.0MB', diagnosisStatus: 'pending', remark: '胸闷气短，胸部CT薄层扫描。' }
]

export default {
  name: 'radiologistDashboard',
  data() {
    return {
      doctorName: '医生',
      pendingList: [],
      selectedImaging: null,
      currentSlice: 0,
      totalSlices: 1,
      stats: {
        todayTotal: 12,
        todayDiagnosed: 8,
        todayPending: 4
      }
    }
  },
  computed: {
    previewClass() {
      if (!this.selectedImaging) return ''
      const type = this.selectedImaging.type || ''
      if (type === 'CT') return 'is-ct'
      if (type === 'MRI') return 'is-mri'
      if (type === '超声') return 'is-ultrasound'
      return 'is-xray'
    }
  },
  created() {
    this.loadPendingList()
  },
  methods: {
    ensureDemoImagings() {
      try {
        const saved = localStorage.getItem(IMAGING_KEY)
        if (saved) {
          const list = JSON.parse(saved)
          return list.map(item => {
            if (Number(item.id) !== 10001) return item
            return Object.assign({}, item, {
              type: 'CT',
              bodyPart: '胸部',
              doctorName: item.doctorName || '沈放射',
              fileSize: '114.8MB',
              radiologyStatus: item.radiologyStatus || '待标注',
              remark: item.remark && item.remark.indexOf('lung_001') !== -1 ? item.remark : defaultImagings[0].remark
            })
          })
        }
      } catch (e) {
        localStorage.removeItem(IMAGING_KEY)
      }
      localStorage.setItem(IMAGING_KEY, JSON.stringify(defaultImagings))
      return defaultImagings
    },
    normalizeImaging(item) {
      return {
        id: item.id,
        patientId: item.patientId,
        patientName: item.patientName || item.name || '未知患者',
        type: item.type || item.imagingType || 'CT',
        bodyPart: item.bodyPart || item.body_part || '胸部',
        uploadTime: item.uploadTime || item.upload_time || item.gmtCreate || '',
        diagnosisStatus: item.diagnosisStatus === 1 ? 'completed' : (item.diagnosisStatus || 'pending'),
        remark: item.remark || item.description || ''
      }
    },
    getLocalPendingList() {
      return this.ensureDemoImagings()
        .map(this.normalizeImaging)
        .filter(item => item.diagnosisStatus !== 'completed')
    },
    loadPendingList() {
      getImagingList({
        diagnosisStatus: 0,
        pageNum: 1,
        pageSize: 20
      }).then(res => {
        if (res.code === 200) {
          const apiList = res.data && res.data.list ? res.data.list.map(this.normalizeImaging) : []
          this.pendingList = apiList.length ? apiList : this.getLocalPendingList()
        }
      }).catch(e => {
        console.error('加载待诊断列表失败:', e)
        this.pendingList = this.getLocalPendingList()
      }).finally(() => {
        this.stats.todayPending = this.pendingList.length
        this.stats.todayTotal = this.ensureDemoImagings().length
        this.stats.todayDiagnosed = Math.max(0, this.stats.todayTotal - this.stats.todayPending)
      })
    },

    refreshPending() {
      this.loadPendingList()
      this.$message.success('列表已刷新')
    },

    selectImaging(item) {
      this.selectedImaging = item
      this.currentSlice = 0
    },

    prevSlice() {
      if (this.currentSlice > 0) {
        this.currentSlice--
      }
    },

    nextSlice() {
      if (this.currentSlice < this.totalSlices - 1) {
        this.currentSlice++
      }
    },

    openViewer() {
      if (!this.selectedImaging) return
      this.$router.push({
        path: '/imagingViewer',
        query: { id: this.selectedImaging.id }
      })
    },

    goToUpload() {
      this.$router.push('/imagingUpload')
    },

    goToViewerList() {
      this.$router.push('/imagingList')
    }
  }
}
</script>

<style lang="scss" scoped>
.radiologist-dashboard {
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
.preview-card,
.action-card,
.stats-card {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.task-list {
  max-height: 500px;
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

.preview-area {
  text-align: center;
}

.film-board {
  width: 100%;
  max-width: 500px;
  margin: 0 auto;
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

.preview-actions {
  margin-top: 20px;
  display: flex;
  justify-content: center;
  gap: 10px;
}

.empty-preview {
  text-align: center;
  padding: 60px 0;
  color: #999;

  i {
    font-size: 48px;
    margin-bottom: 10px;
  }
}

.action-list {
  display: flex;
  flex-direction: column;
  gap: 10px;

  .action-btn {
    width: 100%;
    height: 50px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    border: 1px solid #eee;
    border-radius: 8px;
    transition: all 0.3s;

    i {
      font-size: 20px;
      margin-bottom: 5px;
      color: #409eff;
    }

    span {
      font-size: 13px;
      color: #666;
    }

    &:hover {
      border-color: #409eff;
      background: #f5f7fa;
    }
  }
}

.stats-list {
  display: flex;
  justify-content: space-between;

  .stat-item {
    text-align: center;

    .stat-value {
      font-size: 24px;
      font-weight: bold;
      color: #409eff;
    }

    .stat-label {
      font-size: 12px;
      color: #999;
      margin-top: 5px;
    }
  }
}

.tumor-reference {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.tumor-slice {
  text-align: center;

  .slice-title {
    display: block;
    font-size: 12px;
    color: #666;
    margin-top: 6px;
  }
}

.slice-visual {
  position: relative;
  width: 100%;
  aspect-ratio: 4 / 3;
  border-radius: 6px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.lung-slice {
  background:
    radial-gradient(circle at 45% 50%, rgba(200, 210, 220, 0.6), rgba(100, 120, 140, 0.3) 40%, rgba(30, 40, 50, 0.9) 70%),
    linear-gradient(180deg, #1a2332, #0d1520);
}

.brain-slice {
  background:
    radial-gradient(ellipse at 50% 45%, rgba(180, 190, 200, 0.5), rgba(80, 100, 120, 0.3) 35%, rgba(20, 30, 40, 0.92) 65%),
    linear-gradient(135deg, #1e293b, #0f172a);
}

.slice-overlay {
  position: absolute;
  top: 6px;
  left: 6px;

  .slice-label {
    padding: 2px 8px;
    border-radius: 3px;
    background: rgba(64, 158, 255, 0.85);
    color: white;
    font-size: 11px;
  }
}

.tumor-region {
  position: absolute;
  width: 35%;
  height: 40%;
  top: 30%;
  left: 38%;
  border: 2px solid rgba(255, 82, 82, 0.8);
  border-radius: 50%;
  background: radial-gradient(circle, rgba(255, 82, 82, 0.2), transparent 70%);

  &::after {
    content: '病灶';
    position: absolute;
    top: -18px;
    left: 50%;
    transform: translateX(-50%);
    font-size: 10px;
    color: #ff5252;
    white-space: nowrap;
  }
}

.brain-region {
  width: 28%;
  height: 30%;
  top: 35%;
  left: 40%;
  border-color: rgba(255, 193, 7, 0.8);
  background: radial-gradient(circle, rgba(255, 193, 7, 0.2), transparent 70%);

  &::after {
    content: '异常区';
    color: #ffc107;
  }
}

.tumor-info {
  background: #f8f9fa;
  border-radius: 6px;
  padding: 10px 12px;

  .info-row {
    display: flex;
    justify-content: space-between;
    padding: 5px 0;
    font-size: 12px;
    border-bottom: 1px solid #eee;

    &:last-child {
      border-bottom: none;
    }

    .info-label {
      color: #999;
    }

    .info-value {
      color: #333;
      font-weight: 500;
    }
  }
}
</style>
