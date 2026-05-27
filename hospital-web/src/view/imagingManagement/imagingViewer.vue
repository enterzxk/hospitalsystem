<template>
  <div class="imaging-viewer-page">
    <div class="viewer-topbar">
      <div class="case-line">
        <span>患者：{{ imagingData.patientName || '-' }}</span>
        <span>检查：{{ imagingData.type || '-' }}{{ imagingData.bodyPart || '' }}</span>
        <span>序列：{{ currentSeriesIndex + 1 }}/{{ seriesList.length }}</span>
        <span>任务状态：{{ taskStatus }}</span>
        <span>分配医生：{{ assignedDoctor }}</span>
      </div>
      <div class="top-actions">
        <el-button size="mini" icon="el-icon-back" @click="goBack">返回</el-button>
        <el-button size="mini" type="primary" icon="el-icon-edit" @click="submitReport">提交报告</el-button>
      </div>
    </div>

    <div class="viewer-shell">
      <aside class="viewer-sidebar">
        <div class="panel-title">影像序列</div>
        <button
          v-for="(series, index) in seriesList"
          :key="series.name"
          type="button"
          class="list-btn"
          :class="{ active: index === currentSeriesIndex }"
          @click="selectSeries(index)">
          <span>{{ series.name }}</span>
          <small>{{ series.count }}层</small>
        </button>

        <div class="panel-title slice-title">切片列表</div>
        <button
          v-for="slice in visibleSlices"
          :key="slice"
          type="button"
          class="slice-btn"
          :class="{ active: slice === currentSlice }"
          @click="selectSlice(slice)">
          Slice {{ slice }}
        </button>
      </aside>

      <main class="viewer-stage">
        <div class="stage-header">
          <span>医学影像 Viewer（DICOM 演示）</span>
          <span>窗宽：{{ windowWidth }}　窗位：{{ windowCenter }}　缩放：{{ zoomLabel }}</span>
        </div>

        <div
          class="canvas-wrap"
          @mousedown="handlePointerDown"
          @mousemove="handlePointerMove"
          @mouseup="handlePointerUp"
          @mouseleave="handlePointerUp"
          @wheel.prevent="handleWheel">
          <canvas ref="imageCanvas" :width="canvasWidth" :height="canvasHeight"></canvas>
          <canvas ref="maskCanvas" :width="canvasWidth" :height="canvasHeight" class="mask-layer"></canvas>
          <div class="crosshair horizontal"></div>
          <div class="crosshair vertical"></div>
        </div>

        <div class="stage-controls">
          <div class="control-group">
            <span>窗宽/窗位</span>
            <el-button size="mini" @click="adjustWindow(-20, 0)">窗宽-</el-button>
            <el-button size="mini" @click="adjustWindow(20, 0)">窗宽+</el-button>
            <el-button size="mini" @click="adjustWindow(0, -5)">窗位-</el-button>
            <el-button size="mini" @click="adjustWindow(0, 5)">窗位+</el-button>
          </div>
          <div class="control-group">
            <span>缩放</span>
            <el-button size="mini" icon="el-icon-minus" @click="changeZoom(-0.1)"></el-button>
            <el-button size="mini" icon="el-icon-plus" @click="changeZoom(0.1)"></el-button>
          </div>
        </div>
      </main>

      <aside class="viewer-inspector">
        <section class="inspector-card">
          <h3>Prompt 信息</h3>
          <div class="metric-box">
            <p>Box：x={{ promptBox.x }}, y={{ promptBox.y }}</p>
            <p>w={{ promptBox.w }}, h={{ promptBox.h }}</p>
            <p>slice：{{ currentSlice }}/{{ totalSlices }}</p>
          </div>
        </section>

        <section class="inspector-card">
          <h3>AI 质量评分</h3>
          <div class="metric-row">
            <span>Confidence</span>
            <strong>{{ aiScore.confidence }}</strong>
          </div>
          <div class="metric-row">
            <span>Dice(est.)</span>
            <strong>{{ aiScore.dice }}</strong>
          </div>
        </section>

        <section class="inspector-card">
          <h3>测量数据</h3>
          <div class="metric-box">
            <p>面积：{{ measurements.area }} mm²</p>
            <p>体积：{{ measurements.volume }} cm³</p>
            <p>质心：({{ measurements.centerX }}, {{ measurements.centerY }})</p>
          </div>
        </section>

        <section class="inspector-card">
          <h3>病例摘要</h3>
          <p class="case-summary">{{ imagingData.remark || '暂无检查说明。' }}</p>
        </section>
      </aside>
    </div>

    <div class="bottom-toolbar">
      <el-button size="small" icon="el-icon-refresh-left" @click="undo">撤销</el-button>
      <el-button
        size="small"
        :type="tool === 'box' ? 'primary' : ''"
        icon="el-icon-crop"
        @click="setTool('box')">框选</el-button>
      <el-button
        size="small"
        :type="tool === 'pan' ? 'primary' : ''"
        icon="el-icon-rank"
        @click="setTool('pan')">平移</el-button>
      <el-button
        size="small"
        :type="tool === 'brush' ? 'success' : ''"
        icon="el-icon-edit"
        @click="setTool('brush')">补画</el-button>
      <el-button
        size="small"
        :type="tool === 'erase' ? 'warning' : ''"
        icon="el-icon-delete"
        @click="setTool('erase')">擦除</el-button>
      <el-button size="small" type="primary" icon="el-icon-magic-stick" @click="runSegmentation">重新分割</el-button>
      <el-button size="small" type="success" icon="el-icon-check" @click="confirmResult">确认结果</el-button>
      <el-button size="small" type="warning" icon="el-icon-document" @click="submitReport">提交报告</el-button>
    </div>
  </div>
</template>

<script>
import { getImagingInfo } from '@/api/imaging'

const IMAGING_KEY = 'ylz_demo_imagings'
const VIEWER_CONTEXT_KEY = 'ylz_viewer_context'

const defaultImagings = [
  { id: 10001, patientId: 30001, patientName: '张明', gender: '男', age: 46, phone: '13810010001', type: 'X光', bodyPart: '胸部', uploadTime: '2026-05-26 09:20:00', doctorName: '林医生', fileSize: '2.8MB', diagnosisStatus: 'pending', remark: '咳嗽伴低热，胸部正侧位片。' },
  { id: 10002, patientId: 30002, patientName: '李娜', gender: '女', age: 33, phone: '13810010002', type: 'CT', bodyPart: '头颅', uploadTime: '2026-05-26 10:15:00', doctorName: '林医生', fileSize: '18.4MB', diagnosisStatus: 'completed', reportId: 20001, remark: '头痛一周，头颅CT平扫。' },
  { id: 10003, patientId: 30003, patientName: '周强', gender: '男', age: 58, phone: '13810010003', type: 'MRI', bodyPart: '腰椎', uploadTime: '2026-05-25 15:40:00', doctorName: '韩医生', fileSize: '35.6MB', diagnosisStatus: 'pending', remark: '腰痛伴左下肢放射痛。' },
  { id: 10004, patientId: 30004, patientName: '赵敏', gender: '女', age: 41, phone: '13810010004', type: '超声', bodyPart: '腹部', uploadTime: '2026-05-24 14:05:00', doctorName: '韩医生', fileSize: '6.1MB', diagnosisStatus: 'completed', reportId: 20002, remark: '右上腹不适，腹部超声检查。' },
  { id: 10005, patientId: 30005, patientName: '陈晨', gender: '男', age: 27, phone: '13810010005', type: 'CT', bodyPart: '胸部', uploadTime: '2026-05-23 11:30:00', doctorName: '林医生', fileSize: '22.0MB', diagnosisStatus: 'pending', remark: '胸闷气短，胸部CT薄层扫描。' }
]

export default {
  name: 'imagingViewer',
  data() {
    return {
      imagingData: {},
      assignedDoctor: '李医生',
      taskStatus: '标注中',
      tool: 'box',
      currentSeriesIndex: 2,
      currentSlice: 42,
      totalSlices: 128,
      seriesList: [
        { name: '序列1', count: 80 },
        { name: '序列2', count: 96 },
        { name: '序列3', count: 128 },
        { name: '序列4', count: 72 },
        { name: '序列5', count: 64 }
      ],
      canvasWidth: 640,
      canvasHeight: 440,
      windowWidth: 400,
      windowCenter: 40,
      zoom: 1,
      promptBox: { x: 156, y: 89, w: 234, h: 187 },
      aiScore: { confidence: '0.93', dice: '0.91' },
      measurements: { area: '342.5', volume: '12.8', centerX: 178, centerY: 112 },
      brushMarks: [],
      history: [],
      isDrawing: false,
      startPoint: null,
      maskVisible: true,
      confirmed: false
    }
  },
  computed: {
    visibleSlices() {
      const result = []
      const start = Math.max(1, this.currentSlice - 4)
      const end = Math.min(this.totalSlices, start + 8)
      for (let i = start; i <= end; i++) {
        result.push(i)
      }
      return result
    },
    zoomLabel() {
      return Math.round(this.zoom * 100) + '%'
    }
  },
  mounted() {
    this.loadImagingData()
    window.addEventListener('resize', this.drawScene)
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.drawScene)
  },
  methods: {
    async loadImagingData() {
      const routeId = Number(this.$route.query.id)
      const demoList = this.ensureDemoImagings()
      const localItem = demoList.find(item => item.id === routeId)
      if (localItem) {
        this.imagingData = this.normalizeImaging(localItem)
        this.drawScene()
        return
      }

      if (routeId) {
        try {
          const res = await getImagingInfo(routeId)
          if (res.code === 200 && res.data) {
            this.imagingData = this.normalizeImaging(res.data)
          }
        } catch (e) {
          console.error('获取影像数据失败:', e)
        }
      }

      if (!this.imagingData.id) {
        this.imagingData = this.normalizeImaging(demoList[0])
      }
      this.drawScene()
    },
    ensureDemoImagings() {
      try {
        const saved = localStorage.getItem(IMAGING_KEY)
        if (saved) {
          return JSON.parse(saved)
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
        patientName: item.patientName || item.name || '张明',
        gender: item.gender || '男',
        age: item.age || 46,
        phone: item.phone || '',
        type: item.type || item.imagingType || 'CT',
        bodyPart: item.bodyPart || item.body_part || '胸部',
        uploadTime: item.uploadTime || item.upload_time || item.gmtCreate || '',
        doctorName: item.doctorName || item.doctor_name || '李医生',
        fileSize: item.fileSize || item.file_size || '演示文件',
        diagnosisStatus: item.diagnosisStatus || 'pending',
        reportId: item.reportId,
        remark: item.remark || item.description || '胸部检查影像，建议结合临床症状和既往病史综合判断。'
      }
    },
    selectSeries(index) {
      this.currentSeriesIndex = index
      this.totalSlices = this.seriesList[index].count
      this.currentSlice = Math.min(this.currentSlice, this.totalSlices)
      this.drawScene()
    },
    selectSlice(slice) {
      this.currentSlice = slice
      this.drawScene()
    },
    setTool(tool) {
      this.tool = tool
      this.taskStatus = tool === 'box' ? '标注中' : '修正中'
    },
    saveHistory() {
      this.history.push({
        promptBox: Object.assign({}, this.promptBox),
        brushMarks: this.brushMarks.slice(),
        maskVisible: this.maskVisible,
        confirmed: this.confirmed
      })
      if (this.history.length > 20) {
        this.history.shift()
      }
    },
    undo() {
      const last = this.history.pop()
      if (!last) {
        this.$message.info('暂无可撤销操作')
        return
      }
      this.promptBox = Object.assign({}, last.promptBox)
      this.brushMarks = last.brushMarks.slice()
      this.maskVisible = last.maskVisible
      this.confirmed = last.confirmed
      this.taskStatus = this.confirmed ? '已确认' : '标注中'
      this.updateMeasurements()
      this.drawScene()
    },
    getCanvasPoint(event) {
      const rect = this.$refs.imageCanvas.getBoundingClientRect()
      return {
        x: Math.round((event.clientX - rect.left) * this.canvasWidth / rect.width),
        y: Math.round((event.clientY - rect.top) * this.canvasHeight / rect.height)
      }
    },
    handlePointerDown(event) {
      const point = this.getCanvasPoint(event)
      if (this.tool === 'box') {
        this.saveHistory()
        this.isDrawing = true
        this.startPoint = point
        this.promptBox = { x: point.x, y: point.y, w: 1, h: 1 }
      } else if (this.tool === 'brush' || this.tool === 'erase') {
        this.saveHistory()
        this.isDrawing = true
        this.applyBrush(point)
      } else if (this.tool === 'pan') {
        this.startPoint = point
        this.isDrawing = true
      }
    },
    handlePointerMove(event) {
      if (!this.isDrawing) return
      const point = this.getCanvasPoint(event)
      if (this.tool === 'box') {
        this.promptBox = {
          x: Math.min(this.startPoint.x, point.x),
          y: Math.min(this.startPoint.y, point.y),
          w: Math.abs(point.x - this.startPoint.x),
          h: Math.abs(point.y - this.startPoint.y)
        }
        this.updateMeasurements()
        this.drawScene()
      } else if (this.tool === 'brush' || this.tool === 'erase') {
        this.applyBrush(point)
      } else if (this.tool === 'pan') {
        this.$message.closeAll()
        this.$message.info('演示查看器已保持影像居中，可用滚轮缩放')
        this.isDrawing = false
      }
    },
    handlePointerUp() {
      if (!this.isDrawing) return
      this.isDrawing = false
      this.startPoint = null
      this.updateMeasurements()
      this.drawScene()
    },
    handleWheel(event) {
      this.changeZoom(event.deltaY > 0 ? -0.08 : 0.08)
    },
    applyBrush(point) {
      this.brushMarks.push({
        x: point.x,
        y: point.y,
        r: this.tool === 'erase' ? 24 : 18,
        erase: this.tool === 'erase'
      })
      this.drawScene()
    },
    adjustWindow(widthDelta, centerDelta) {
      this.windowWidth = Math.max(80, this.windowWidth + widthDelta)
      this.windowCenter = this.windowCenter + centerDelta
      this.drawScene()
    },
    changeZoom(delta) {
      this.zoom = Math.max(0.6, Math.min(1.8, Number((this.zoom + delta).toFixed(2))))
      this.drawScene()
    },
    runSegmentation() {
      if (this.promptBox.w < 20 || this.promptBox.h < 20) {
        this.$message.warning('请先框选病灶区域')
        return
      }
      this.saveHistory()
      this.taskStatus = 'AI分割中'
      this.maskVisible = false
      this.drawScene()
      setTimeout(() => {
        this.maskVisible = true
        this.aiScore = { confidence: '0.94', dice: '0.92' }
        this.taskStatus = '标注中'
        this.updateMeasurements()
        this.drawScene()
        this.$message.success('AI分割已完成，可继续补画或确认结果')
      }, 400)
    },
    confirmResult() {
      this.confirmed = true
      this.taskStatus = '已确认'
      this.$message.success('分割结果已确认')
      this.drawScene()
    },
    submitReport() {
      const context = {
        imagingId: this.imagingData.id,
        promptBox: this.promptBox,
        aiScore: this.aiScore,
        measurements: this.measurements,
        findings: `${this.imagingData.type}${this.imagingData.bodyPart}影像示局部异常密度/信号影，AI辅助分割提示病灶面积约${this.measurements.area} mm²，体积约${this.measurements.volume} cm³。`,
        opinion: '建议结合临床表现、实验室检查及必要复查进一步评估。'
      }
      sessionStorage.setItem(VIEWER_CONTEXT_KEY, JSON.stringify(context))
      this.$router.push({
        path: '/diagnosisWrite',
        query: { imagingId: this.imagingData.id, patientId: this.imagingData.patientId }
      })
    },
    goBack() {
      this.$router.push('/imagingList')
    },
    updateMeasurements() {
      const area = Math.max(24, Math.round(this.promptBox.w * this.promptBox.h * 0.012) / 10)
      const volume = Math.max(1.2, Math.round(area * 0.36) / 10)
      this.measurements = {
        area: area.toFixed(1),
        volume: volume.toFixed(1),
        centerX: Math.round(this.promptBox.x + this.promptBox.w / 2),
        centerY: Math.round(this.promptBox.y + this.promptBox.h / 2)
      }
    },
    drawScene() {
      this.$nextTick(() => {
        this.drawImageCanvas()
        this.drawMaskCanvas()
      })
    },
    drawImageCanvas() {
      const canvas = this.$refs.imageCanvas
      if (!canvas) return
      const ctx = canvas.getContext('2d')
      const w = this.canvasWidth
      const h = this.canvasHeight
      ctx.clearRect(0, 0, w, h)
      ctx.save()
      ctx.translate(w / 2, h / 2)
      ctx.scale(this.zoom, this.zoom)
      ctx.translate(-w / 2, -h / 2)

      const gradient = ctx.createRadialGradient(w * 0.5, h * 0.48, 20, w * 0.5, h * 0.5, w * 0.55)
      gradient.addColorStop(0, '#e7edf1')
      gradient.addColorStop(0.34, '#94a3ad')
      gradient.addColorStop(0.64, '#38424c')
      gradient.addColorStop(1, '#05070a')
      ctx.fillStyle = gradient
      ctx.fillRect(0, 0, w, h)

      ctx.globalAlpha = 0.18
      for (let y = 0; y < h; y += 12) {
        ctx.fillStyle = y % 24 === 0 ? '#ffffff' : '#b8c0c7'
        ctx.fillRect(0, y, w, 1)
      }
      ctx.globalAlpha = 1

      ctx.fillStyle = 'rgba(235, 241, 244, 0.32)'
      ctx.beginPath()
      ctx.ellipse(w * 0.48, h * 0.52, 170, 138, 0, 0, Math.PI * 2)
      ctx.fill()

      ctx.fillStyle = 'rgba(10, 15, 20, 0.36)'
      ctx.beginPath()
      ctx.ellipse(w * 0.39, h * 0.52, 72, 118, -0.16, 0, Math.PI * 2)
      ctx.fill()
      ctx.beginPath()
      ctx.ellipse(w * 0.57, h * 0.52, 72, 118, 0.16, 0, Math.PI * 2)
      ctx.fill()

      ctx.fillStyle = 'rgba(255, 255, 255, 0.55)'
      ctx.font = '13px Arial'
      ctx.fillText(`${this.imagingData.type || 'CT'} ${this.imagingData.bodyPart || '胸部'}  Slice ${this.currentSlice}/${this.totalSlices}`, 24, 30)
      ctx.fillText(`WW/WL ${this.windowWidth}/${this.windowCenter}`, 24, h - 22)
      ctx.restore()
    },
    drawMaskCanvas() {
      const canvas = this.$refs.maskCanvas
      if (!canvas) return
      const ctx = canvas.getContext('2d')
      const w = this.canvasWidth
      const h = this.canvasHeight
      ctx.clearRect(0, 0, w, h)
      ctx.save()
      ctx.translate(w / 2, h / 2)
      ctx.scale(this.zoom, this.zoom)
      ctx.translate(-w / 2, -h / 2)

      if (this.maskVisible) {
        ctx.fillStyle = 'rgba(24, 188, 126, 0.36)'
        ctx.strokeStyle = 'rgba(120, 255, 196, 0.92)'
        ctx.lineWidth = 2
        ctx.beginPath()
        ctx.ellipse(
          this.promptBox.x + this.promptBox.w * 0.52,
          this.promptBox.y + this.promptBox.h * 0.52,
          Math.max(24, this.promptBox.w * 0.34),
          Math.max(18, this.promptBox.h * 0.28),
          -0.24,
          0,
          Math.PI * 2
        )
        ctx.fill()
        ctx.stroke()
      }

      this.brushMarks.forEach(mark => {
        ctx.globalCompositeOperation = mark.erase ? 'destination-out' : 'source-over'
        ctx.fillStyle = mark.erase ? 'rgba(0,0,0,1)' : 'rgba(24, 188, 126, 0.44)'
        ctx.beginPath()
        ctx.arc(mark.x, mark.y, mark.r, 0, Math.PI * 2)
        ctx.fill()
      })
      ctx.globalCompositeOperation = 'source-over'

      ctx.strokeStyle = this.confirmed ? '#3be283' : '#ffd166'
      ctx.lineWidth = 2
      ctx.setLineDash([6, 4])
      ctx.strokeRect(this.promptBox.x, this.promptBox.y, this.promptBox.w, this.promptBox.h)
      ctx.setLineDash([])
      ctx.fillStyle = 'rgba(0, 0, 0, 0.62)'
      ctx.fillRect(this.promptBox.x, Math.max(0, this.promptBox.y - 24), 106, 22)
      ctx.fillStyle = '#fff'
      ctx.font = '12px Arial'
      ctx.fillText(this.confirmed ? 'Confirmed' : 'Box Prompt', this.promptBox.x + 8, Math.max(15, this.promptBox.y - 8))
      ctx.restore()
    }
  }
}
</script>

<style lang="scss" scoped>
.imaging-viewer-page {
  min-height: calc(100vh - 112px);
  display: flex;
  flex-direction: column;
  background: #eef4f1;
  color: #24312d;
}

.viewer-topbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 12px 16px;
  background: #fff;
  border: 1px solid #dbe7e2;
  border-radius: 8px;
  margin-bottom: 12px;
}

.case-line {
  display: flex;
  flex-wrap: wrap;
  gap: 10px 18px;
  font-size: 13px;
  color: #33443e;

  span {
    padding-right: 16px;
    border-right: 1px solid #dbe7e2;

    &:last-child {
      border-right: none;
    }
  }
}

.top-actions {
  display: flex;
  gap: 8px;
}

.viewer-shell {
  flex: 1;
  display: grid;
  grid-template-columns: 170px minmax(520px, 1fr) 260px;
  gap: 12px;
  min-height: 600px;
}

.viewer-sidebar,
.viewer-inspector,
.viewer-stage {
  background: #fff;
  border: 1px solid #dbe7e2;
  border-radius: 8px;
}

.viewer-sidebar {
  padding: 14px;
}

.panel-title {
  font-size: 13px;
  font-weight: 700;
  color: #075f42;
  margin-bottom: 10px;
}

.slice-title {
  margin-top: 18px;
}

.list-btn,
.slice-btn {
  width: 100%;
  border: 1px solid transparent;
  background: transparent;
  color: #4b625b;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 10px;
  margin-bottom: 4px;
  border-radius: 6px;
  cursor: pointer;
  text-align: left;

  &:hover,
  &.active {
    background: #eaf8f1;
    color: #075f42;
    border-color: #bfe7d4;
  }

  small {
    color: #789089;
  }
}

.slice-btn {
  font-family: Consolas, monospace;
}

.viewer-stage {
  display: flex;
  flex-direction: column;
  padding: 14px;
  min-width: 0;
}

.stage-header {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  color: #4b625b;
  font-size: 13px;
  margin-bottom: 10px;
}

.canvas-wrap {
  position: relative;
  flex: 1;
  min-height: 440px;
  background: #020406;
  border-radius: 8px;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: crosshair;

  canvas {
    width: min(100%, 760px);
    height: auto;
    max-height: 100%;
    border-radius: 6px;
  }
}

.mask-layer {
  position: absolute;
}

.crosshair {
  position: absolute;
  pointer-events: none;
  background: rgba(255, 255, 255, 0.16);

  &.horizontal {
    left: 8%;
    right: 8%;
    top: 50%;
    height: 1px;
  }

  &.vertical {
    top: 8%;
    bottom: 8%;
    left: 50%;
    width: 1px;
  }
}

.stage-controls {
  display: flex;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 12px;
  padding-top: 12px;
}

.control-group {
  display: flex;
  align-items: center;
  gap: 8px;

  span {
    color: #60726b;
    font-size: 13px;
  }
}

.viewer-inspector {
  padding: 14px;
}

.inspector-card {
  padding: 12px;
  border: 1px solid #e2eee9;
  border-radius: 8px;
  background: #fbfefd;
  margin-bottom: 12px;

  h3 {
    margin: 0 0 10px;
    color: #075f42;
    font-size: 14px;
  }
}

.metric-box {
  border: 1px dashed #9bbcaf;
  border-radius: 6px;
  padding: 8px;
  background: #f5fbf8;

  p {
    margin: 4px 0;
    color: #344a42;
    font-size: 13px;
  }
}

.metric-row {
  display: flex;
  justify-content: space-between;
  padding: 7px 0;
  border-bottom: 1px solid #eef5f2;
  font-size: 13px;

  &:last-child {
    border-bottom: none;
  }

  strong {
    color: #075f42;
  }
}

.case-summary {
  color: #4b625b;
  line-height: 1.7;
  margin: 0;
  font-size: 13px;
}

.bottom-toolbar {
  margin-top: 12px;
  padding: 12px;
  background: #fff;
  border: 1px solid #dbe7e2;
  border-radius: 8px;
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

@media (max-width: 1200px) {
  .viewer-shell {
    grid-template-columns: 150px minmax(420px, 1fr);
  }

  .viewer-inspector {
    grid-column: 1 / -1;
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
  }

  .inspector-card {
    margin-bottom: 0;
  }
}

@media (max-width: 900px) {
  .viewer-shell {
    grid-template-columns: 1fr;
  }

  .viewer-inspector {
    display: block;
  }
}
</style>
