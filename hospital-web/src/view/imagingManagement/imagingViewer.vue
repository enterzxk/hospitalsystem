<template>
  <div class="imaging-workstation">
    <header class="workstation-topbar">
      <div class="brand-block">
        <div class="brand-mark">
          <i class="el-icon-view"></i>
        </div>
        <div>
          <h2>医学影像人工标注工作站</h2>
          <p>参考 3D Slicer / ITK-SNAP 的多视图阅片与分割标注流程</p>
        </div>
      </div>
      <div class="case-strip">
        <span>患者：{{ imagingData.patientName || '-' }}</span>
        <span>检查：{{ imagingData.type || '-' }} {{ imagingData.bodyPart || '' }}</span>
        <span>切片：{{ currentSlice }}/{{ totalSlices }}</span>
        <span>状态：{{ taskStatus }}</span>
        <span>放射科医生：{{ assignedDoctor }}</span>
      </div>
      <div class="top-actions">
        <el-button size="mini" icon="el-icon-back" @click="goBack">返回</el-button>
        <el-button size="mini" type="success" icon="el-icon-check" @click="confirmResult">保存归档</el-button>
        <el-button size="mini" type="primary" icon="el-icon-document" @click="submitReport">提交主治医生</el-button>
      </div>
    </header>

    <div class="workstation-body">
      <aside class="left-dock">
        <section class="dock-panel">
          <div class="panel-heading">
            <span>影像数据</span>
            <small>{{ datasetMeta.format }}</small>
          </div>
          <div class="dataset-card active">
            <div class="dataset-icon">DATA</div>
            <div>
              <strong>{{ datasetMeta.sourceVolume.fileName }}</strong>
              <p>{{ datasetMeta.sourceVolume.role }} · {{ datasetMeta.sourceVolume.datatype }} · {{ datasetMeta.sourceVolume.gzipSize }}</p>
            </div>
          </div>
          <div class="dataset-card label-file">
            <div class="dataset-icon label">SEG</div>
            <div>
              <strong>{{ datasetMeta.labelVolume.fileName }}</strong>
              <p>{{ datasetMeta.labelVolume.role }} · {{ datasetMeta.labelVolume.datatype }} · {{ datasetMeta.labelVolume.gzipSize }}</p>
            </div>
          </div>
          <dl class="meta-list">
            <dt>加载状态</dt>
            <dd>{{ volumeLoadStatus }}</dd>
            <dt>配对状态</dt>
            <dd>{{ datasetMeta.pairStatus }}</dd>
            <dt>体数据维度</dt>
            <dd>{{ datasetMeta.sourceVolume.dimensions }}</dd>
            <dt>体素间距</dt>
            <dd>{{ datasetMeta.sourceVolume.spacing }}</dd>
            <dt>数据类型</dt>
            <dd>影像 {{ datasetMeta.sourceVolume.datatypeCode }} / 标注 {{ datasetMeta.labelVolume.datatypeCode }}</dd>
            <dt>偏移</dt>
            <dd>vox_offset {{ datasetMeta.sourceVolume.voxOffset }}</dd>
            <dt>数据目录</dt>
            <dd>{{ datasetMeta.storagePath }}</dd>
          </dl>
        </section>

        <section class="dock-panel">
          <div class="panel-heading">
            <span>序列导航</span>
            <small>{{ seriesList.length }} 组</small>
          </div>
          <button
            v-for="(series, index) in seriesList"
            :key="series.name"
            type="button"
            class="series-row"
            :class="{ active: index === currentSeriesIndex }"
            @click="selectSeries(index)">
            <span>{{ series.name }}</span>
            <small>{{ series.count }} 层</small>
          </button>
        </section>

        <section class="dock-panel">
          <div class="panel-heading">
            <span>切片</span>
            <small>{{ currentSlice }}/{{ totalSlices }}</small>
          </div>
          <el-slider
            v-model="currentSlice"
            :min="1"
            :max="totalSlices"
            :show-tooltip="false"
            @input="selectSlice">
          </el-slider>
          <div class="slice-list">
            <button
              v-for="slice in visibleSlices"
              :key="slice"
              type="button"
              class="slice-row"
              :class="{ active: slice === currentSlice }"
              @click="selectSlice(slice)">
              Slice {{ slice }}
            </button>
          </div>
        </section>

        <section class="dock-panel">
          <div class="panel-heading">
            <span>标签图层</span>
            <small>{{ labels.length }} 类</small>
          </div>
          <button
            v-for="label in labels"
            :key="label.id"
            type="button"
            class="label-row"
            :class="{ active: label.id === activeLabelId }"
            @click="selectLabel(label.id)">
            <i :style="{ backgroundColor: label.color }"></i>
            <span>{{ label.name }}</span>
            <small>{{ getLabelCount(label.id) }}</small>
          </button>
        </section>
      </aside>

      <main class="viewer-center">
        <div class="viewport-toolbar">
          <div class="tool-tabs">
            <button
              v-for="view in views"
              :key="view.key"
              type="button"
              :class="{ active: activeView === view.key }"
              @click="selectView(view.key)">
              {{ view.name }}
            </button>
          </div>
          <div class="view-status">
            <span>窗宽/窗位 {{ windowWidth }}/{{ windowCenter }}</span>
            <span>缩放 {{ zoomLabel }}</span>
            <span>遮罩透明度 {{ maskOpacity }}%</span>
          </div>
        </div>

        <div class="viewport-grid">
          <section
            v-for="view in views"
            :key="view.key"
            class="viewport"
            :class="{ active: activeView === view.key }"
            @click="selectView(view.key)">
        <div class="viewport-title">
          <span>{{ view.name }}</span>
          <small>{{ volumeData.source ? '真实 NIfTI 切片' : view.subtitle }}</small>
        </div>
            <div
              class="canvas-stack"
              @mousedown="handlePointerDown($event, view.key)"
              @mousemove="handlePointerMove($event, view.key)"
              @mouseup="handlePointerUp($event, view.key)"
              @mouseleave="handlePointerUp($event, view.key)"
              @wheel.prevent="handleWheel">
              <canvas :ref="'imageCanvas_' + view.key" :width="canvasWidth" :height="canvasHeight"></canvas>
              <canvas :ref="'maskCanvas_' + view.key" :width="canvasWidth" :height="canvasHeight" class="mask-layer"></canvas>
              <div class="crosshair horizontal"></div>
              <div class="crosshair vertical"></div>
            </div>
          </section>
        </div>
      </main>

      <aside class="right-dock">
        <section class="dock-panel annotation-panel">
          <div class="panel-heading">
            <span>人工标注</span>
            <small>{{ currentToolName }}</small>
          </div>
          <div class="active-label">
            <i :style="{ backgroundColor: currentLabel.color }"></i>
            <div>
              <strong>{{ currentLabel.name }}</strong>
              <p>当前图层，所有补画/框选会归入此标签</p>
            </div>
          </div>
          <div class="slider-row">
            <span>笔刷半径</span>
            <el-slider v-model="brushSize" :min="4" :max="48" :show-tooltip="false"></el-slider>
            <b>{{ brushSize }}px</b>
          </div>
          <div class="slider-row">
            <span>遮罩透明度</span>
            <el-slider v-model="maskOpacity" :min="15" :max="85" :show-tooltip="false" @input="drawScene"></el-slider>
            <b>{{ maskOpacity }}%</b>
          </div>
        </section>

        <section class="dock-panel">
          <div class="panel-heading">
            <span>模型接口</span>
            <small>预留</small>
          </div>
          <div class="model-placeholder">
            <i class="el-icon-cpu"></i>
            <strong>MedSAM 待接入</strong>
            <p>当前版本先完成人工标注、归档和报告闭环。后续接入模型时，使用数据文件作为模型输入，使用标注文件作为参考 mask 或监督标签。</p>
            <el-button size="mini" disabled>模型分割待接入</el-button>
          </div>
        </section>

        <section class="dock-panel">
          <div class="panel-heading">
            <span>Prompt / 测量</span>
            <small>自动更新</small>
          </div>
          <div class="metric-box">
            <p>Box：x={{ promptBox.x }}，y={{ promptBox.y }}</p>
            <p>w={{ promptBox.w }}，h={{ promptBox.h }}</p>
            <p>视图：{{ activeViewName }}，Slice {{ currentSlice }}</p>
          </div>
          <div class="metric-grid">
            <div>
              <span>面积</span>
              <strong>{{ measurements.area }} mm²</strong>
            </div>
            <div>
              <span>体积</span>
              <strong>{{ measurements.volume }} cm³</strong>
            </div>
            <div>
              <span>人工标注</span>
              <strong>{{ manualAnnotationCount }} 条</strong>
            </div>
            <div>
              <span>测量线</span>
              <strong>{{ rulerCount }} 条</strong>
            </div>
          </div>
        </section>

        <section class="dock-panel">
          <div class="panel-heading">
            <span>标注记录</span>
            <small>{{ annotationMarks.length }} 条</small>
          </div>
          <div v-if="annotationMarks.length" class="annotation-list">
            <div v-for="item in recentAnnotations" :key="item.id" class="annotation-row">
              <i :style="{ backgroundColor: getLabelColor(item.labelId) }"></i>
              <div>
                <strong>{{ getLabelName(item.labelId) }} · {{ getToolText(item.type) }}</strong>
                <p>{{ getViewName(item.view) }} / Slice {{ item.slice }} / {{ item.time }}</p>
              </div>
            </div>
          </div>
          <el-empty v-else description="还没有人工标注" :image-size="56"></el-empty>
        </section>

        <section class="dock-panel">
          <div class="panel-heading">
            <span>病例摘要</span>
          </div>
          <p class="case-summary">{{ imagingData.remark || '暂无检查说明。' }}</p>
        </section>
      </aside>
    </div>

    <footer class="bottom-toolbar">
      <div class="tool-group">
        <button type="button" :class="{ active: tool === 'box' }" @click="setTool('box')">
          <i class="el-icon-crop"></i>
          <span>框选</span>
        </button>
        <button type="button" :class="{ active: tool === 'brush' }" @click="setTool('brush')">
          <i class="el-icon-edit"></i>
          <span>补画</span>
        </button>
        <button type="button" :class="{ active: tool === 'erase' }" @click="setTool('erase')">
          <i class="el-icon-delete"></i>
          <span>擦除</span>
        </button>
        <button type="button" :class="{ active: tool === 'ruler' }" @click="setTool('ruler')">
          <i class="el-icon-minus"></i>
          <span>测量</span>
        </button>
        <button type="button" :class="{ active: tool === 'pan' }" @click="setTool('pan')">
          <i class="el-icon-rank"></i>
          <span>查看</span>
        </button>
      </div>
      <div class="tool-group secondary">
        <button type="button" @click="adjustWindow(-20, 0)">窗宽-</button>
        <button type="button" @click="adjustWindow(20, 0)">窗宽+</button>
        <button type="button" @click="adjustWindow(0, -5)">窗位-</button>
        <button type="button" @click="adjustWindow(0, 5)">窗位+</button>
        <button type="button" @click="changeZoom(-0.1)">缩小</button>
        <button type="button" @click="changeZoom(0.1)">放大</button>
      </div>
      <div class="tool-group secondary">
        <button type="button" @click="undo">撤销</button>
        <button type="button" @click="clearCurrentSlice">清空本层</button>
        <button type="button" class="success" @click="confirmResult">保存归档</button>
        <button type="button" class="primary" @click="submitReport">提交报告</button>
      </div>
    </footer>
  </div>
</template>

<script>
import { getImagingInfo } from '@/api/imaging'
import pako from 'pako'
import sourceVolumeUrl from '../../../../影像数据/lung_001.nii.gz'
import labelVolumeUrl from '../../../../影像数据/lung_001.nii（标注）.gz'

const IMAGING_KEY = 'ylz_demo_imagings'
const VIEWER_CONTEXT_KEY = 'ylz_viewer_context'
const ANNOTATION_KEY = 'ylz_demo_annotations'

const datasetMeta = {
  format: 'NIfTI-1 .nii.gz',
  storagePath: '影像数据/',
  pairStatus: '数据文件与标注文件维度一致，可按同一 slice 索引叠加',
  sourceVolume: {
    role: '数据文件',
    fileName: 'lung_001.nii.gz',
    url: sourceVolumeUrl,
    path: '影像数据/lung_001.nii.gz',
    dimensions: '512 × 512 × 304',
    dimArray: [3, 512, 512, 304, 1, 1, 1, 1],
    spacing: '0.6934 × 0.6934 × 1.0 mm',
    pixdim: [-1, 0.6934, 0.6934, 1, 0, 0, 0, 0],
    datatype: 'float32',
    datatypeCode: 16,
    bitpix: 32,
    voxOffset: 352,
    magic: 'n+1',
    gzipSize: '114.8 MB'
  },
  labelVolume: {
    role: '标注文件',
    fileName: 'lung_001.nii（标注）.gz',
    url: labelVolumeUrl,
    path: '影像数据/lung_001.nii（标注）.gz',
    dimensions: '512 × 512 × 304',
    dimArray: [3, 512, 512, 304, 1, 1, 1, 1],
    spacing: '0.6934 × 0.6934 × 1.0 mm',
    pixdim: [-1, 0.6934, 0.6934, 1, 1, 0, 0, 0],
    datatype: 'uint8',
    datatypeCode: 2,
    bitpix: 8,
    voxOffset: 352,
    magic: 'n+1',
    gzipSize: '0.1 MB',
    labelMeaning: '0=背景，1=已标注区域'
  }
}

const defaultImagings = [
  {
    id: 10001,
    patientId: 30001,
    patientName: '张明',
    gender: '男',
    age: 46,
    phone: '13810010001',
    type: 'CT',
    bodyPart: '胸部',
    uploadTime: '2026-05-26 09:20:00',
    doctorName: '林医生',
    fileSize: '114.8MB',
    diagnosisStatus: 'pending',
    radiologyStatus: '待标注',
    datasetMeta: datasetMeta,
    remark: '胸部 CT 肺窗薄层扫描，已导入 lung_001.nii.gz，需完成肺部病灶人工标注。'
  },
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
      datasetMeta: Object.assign({}, datasetMeta),
      volumeLoadStatus: '准备加载真实 NIfTI 数据',
      volumeLoadPercent: 0,
      volumeError: '',
      volumeData: {
        source: null,
        label: null
      },
      assignedDoctor: '沈放射',
      taskStatus: '人工标注中',
      currentSeriesIndex: 0,
      currentSlice: 239,
      totalSlices: 304,
      seriesList: [
        { name: '肺窗薄层', count: 304 },
        { name: '纵隔窗', count: 304 },
        { name: '冠状重建', count: 220 },
        { name: '矢状重建', count: 220 }
      ],
      views: [
        { key: 'axial', name: '轴位 Axial', subtitle: '主标注视图' },
        { key: 'coronal', name: '冠状 Coronal', subtitle: '重建参考' },
        { key: 'sagittal', name: '矢状 Sagittal', subtitle: '重建参考' },
        { key: 'volume', name: '3D Preview', subtitle: '体渲染预览' }
      ],
      labels: [
        { id: 'lesion', name: '病灶', color: '#18bc7e' },
        { id: 'lung', name: '肺野', color: '#38bdf8' },
        { id: 'vessel', name: '血管', color: '#f59e0b' },
        { id: 'exclude', name: '排除区', color: '#ef4444' }
      ],
      activeView: 'axial',
      activeLabelId: 'lesion',
      tool: 'brush',
      canvasWidth: 512,
      canvasHeight: 512,
      windowWidth: 420,
      windowCenter: 40,
      zoom: 1,
      brushSize: 18,
      maskOpacity: 42,
      promptBox: { x: 156, y: 89, w: 214, h: 168 },
      measurements: { area: '342.5', volume: '12.8', centerX: 263, centerY: 173 },
      aiScore: { confidence: '--', dice: '--' },
      machineAnnotations: [],
      annotationMarks: [],
      history: [],
      isDrawing: false,
      startPoint: null,
      pendingMark: null,
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
    },
    currentLabel() {
      return this.labels.find(item => item.id === this.activeLabelId) || this.labels[0]
    },
    currentToolName() {
      const map = {
        box: 'Box Prompt',
        brush: '补画笔刷',
        erase: '擦除',
        ruler: '距离测量',
        pan: '查看'
      }
      return map[this.tool] || '查看'
    },
    activeViewName() {
      return this.getViewName(this.activeView)
    },
    manualAnnotationCount() {
      return this.annotationMarks.filter(item => item.type !== 'ruler').length
    },
    rulerCount() {
      return this.annotationMarks.filter(item => item.type === 'ruler').length
    },
    recentAnnotations() {
      return this.annotationMarks.slice().reverse().slice(0, 8)
    },
    manualAnnotations() {
      return this.annotationMarks.map(item => {
        return {
          id: item.id,
          type: item.type,
          tool: item.type,
          source: 'manual',
          labelId: item.labelId,
          label: this.getLabelName(item.labelId),
          view: item.view,
          slice: item.slice,
          x: item.x,
          y: item.y,
          w: item.w,
          h: item.h,
          r: item.r,
          x2: item.x2,
          y2: item.y2,
          erase: item.type === 'erase',
          time: item.time
        }
      })
    }
  },
  mounted() {
    this.loadImagingData()
    this.loadRealVolumes()
    window.addEventListener('resize', this.drawScene)
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.drawScene)
  },
  methods: {
    loadImagingData() {
      const routeId = Number(this.$route.query.id)
      const demoList = this.ensureDemoImagings()
      const localItem = demoList.find(item => Number(item.id) === routeId)
      if (localItem) {
        this.applyImaging(localItem)
        return
      }

      if (routeId) {
        getImagingInfo(routeId).then(res => {
          if (res.code === 200 && res.data) {
            this.applyImaging(res.data)
          }
        }).catch(e => {
          console.error('获取影像数据失败:', e)
        }).finally(() => {
          if (!this.imagingData.id) {
            this.applyImaging(demoList[0])
          }
        })
        return
      }

      this.applyImaging(demoList[0])
    },
    applyImaging(item) {
      this.imagingData = this.normalizeImaging(item)
      this.datasetMeta = this.mergeDatasetMeta(item.datasetMeta)
      this.loadArchivedAnnotations(item)
      this.updateMeasurements()
      this.drawScene()
    },
    mergeDatasetMeta(savedMeta) {
      const saved = savedMeta || {}
      const source = Object.assign({}, datasetMeta.sourceVolume, saved.sourceVolume || {})
      const label = Object.assign({}, datasetMeta.labelVolume, saved.labelVolume || {})
      return Object.assign({}, datasetMeta, saved, {
        sourceVolume: source,
        labelVolume: label
      })
    },
    ensureDemoImagings() {
      let savedList = []
      try {
        const saved = localStorage.getItem(IMAGING_KEY)
        if (saved) {
          savedList = JSON.parse(saved)
        }
      } catch (e) {
        localStorage.removeItem(IMAGING_KEY)
      }
      if (!savedList.length) {
        localStorage.setItem(IMAGING_KEY, JSON.stringify(defaultImagings))
        return defaultImagings
      }
      const mergedList = savedList.map(item => {
        if (Number(item.id) !== 10001) return item
        return Object.assign({}, defaultImagings[0], item, {
          type: 'CT',
          bodyPart: '胸部',
          fileSize: '114.8MB',
          remark: item.remark && item.remark.indexOf('lung_001') !== -1 ? item.remark : defaultImagings[0].remark,
          datasetMeta: Object.assign({}, datasetMeta, item.datasetMeta || {})
        })
      })
      if (!mergedList.some(item => Number(item.id) === 10001)) {
        mergedList.unshift(defaultImagings[0])
      }
      localStorage.setItem(IMAGING_KEY, JSON.stringify(mergedList))
      return mergedList
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
        doctorName: item.doctorName || item.doctor_name || '沈放射',
        fileSize: item.fileSize || item.file_size || this.datasetMeta.sourceVolume.gzipSize,
        diagnosisStatus: item.diagnosisStatus || 'pending',
        radiologyStatus: item.radiologyStatus || '待标注',
        medsamResult: item.medsamResult || null,
        reportId: item.reportId,
        remark: item.remark || item.description || '胸部 CT 影像，当前需完成人工分割标注并提交主治医生诊断。'
      }
    },
    loadArchivedAnnotations(item) {
      const result = item.medsamResult || {}
      if (result.promptBox) {
        this.promptBox = Object.assign({}, result.promptBox)
      }
      if (result.measurements) {
        this.measurements = Object.assign({}, result.measurements)
      }
      if (result.aiScore) {
        this.aiScore = Object.assign({}, result.aiScore)
      }
      this.machineAnnotations = result.machineAnnotations ? result.machineAnnotations.slice() : []
      if (result.annotationMarks) {
        this.annotationMarks = result.annotationMarks.slice()
      } else if (result.manualAnnotations) {
        this.annotationMarks = result.manualAnnotations.map(item => this.normalizeAnnotationMark(item))
      } else if (result.brushMarks) {
        this.annotationMarks = result.brushMarks.map(item => this.normalizeAnnotationMark(item))
      } else {
        this.annotationMarks = []
      }
      this.confirmed = item.radiologyStatus === '已提交主治医生' || item.radiologyStatus === '已确认' || item.radiologyStatus === '诊断报告已上传'
      this.taskStatus = this.confirmed ? item.radiologyStatus : '人工标注中'
    },
    normalizeAnnotationMark(item) {
      return Object.assign({
        id: item.id || Date.now() + Math.floor(Math.random() * 10000),
        type: item.type || (item.erase ? 'erase' : 'brush'),
        view: item.view || 'axial',
        slice: item.slice || this.currentSlice,
        labelId: item.labelId || 'lesion',
        time: item.time || this.formatShortTime(new Date())
      }, item)
    },
    loadRealVolumes() {
      const self = this
      self.volumeLoadStatus = '正在加载真实影像数据...'
      self.volumeError = ''
      Promise.all([
        self.loadNiftiVolume(datasetMeta.sourceVolume.url, 'source'),
        self.loadNiftiVolume(datasetMeta.labelVolume.url, 'label')
      ]).then(function(results) {
        self.volumeData = {
          source: results[0],
          label: results[1]
        }
        self.totalSlices = results[0].dims[2]
        if (results[1].labelStats && results[1].labelStats.peakSlice) {
          self.currentSlice = Math.min(results[1].labelStats.peakSlice, self.totalSlices)
          self.applyLabelStats(results[1].labelStats)
        } else {
          self.currentSlice = Math.min(self.currentSlice, self.totalSlices)
        }
        self.datasetMeta = self.mergeDatasetMeta({
          sourceVolume: Object.assign({}, datasetMeta.sourceVolume, {
            dimensions: results[0].dims.join(' × '),
            spacing: results[0].spacing.join(' × ') + ' mm',
            datatypeCode: results[0].datatype,
            bitpix: results[0].bitpix,
            voxOffset: results[0].voxOffset
          }),
          labelVolume: Object.assign({}, datasetMeta.labelVolume, {
            dimensions: results[1].dims.join(' × '),
            spacing: results[1].spacing.join(' × ') + ' mm',
            datatypeCode: results[1].datatype,
            bitpix: results[1].bitpix,
            voxOffset: results[1].voxOffset
          })
        })
        const stats = results[1].labelStats
        self.volumeLoadStatus = stats
          ? `已加载真实 NIfTI 数据：标注位于 Slice ${stats.firstSlice}-${stats.lastSlice}，当前定位 Slice ${self.currentSlice}`
          : '已加载真实 NIfTI 数据与标注 mask'
        self.drawScene()
      }).catch(function(error) {
        console.error('加载 NIfTI 数据失败:', error)
        self.volumeError = error.message || '加载失败'
        self.volumeLoadStatus = '真实数据加载失败，暂用演示底图'
        self.drawScene()
      })
    },
    loadNiftiVolume(url, role) {
      return fetch(url)
        .then(function(response) {
          if (!response.ok) {
            throw new Error('读取 ' + role + ' 文件失败：' + response.status)
          }
          return response.arrayBuffer()
        })
        .then(function(arrayBuffer) {
          const compressed = new Uint8Array(arrayBuffer)
          const bytes = pako.ungzip(compressed)
          return this.parseNiftiBytes(bytes, role)
        }.bind(this))
    },
    parseNiftiBytes(bytes, role) {
      const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength)
      const sizeofHdr = view.getInt32(0, true)
      if (sizeofHdr !== 348) {
        throw new Error(role + ' 不是有效的 NIfTI-1 文件')
      }
      const dimCount = view.getInt16(40, true)
      const dims = [
        view.getInt16(42, true),
        view.getInt16(44, true),
        view.getInt16(46, true)
      ]
      const datatype = view.getInt16(70, true)
      const bitpix = view.getInt16(72, true)
      const spacing = [
        Number(view.getFloat32(80, true).toFixed(4)),
        Number(view.getFloat32(84, true).toFixed(4)),
        Number(view.getFloat32(88, true).toFixed(4))
      ]
      const voxOffset = Math.round(view.getFloat32(108, true))
      const total = dims[0] * dims[1] * dims[2]
      let data
      if (datatype === 16) {
        data = new Float32Array(bytes.buffer, bytes.byteOffset + voxOffset, total)
      } else if (datatype === 2) {
        data = new Uint8Array(bytes.buffer, bytes.byteOffset + voxOffset, total)
      } else {
        throw new Error(role + ' 暂不支持 datatype=' + datatype)
      }
      return {
        role: role,
        dimCount: dimCount,
        dims: dims,
        datatype: datatype,
        bitpix: bitpix,
        spacing: spacing,
        voxOffset: voxOffset,
        data: data,
        labelStats: role === 'label' ? this.analyzeLabelVolume(data, dims, spacing) : null
      }
    },
    analyzeLabelVolume(data, dims, spacing) {
      const dimX = dims[0]
      const dimY = dims[1]
      const dimZ = dims[2]
      const sliceSize = dimX * dimY
      let totalVoxels = 0
      let firstSlice = 0
      let lastSlice = 0
      let peak = null

      for (let z = 0; z < dimZ; z++) {
        let count = 0
        let minX = dimX
        let maxX = -1
        let minY = dimY
        let maxY = -1
        const base = z * sliceSize
        for (let y = 0; y < dimY; y++) {
          const row = base + y * dimX
          for (let x = 0; x < dimX; x++) {
            if (!data[row + x]) continue
            count += 1
            if (x < minX) minX = x
            if (x > maxX) maxX = x
            if (y < minY) minY = y
            if (y > maxY) maxY = y
          }
        }
        if (!count) continue
        totalVoxels += count
        if (!firstSlice) firstSlice = z + 1
        lastSlice = z + 1
        if (!peak || count > peak.count) {
          peak = { slice: z + 1, count, minX, maxX, minY, maxY }
        }
      }

      if (!peak) return null
      const voxelArea = spacing[0] * spacing[1]
      const voxelVolume = voxelArea * spacing[2]
      const displayMinY = dimY - 1 - peak.maxY
      const displayMaxY = dimY - 1 - peak.minY
      const centerX = Math.round((peak.minX + peak.maxX) / 2)
      const centerY = Math.round((displayMinY + displayMaxY) / 2)
      const boxWidth = Math.max(48, peak.maxX - peak.minX + 1 + 32)
      const boxHeight = Math.max(48, displayMaxY - displayMinY + 1 + 32)
      const promptBox = {
        x: Math.max(0, Math.min(dimX - boxWidth, Math.round(centerX - boxWidth / 2))),
        y: Math.max(0, Math.min(dimY - boxHeight, Math.round(centerY - boxHeight / 2))),
        w: boxWidth,
        h: boxHeight
      }

      return {
        totalVoxels,
        firstSlice,
        lastSlice,
        peakSlice: peak.slice,
        peakVoxelCount: peak.count,
        peakBbox: peak,
        promptBox,
        centerX,
        centerY,
        peakAreaMm2: Number((peak.count * voxelArea).toFixed(1)),
        volumeCm3: Number((totalVoxels * voxelVolume / 1000).toFixed(2))
      }
    },
    applyLabelStats(stats) {
      this.promptBox = Object.assign({}, stats.promptBox)
      this.measurements = {
        area: stats.peakAreaMm2,
        volume: stats.volumeCm3,
        centerX: stats.centerX,
        centerY: stats.centerY
      }
    },
    selectSeries(index) {
      this.currentSeriesIndex = index
      this.totalSlices = this.seriesList[index].count
      this.currentSlice = Math.min(this.currentSlice, this.totalSlices)
      this.drawScene()
    },
    selectSlice(value) {
      this.currentSlice = Number(value)
      this.drawScene()
    },
    selectView(viewKey) {
      this.activeView = viewKey
      this.drawScene()
    },
    selectLabel(labelId) {
      this.activeLabelId = labelId
    },
    setTool(tool) {
      this.tool = tool
      this.taskStatus = tool === 'pan' ? '阅片查看中' : '人工标注中'
    },
    saveHistory() {
      this.history.push({
        promptBox: Object.assign({}, this.promptBox),
        annotationMarks: JSON.parse(JSON.stringify(this.annotationMarks)),
        confirmed: this.confirmed,
        taskStatus: this.taskStatus
      })
      if (this.history.length > 30) {
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
      this.annotationMarks = last.annotationMarks
      this.confirmed = last.confirmed
      this.taskStatus = last.taskStatus
      this.updateMeasurements()
      this.drawScene()
    },
    clearCurrentSlice() {
      const before = this.annotationMarks.length
      this.saveHistory()
      this.annotationMarks = this.annotationMarks.filter(item => !(item.view === this.activeView && item.slice === this.currentSlice))
      if (before === this.annotationMarks.length) {
        this.history.pop()
        this.$message.info('当前视图切片没有标注')
        return
      }
      this.updateMeasurements()
      this.drawScene()
      this.$message.success('已清空当前切片标注')
    },
    getRef(name) {
      const ref = this.$refs[name]
      return Array.isArray(ref) ? ref[0] : ref
    },
    getCanvasPoint(event, viewKey) {
      const canvas = this.getRef('imageCanvas_' + viewKey)
      if (!canvas) return { x: 0, y: 0 }
      const rect = canvas.getBoundingClientRect()
      return {
        x: Math.round((event.clientX - rect.left) * this.canvasWidth / rect.width),
        y: Math.round((event.clientY - rect.top) * this.canvasHeight / rect.height)
      }
    },
    handlePointerDown(event, viewKey) {
      this.selectView(viewKey)
      const point = this.getCanvasPoint(event, viewKey)
      if (this.tool === 'pan') {
        this.$message.closeAll()
        this.$message.info('查看模式：可用滚轮缩放，或切换工具进行标注')
        return
      }
      this.saveHistory()
      this.isDrawing = true
      this.startPoint = point
      if (this.tool === 'brush' || this.tool === 'erase') {
        this.applyBrush(point, viewKey)
      } else if (this.tool === 'box') {
        this.pendingMark = this.createBaseMark('box', point, viewKey)
        this.promptBox = { x: point.x, y: point.y, w: 1, h: 1 }
      } else if (this.tool === 'ruler') {
        this.pendingMark = Object.assign(this.createBaseMark('ruler', point, viewKey), {
          x2: point.x,
          y2: point.y,
          length: 0
        })
      }
    },
    handlePointerMove(event, viewKey) {
      if (!this.isDrawing) return
      const point = this.getCanvasPoint(event, viewKey)
      if (this.tool === 'brush' || this.tool === 'erase') {
        this.applyBrush(point, viewKey)
        return
      }
      if (this.tool === 'box' && this.pendingMark) {
        this.promptBox = {
          x: Math.min(this.startPoint.x, point.x),
          y: Math.min(this.startPoint.y, point.y),
          w: Math.abs(point.x - this.startPoint.x),
          h: Math.abs(point.y - this.startPoint.y)
        }
        this.pendingMark = Object.assign(this.pendingMark, this.promptBox)
        this.updateMeasurements()
        this.drawScene()
        return
      }
      if (this.tool === 'ruler' && this.pendingMark) {
        const dx = point.x - this.pendingMark.x
        const dy = point.y - this.pendingMark.y
        this.pendingMark.x2 = point.x
        this.pendingMark.y2 = point.y
        this.pendingMark.length = Math.sqrt(dx * dx + dy * dy) * 0.6934
        this.drawScene()
      }
    },
    handlePointerUp(event, viewKey) {
      if (!this.isDrawing) return
      this.isDrawing = false
      if (this.tool === 'box' && this.pendingMark && this.promptBox.w > 8 && this.promptBox.h > 8) {
        this.annotationMarks.push(Object.assign({}, this.pendingMark, {
          id: this.createId(),
          time: this.formatShortTime(new Date())
        }))
      } else if (this.tool === 'ruler' && this.pendingMark && this.pendingMark.length > 1) {
        this.annotationMarks.push(Object.assign({}, this.pendingMark, {
          id: this.createId(),
          time: this.formatShortTime(new Date())
        }))
      } else if (this.tool === 'box' || this.tool === 'ruler') {
        this.history.pop()
      }
      this.pendingMark = null
      this.startPoint = null
      this.updateMeasurements()
      this.drawScene()
    },
    handleWheel(event) {
      this.changeZoom(event.deltaY > 0 ? -0.08 : 0.08)
    },
    createBaseMark(type, point, viewKey) {
      return {
        id: this.createId(),
        type: type,
        view: viewKey,
        slice: this.currentSlice,
        labelId: this.activeLabelId,
        x: point.x,
        y: point.y,
        time: this.formatShortTime(new Date())
      }
    },
    createId() {
      return Date.now() + Math.floor(Math.random() * 10000)
    },
    applyBrush(point, viewKey) {
      const mark = Object.assign(this.createBaseMark(this.tool === 'erase' ? 'erase' : 'brush', point, viewKey), {
        r: this.tool === 'erase' ? this.brushSize + 4 : this.brushSize
      })
      this.annotationMarks.push(mark)
      this.updateMeasurements()
      this.drawScene()
    },
    adjustWindow(widthDelta, centerDelta) {
      this.windowWidth = Math.max(80, this.windowWidth + widthDelta)
      this.windowCenter = this.windowCenter + centerDelta
      this.drawScene()
    },
    changeZoom(delta) {
      this.zoom = Math.max(0.65, Math.min(1.9, Number((this.zoom + delta).toFixed(2))))
      this.drawScene()
    },
    confirmResult() {
      if (!this.annotationMarks.length && (!this.promptBox.w || this.promptBox.w < 8)) {
        this.$message.warning('请先完成至少一处人工标注')
        return
      }
      this.confirmed = true
      this.taskStatus = '已确认'
      this.persistImagingArchive('已确认')
      this.$message.success('人工标注结果已保存归档')
      this.drawScene()
    },
    submitReport() {
      if (!this.confirmed) {
        if (!this.annotationMarks.length && (!this.promptBox.w || this.promptBox.w < 8)) {
          this.$message.warning('请先完成标注后再提交报告')
          return
        }
        this.confirmed = true
      }
      this.persistImagingArchive('已提交主治医生')
      const context = {
        imagingId: this.imagingData.id,
        promptBox: this.promptBox,
        aiScore: this.aiScore,
        measurements: this.measurements,
        machineAnnotations: this.machineAnnotations,
        manualAnnotations: this.manualAnnotations,
        annotationMarks: this.annotationMarks,
        findings: `${this.imagingData.type}${this.imagingData.bodyPart}影像已完成人工分割标注，主要标注层面为 ${this.activeViewName} Slice ${this.currentSlice}，估算标注面积约 ${this.measurements.area} mm²，体积约 ${this.measurements.volume} cm³。`,
        opinion: '请主治医生结合临床表现、实验室检查和随访影像综合判断。'
      }
      sessionStorage.setItem(VIEWER_CONTEXT_KEY, JSON.stringify(context))
      this.$router.push({
        path: '/diagnosisWrite',
        query: { imagingId: this.imagingData.id, patientId: this.imagingData.patientId }
      })
    },
    persistImagingArchive(status) {
      const list = this.ensureDemoImagings()
      const archive = this.buildArchivePayload(status)
      const nextList = list.map(item => {
        if (Number(item.id) !== Number(this.imagingData.id)) return item
        return Object.assign({}, item, archive)
      })
      if (!nextList.some(item => Number(item.id) === Number(this.imagingData.id))) {
        nextList.unshift(Object.assign({}, this.imagingData, archive))
      }
      localStorage.setItem(IMAGING_KEY, JSON.stringify(nextList))
      this.persistAnnotationRows(archive.medsamResult)
      this.imagingData = this.normalizeImaging(Object.assign({}, this.imagingData, archive))
    },
    buildArchivePayload(status) {
      return {
        radiologyStatus: status,
        diagnosisStatus: status === '已提交主治医生' ? 'pending' : this.imagingData.diagnosisStatus,
        datasetMeta: Object.assign({}, this.datasetMeta),
        sourceVolume: Object.assign({}, this.datasetMeta.sourceVolume),
        labelVolume: Object.assign({}, this.datasetMeta.labelVolume),
        medsamResult: {
          modelName: 'MedSAM（待接入）',
          workflowMode: 'manual-first',
          promptType: 'manual-box',
          promptBox: Object.assign({}, this.promptBox),
          slice: this.currentSlice,
          view: this.activeView,
          series: this.seriesList[this.currentSeriesIndex].name,
          aiScore: Object.assign({}, this.aiScore),
          measurements: Object.assign({}, this.measurements),
          machineAnnotations: this.machineAnnotations.slice(),
          manualAnnotations: this.manualAnnotations,
          annotationMarks: JSON.parse(JSON.stringify(this.annotationMarks)),
          labelStats: this.createLabelStats(),
          datasetMeta: Object.assign({}, this.datasetMeta),
          sourceVolume: Object.assign({}, this.datasetMeta.sourceVolume),
          labelVolume: Object.assign({}, this.datasetMeta.labelVolume),
          updatedAt: this.formatDateTime(new Date())
        }
      }
    },
    persistAnnotationRows(result) {
      let rows = []
      try {
        rows = JSON.parse(localStorage.getItem(ANNOTATION_KEY) || '[]')
      } catch (e) {
        rows = []
      }
      rows = rows.filter(item => Number(item.imagingId) !== Number(this.imagingData.id))
      this.manualAnnotations.forEach((item, index) => {
        rows.push({
          id: Date.now() + index,
          imagingId: this.imagingData.id,
          patientId: this.imagingData.patientId,
          source: 'manual',
          modelName: '',
          annotationType: item.type,
          annotationData: item,
          label: item.label,
          color: this.getLabelColor(item.labelId),
          createdAt: this.formatDateTime(new Date())
        })
      })
      rows.push({
        id: Date.now() + 9000,
        imagingId: this.imagingData.id,
        patientId: this.imagingData.patientId,
        source: 'archive',
        modelName: 'MedSAM待接入',
        annotationType: 'manual-archive',
        annotationData: result,
        label: '人工分割归档',
        color: '#0f8f61',
        createdAt: this.formatDateTime(new Date())
      })
      localStorage.setItem(ANNOTATION_KEY, JSON.stringify(rows))
    },
    createLabelStats() {
      return this.labels.map(label => {
        const count = this.getLabelCount(label.id)
        return {
          labelId: label.id,
          label: label.name,
          color: label.color,
          count: count
        }
      })
    },
    updateMeasurements() {
      const voxelArea = 0.6934 * 0.6934
      const brushAreaPx = this.annotationMarks.reduce((sum, item) => {
        if (item.type === 'brush') return sum + Math.PI * item.r * item.r
        if (item.type === 'erase') return sum - Math.PI * item.r * item.r * 0.72
        return sum
      }, 0)
      const boxAreaPx = this.promptBox.w > 8 && this.promptBox.h > 8 ? this.promptBox.w * this.promptBox.h * 0.36 : 0
      const area = Math.max(0, (brushAreaPx + boxAreaPx) * voxelArea)
      const volume = Math.max(0, area * 1.0 * Math.max(1, this.getAnnotatedSliceCount()) / 1000)
      this.measurements = {
        area: area.toFixed(1),
        volume: volume.toFixed(2),
        centerX: Math.round(this.promptBox.x + this.promptBox.w / 2),
        centerY: Math.round(this.promptBox.y + this.promptBox.h / 2)
      }
    },
    getAnnotatedSliceCount() {
      const seen = {}
      this.annotationMarks.forEach(item => {
        if (item.type !== 'ruler') {
          seen[item.view + '-' + item.slice] = true
        }
      })
      return Object.keys(seen).length
    },
    drawScene() {
      this.$nextTick(() => {
        this.views.forEach(view => {
          this.drawImageCanvas(view.key)
          this.drawMaskCanvas(view.key)
        })
      })
    },
    drawImageCanvas(viewKey) {
      const canvas = this.getRef('imageCanvas_' + viewKey)
      if (!canvas) return
      const ctx = canvas.getContext('2d')
      const w = this.canvasWidth
      const h = this.canvasHeight
      ctx.clearRect(0, 0, w, h)
      ctx.save()
      ctx.translate(w / 2, h / 2)
      ctx.scale(this.zoom, this.zoom)
      ctx.translate(-w / 2, -h / 2)

      if (this.volumeData.source) {
        this.drawRealImageSlice(ctx, viewKey, w, h)
        ctx.fillStyle = 'rgba(255, 255, 255, 0.72)'
        ctx.font = '13px Arial'
        ctx.fillText(`${this.imagingData.type || 'CT'} ${this.imagingData.bodyPart || '胸部'} · ${this.getViewName(viewKey)} · real NIfTI`, 18, 26)
        ctx.fillText(`Slice ${this.currentSlice}/${this.totalSlices}  WW/WL ${this.windowWidth}/${this.windowCenter}`, 18, h - 18)
        ctx.restore()
        return
      }

      const tone = this.getWindowTone()
      const gradient = ctx.createRadialGradient(w * 0.5, h * 0.48, 20, w * 0.5, h * 0.5, w * 0.62)
      gradient.addColorStop(0, tone.center)
      gradient.addColorStop(0.35, tone.mid)
      gradient.addColorStop(0.68, tone.edge)
      gradient.addColorStop(1, '#05070a')
      ctx.fillStyle = gradient
      ctx.fillRect(0, 0, w, h)

      ctx.globalAlpha = 0.12
      for (let y = 0; y < h; y += 12) {
        ctx.fillStyle = y % 24 === 0 ? '#ffffff' : '#b8c0c7'
        ctx.fillRect(0, y, w, 1)
      }
      ctx.globalAlpha = 1

      if (viewKey === 'volume') {
        this.drawVolumePreview(ctx, w, h)
      } else if (viewKey === 'coronal') {
        this.drawCoronalBody(ctx, w, h)
      } else if (viewKey === 'sagittal') {
        this.drawSagittalBody(ctx, w, h)
      } else {
        this.drawAxialBody(ctx, w, h)
      }

      ctx.fillStyle = 'rgba(255, 255, 255, 0.62)'
      ctx.font = '13px Arial'
      ctx.fillText(`${this.imagingData.type || 'CT'} ${this.imagingData.bodyPart || '胸部'} · ${this.getViewName(viewKey)}`, 18, 26)
      ctx.fillText(`Slice ${this.currentSlice}/${this.totalSlices}  WW/WL ${this.windowWidth}/${this.windowCenter}`, 18, h - 18)
      ctx.restore()
    },
    drawRealImageSlice(ctx, viewKey, w, h) {
      const image = ctx.createImageData(w, h)
      const pixels = image.data
      const volume = this.volumeData.source
      const dims = volume.dims
      const data = volume.data
      const min = this.windowCenter - this.windowWidth / 2
      const width = Math.max(1, this.windowWidth)
      for (let y = 0; y < h; y++) {
        for (let x = 0; x < w; x++) {
          const voxel = this.getVoxelForView(data, dims, viewKey, x, y, w, h)
          let gray = Math.round((voxel - min) / width * 255)
          if (gray < 0) gray = 0
          if (gray > 255) gray = 255
          const idx = (y * w + x) * 4
          pixels[idx] = gray
          pixels[idx + 1] = gray
          pixels[idx + 2] = gray
          pixels[idx + 3] = 255
        }
      }
      ctx.putImageData(image, 0, 0)
    },
    getVoxelForView(data, dims, viewKey, x, y, w, h) {
      const dimX = dims[0]
      const dimY = dims[1]
      const dimZ = dims[2]
      const sx = Math.min(dimX - 1, Math.max(0, Math.round(x / Math.max(1, w - 1) * (dimX - 1))))
      const sy = Math.min(dimY - 1, Math.max(0, Math.round((h - 1 - y) / Math.max(1, h - 1) * (dimY - 1))))
      const sz = Math.min(dimZ - 1, Math.max(0, this.currentSlice - 1))
      if (viewKey === 'coronal') {
        const fixedY = this.getReferencePlaneIndex('coronal', dimX, dimY, dimZ)
        const z = Math.min(dimZ - 1, Math.max(0, Math.round((h - 1 - y) / Math.max(1, h - 1) * (dimZ - 1))))
        return data[sx + fixedY * dimX + z * dimX * dimY]
      }
      if (viewKey === 'sagittal') {
        const fixedX = this.getReferencePlaneIndex('sagittal', dimX, dimY, dimZ)
        const y2 = Math.min(dimY - 1, Math.max(0, Math.round(x / Math.max(1, w - 1) * (dimY - 1))))
        const z2 = Math.min(dimZ - 1, Math.max(0, Math.round((h - 1 - y) / Math.max(1, h - 1) * (dimZ - 1))))
        return data[fixedX + y2 * dimX + z2 * dimX * dimY]
      }
      if (viewKey === 'volume') {
        let max = -Infinity
        for (let z3 = 0; z3 < dimZ; z3 += 8) {
          const value = data[sx + sy * dimX + z3 * dimX * dimY]
          if (value > max) max = value
        }
        return max
      }
      return data[sx + sy * dimX + sz * dimX * dimY]
    },
    getReferencePlaneIndex(viewKey, dimX, dimY, dimZ) {
      const stats = this.volumeData.label && this.volumeData.label.labelStats
      const bbox = stats && stats.peakBbox
      if (viewKey === 'coronal') {
        if (bbox) return Math.round((bbox.minY + bbox.maxY) / 2)
        return Math.min(dimY - 1, Math.max(0, Math.round((this.currentSlice - 1) / Math.max(1, dimZ - 1) * (dimY - 1))))
      }
      if (viewKey === 'sagittal') {
        if (bbox) return Math.round((bbox.minX + bbox.maxX) / 2)
        return Math.min(dimX - 1, Math.max(0, Math.round((this.currentSlice - 1) / Math.max(1, dimZ - 1) * (dimX - 1))))
      }
      return Math.min(dimZ - 1, Math.max(0, this.currentSlice - 1))
    },
    drawAxialBody(ctx, w, h) {
      ctx.fillStyle = 'rgba(235, 241, 244, 0.34)'
      ctx.beginPath()
      ctx.ellipse(w * 0.5, h * 0.54, 176, 132, 0, 0, Math.PI * 2)
      ctx.fill()

      ctx.fillStyle = 'rgba(7, 12, 18, 0.52)'
      ctx.beginPath()
      ctx.ellipse(w * 0.38, h * 0.53, 76, 112, -0.14, 0, Math.PI * 2)
      ctx.fill()
      ctx.beginPath()
      ctx.ellipse(w * 0.62, h * 0.53, 76, 112, 0.14, 0, Math.PI * 2)
      ctx.fill()

      ctx.fillStyle = 'rgba(220, 226, 230, 0.48)'
      ctx.beginPath()
      ctx.ellipse(w * 0.5, h * 0.55, 34, 45, 0, 0, Math.PI * 2)
      ctx.fill()
    },
    drawCoronalBody(ctx, w, h) {
      ctx.fillStyle = 'rgba(236, 242, 245, 0.31)'
      ctx.beginPath()
      ctx.ellipse(w * 0.5, h * 0.54, 138, 156, 0, 0, Math.PI * 2)
      ctx.fill()

      ctx.fillStyle = 'rgba(7, 12, 18, 0.48)'
      ctx.beginPath()
      ctx.ellipse(w * 0.41, h * 0.52, 52, 132, -0.08, 0, Math.PI * 2)
      ctx.fill()
      ctx.beginPath()
      ctx.ellipse(w * 0.59, h * 0.52, 52, 132, 0.08, 0, Math.PI * 2)
      ctx.fill()
    },
    drawSagittalBody(ctx, w, h) {
      ctx.fillStyle = 'rgba(236, 242, 245, 0.3)'
      ctx.beginPath()
      ctx.ellipse(w * 0.5, h * 0.54, 110, 158, 0.08, 0, Math.PI * 2)
      ctx.fill()

      ctx.fillStyle = 'rgba(8, 13, 20, 0.5)'
      ctx.beginPath()
      ctx.ellipse(w * 0.52, h * 0.53, 58, 132, 0.04, 0, Math.PI * 2)
      ctx.fill()
    },
    drawVolumePreview(ctx, w, h) {
      ctx.fillStyle = 'rgba(236, 242, 245, 0.22)'
      ctx.beginPath()
      ctx.ellipse(w * 0.49, h * 0.52, 154, 122, -0.16, 0, Math.PI * 2)
      ctx.fill()
      ctx.fillStyle = 'rgba(24, 188, 126, 0.13)'
      ctx.beginPath()
      ctx.ellipse(w * 0.53, h * 0.47, 92, 70, -0.2, 0, Math.PI * 2)
      ctx.fill()
      ctx.strokeStyle = 'rgba(255,255,255,0.22)'
      ctx.lineWidth = 1
      for (let i = 0; i < 6; i++) {
        ctx.strokeRect(176 + i * 8, 84 + i * 12, 160 - i * 12, 142 - i * 10)
      }
    },
    drawMaskCanvas(viewKey) {
      const canvas = this.getRef('maskCanvas_' + viewKey)
      if (!canvas) return
      const ctx = canvas.getContext('2d')
      const w = this.canvasWidth
      const h = this.canvasHeight
      ctx.clearRect(0, 0, w, h)
      ctx.save()
      ctx.translate(w / 2, h / 2)
      ctx.scale(this.zoom, this.zoom)
      ctx.translate(-w / 2, -h / 2)
      ctx.globalAlpha = this.maskOpacity / 100

      if (this.volumeData.label) {
        this.drawRealLabelMask(ctx, viewKey, w, h)
      }

      const marks = this.annotationMarks.filter(item => item.view === viewKey)
      marks.forEach(mark => {
        this.drawAnnotationMark(ctx, mark)
      })

      if (this.pendingMark && this.pendingMark.view === viewKey) {
        this.drawAnnotationMark(ctx, this.pendingMark, true)
      }

      ctx.globalAlpha = 1
      if (viewKey === this.activeView && this.promptBox.w > 8 && this.promptBox.h > 8) {
        ctx.strokeStyle = this.confirmed ? '#3be283' : '#ffd166'
        ctx.lineWidth = 2
        ctx.setLineDash([7, 4])
        ctx.strokeRect(this.promptBox.x, this.promptBox.y, this.promptBox.w, this.promptBox.h)
        ctx.setLineDash([])
        ctx.fillStyle = 'rgba(0, 0, 0, 0.64)'
        ctx.fillRect(this.promptBox.x, Math.max(0, this.promptBox.y - 24), 116, 22)
        ctx.fillStyle = '#ffffff'
        ctx.font = '12px Arial'
        ctx.fillText(this.confirmed ? 'Archived Box' : 'Manual Box', this.promptBox.x + 8, Math.max(15, this.promptBox.y - 8))
      }
      ctx.restore()
    },
    drawRealLabelMask(ctx, viewKey, w, h) {
      const labelVolume = this.volumeData.label
      const dims = labelVolume.dims
      const data = labelVolume.data
      const image = ctx.createImageData(w, h)
      const pixels = image.data
      for (let y = 0; y < h; y++) {
        for (let x = 0; x < w; x++) {
          const label = this.getLabelForView(data, dims, viewKey, x, y, w, h)
          if (!label) continue
          const idx = (y * w + x) * 4
          pixels[idx] = 24
          pixels[idx + 1] = 188
          pixels[idx + 2] = 126
          pixels[idx + 3] = 210
        }
      }
      const tempCanvas = document.createElement('canvas')
      tempCanvas.width = w
      tempCanvas.height = h
      tempCanvas.getContext('2d').putImageData(image, 0, 0)
      ctx.drawImage(tempCanvas, 0, 0, w, h)
    },
    getLabelForView(data, dims, viewKey, x, y, w, h) {
      const dimX = dims[0]
      const dimY = dims[1]
      const dimZ = dims[2]
      const sx = Math.min(dimX - 1, Math.max(0, Math.round(x / Math.max(1, w - 1) * (dimX - 1))))
      const sy = Math.min(dimY - 1, Math.max(0, Math.round((h - 1 - y) / Math.max(1, h - 1) * (dimY - 1))))
      const sz = Math.min(dimZ - 1, Math.max(0, this.currentSlice - 1))
      if (viewKey === 'coronal') {
        const fixedY = this.getReferencePlaneIndex('coronal', dimX, dimY, dimZ)
        const z = Math.min(dimZ - 1, Math.max(0, Math.round((h - 1 - y) / Math.max(1, h - 1) * (dimZ - 1))))
        return data[sx + fixedY * dimX + z * dimX * dimY]
      }
      if (viewKey === 'sagittal') {
        const fixedX = this.getReferencePlaneIndex('sagittal', dimX, dimY, dimZ)
        const y2 = Math.min(dimY - 1, Math.max(0, Math.round(x / Math.max(1, w - 1) * (dimY - 1))))
        const z2 = Math.min(dimZ - 1, Math.max(0, Math.round((h - 1 - y) / Math.max(1, h - 1) * (dimZ - 1))))
        return data[fixedX + y2 * dimX + z2 * dimX * dimY]
      }
      if (viewKey === 'volume') {
        for (let z3 = 0; z3 < dimZ; z3 += 3) {
          if (data[sx + sy * dimX + z3 * dimX * dimY]) return 1
        }
        return 0
      }
      return data[sx + sy * dimX + sz * dimX * dimY]
    },
    drawAnnotationMark(ctx, mark, pending) {
      const color = this.getLabelColor(mark.labelId)
      if (mark.type === 'erase') {
        ctx.globalCompositeOperation = 'destination-out'
        ctx.fillStyle = 'rgba(0,0,0,1)'
        ctx.beginPath()
        ctx.arc(mark.x, mark.y, mark.r || this.brushSize, 0, Math.PI * 2)
        ctx.fill()
        ctx.globalCompositeOperation = 'source-over'
        return
      }
      ctx.globalCompositeOperation = 'source-over'
      if (mark.type === 'brush') {
        ctx.fillStyle = color
        ctx.beginPath()
        ctx.arc(mark.x, mark.y, mark.r || this.brushSize, 0, Math.PI * 2)
        ctx.fill()
        return
      }
      if (mark.type === 'box') {
        ctx.strokeStyle = color
        ctx.fillStyle = this.hexToRgba(color, pending ? 0.2 : 0.12)
        ctx.lineWidth = pending ? 1 : 2
        ctx.fillRect(mark.x, mark.y, mark.w || 1, mark.h || 1)
        ctx.strokeRect(mark.x, mark.y, mark.w || 1, mark.h || 1)
        return
      }
      if (mark.type === 'ruler') {
        ctx.strokeStyle = '#f8fafc'
        ctx.fillStyle = '#f8fafc'
        ctx.lineWidth = 2
        ctx.beginPath()
        ctx.moveTo(mark.x, mark.y)
        ctx.lineTo(mark.x2 || mark.x, mark.y2 || mark.y)
        ctx.stroke()
        ctx.font = '12px Arial'
        ctx.fillText(`${(mark.length || 0).toFixed(1)} mm`, (mark.x + (mark.x2 || mark.x)) / 2 + 6, (mark.y + (mark.y2 || mark.y)) / 2 - 6)
      }
    },
    getWindowTone() {
      const bright = Math.max(0, Math.min(1, (this.windowCenter + 120) / 260))
      const contrast = Math.max(0.7, Math.min(1.3, this.windowWidth / 420))
      const center = Math.round(210 + bright * 26)
      const mid = Math.round(105 + bright * 38)
      const edge = Math.round(42 * contrast)
      return {
        center: `rgb(${center}, ${center + 4}, ${center + 7})`,
        mid: `rgb(${mid}, ${mid + 10}, ${mid + 16})`,
        edge: `rgb(${edge}, ${edge + 8}, ${edge + 14})`
      }
    },
    hexToRgba(hex, alpha) {
      const value = hex.replace('#', '')
      const r = parseInt(value.substring(0, 2), 16)
      const g = parseInt(value.substring(2, 4), 16)
      const b = parseInt(value.substring(4, 6), 16)
      return `rgba(${r}, ${g}, ${b}, ${alpha})`
    },
    getLabelCount(labelId) {
      return this.annotationMarks.filter(item => item.labelId === labelId && item.type !== 'ruler').length
    },
    getLabelName(labelId) {
      const label = this.labels.find(item => item.id === labelId)
      return label ? label.name : '未分类'
    },
    getLabelColor(labelId) {
      const label = this.labels.find(item => item.id === labelId)
      return label ? label.color : '#18bc7e'
    },
    getToolText(type) {
      const map = {
        box: '框选',
        brush: '补画',
        erase: '擦除',
        ruler: '测量'
      }
      return map[type] || type
    },
    getViewName(viewKey) {
      const view = this.views.find(item => item.key === viewKey)
      return view ? view.name : viewKey
    },
    formatShortTime(date) {
      const pad = value => String(value).padStart(2, '0')
      return `${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
    },
    formatDateTime(date) {
      const pad = value => String(value).padStart(2, '0')
      return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
    },
    goBack() {
      this.$router.push('/radiologistDashboard')
    }
  }
}
</script>

<style lang="scss" scoped>
.imaging-workstation {
  min-height: calc(100vh - 112px);
  display: flex;
  flex-direction: column;
  color: #1f332d;
  background: #edf4f1;
}

.workstation-topbar {
  display: grid;
  grid-template-columns: 320px minmax(360px, 1fr) auto;
  align-items: center;
  gap: 14px;
  padding: 12px 16px;
  margin-bottom: 12px;
  border: 1px solid #d9e8e2;
  border-radius: 8px;
  background: #ffffff;
}

.brand-block {
  display: flex;
  align-items: center;
  gap: 12px;

  h2 {
    margin: 0;
    color: #075f42;
    font-size: 18px;
  }

  p {
    margin: 4px 0 0;
    color: #60756e;
    font-size: 12px;
  }
}

.brand-mark {
  width: 42px;
  height: 42px;
  border-radius: 8px;
  background: #0f8f61;
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
}

.case-strip {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;

  span {
    padding: 6px 10px;
    border-radius: 999px;
    background: #edf8f3;
    color: #2f5d4f;
    font-size: 12px;
  }
}

.top-actions {
  display: flex;
  gap: 8px;
  justify-content: flex-end;
}

.workstation-body {
  flex: 1;
  min-height: 680px;
  display: grid;
  grid-template-columns: 248px minmax(620px, 1fr) 318px;
  gap: 12px;
}

.left-dock,
.right-dock {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-width: 0;
}

.dock-panel {
  border: 1px solid #d9e8e2;
  border-radius: 8px;
  background: #ffffff;
  padding: 12px;
}

.panel-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;

  span {
    color: #075f42;
    font-weight: 700;
    font-size: 14px;
  }

  small {
    color: #7c9089;
    font-size: 12px;
  }
}

.dataset-card {
  display: grid;
  grid-template-columns: 40px 1fr;
  gap: 10px;
  align-items: center;
  padding: 10px;
  margin-bottom: 8px;
  border: 1px solid #e1eee8;
  border-radius: 8px;
  background: #fbfefd;

  &.active {
    border-color: #9bd8bf;
    background: #effaf5;
  }

  &.label-file {
    background: #f8fbff;
  }

  strong {
    display: block;
    color: #1f332d;
    font-size: 13px;
  }

  p {
    margin: 4px 0 0;
    color: #6b7f78;
    font-size: 12px;
  }
}

.dataset-icon {
  width: 38px;
  height: 38px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  background: #0f8f61;
  color: #ffffff;
  font-weight: 700;
  font-size: 12px;

  &.label {
    background: #2f80ed;
  }
}

.meta-list {
  display: grid;
  grid-template-columns: 64px 1fr;
  gap: 6px 8px;
  margin: 10px 0 0;
  font-size: 12px;

  dt {
    color: #7c9089;
  }

  dd {
    margin: 0;
    color: #334a43;
    word-break: break-all;
  }
}

.series-row,
.slice-row,
.label-row {
  width: 100%;
  border: 1px solid transparent;
  border-radius: 6px;
  background: transparent;
  color: #435a53;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  padding: 8px 10px;
  margin-bottom: 4px;
  cursor: pointer;
  text-align: left;

  &:hover,
  &.active {
    border-color: #bfe7d4;
    background: #eaf8f1;
    color: #075f42;
  }

  small {
    color: #7c9089;
  }
}

.slice-list {
  max-height: 176px;
  overflow: auto;
}

.slice-row {
  font-family: Consolas, monospace;
  font-size: 12px;
}

.label-row {
  justify-content: flex-start;

  i {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    box-shadow: 0 0 0 3px rgba(15, 143, 97, 0.08);
  }

  span {
    flex: 1;
  }
}

.viewer-center {
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.viewport-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 10px 12px;
  border: 1px solid #d9e8e2;
  border-radius: 8px;
  background: #ffffff;
}

.tool-tabs {
  display: flex;
  gap: 6px;

  button {
    border: 1px solid #d7e6df;
    border-radius: 6px;
    background: #ffffff;
    color: #425b53;
    padding: 7px 10px;
    cursor: pointer;

    &.active,
    &:hover {
      border-color: #0f8f61;
      background: #0f8f61;
      color: #ffffff;
    }
  }
}

.view-status {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  justify-content: flex-end;

  span {
    color: #60756e;
    font-size: 12px;
  }
}

.viewport-grid {
  flex: 1;
  min-height: 620px;
  display: grid;
  grid-template-columns: repeat(2, minmax(280px, 1fr));
  gap: 12px;
}

.viewport {
  min-width: 0;
  min-height: 290px;
  display: flex;
  flex-direction: column;
  border: 2px solid #d9e8e2;
  border-radius: 8px;
  overflow: hidden;
  background: #0b1114;

  &.active {
    border-color: #0f8f61;
    box-shadow: 0 0 0 3px rgba(15, 143, 97, 0.12);
  }
}

.viewport-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 10px;
  background: #ffffff;
  color: #075f42;

  span {
    font-weight: 700;
    font-size: 13px;
  }

  small {
    color: #71877f;
    font-size: 12px;
  }
}

.canvas-stack {
  position: relative;
  flex: 1;
  min-height: 252px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  cursor: crosshair;

  canvas {
    width: 100%;
    height: 100%;
    object-fit: contain;
  }
}

.mask-layer {
  position: absolute;
  inset: 0;
}

.crosshair {
  position: absolute;
  pointer-events: none;
  background: rgba(255, 255, 255, 0.16);

  &.horizontal {
    left: 6%;
    right: 6%;
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

.annotation-panel {
  border-color: #bfe7d4;
}

.active-label {
  display: grid;
  grid-template-columns: 18px 1fr;
  gap: 10px;
  align-items: start;
  padding: 10px;
  border-radius: 8px;
  background: #f4fbf8;

  i {
    width: 18px;
    height: 18px;
    border-radius: 50%;
    margin-top: 3px;
  }

  strong {
    color: #1f332d;
  }

  p {
    margin: 4px 0 0;
    color: #6b7f78;
    font-size: 12px;
    line-height: 1.5;
  }
}

.slider-row {
  display: grid;
  grid-template-columns: 76px 1fr 48px;
  gap: 8px;
  align-items: center;
  margin-top: 10px;
  color: #556b63;
  font-size: 12px;

  b {
    color: #075f42;
    text-align: right;
  }
}

.model-placeholder {
  padding: 12px;
  border-radius: 8px;
  border: 1px dashed #adcfc0;
  background: #fbfefd;
  text-align: center;

  i {
    display: block;
    margin-bottom: 8px;
    color: #0f8f61;
    font-size: 24px;
  }

  strong {
    color: #075f42;
  }

  p {
    margin: 8px 0 12px;
    color: #60756e;
    font-size: 12px;
    line-height: 1.6;
    text-align: left;
  }
}

.metric-box {
  padding: 10px;
  border: 1px dashed #9bbcaf;
  border-radius: 8px;
  background: #f5fbf8;

  p {
    margin: 4px 0;
    color: #344a42;
    font-size: 12px;
  }
}

.metric-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 8px;
  margin-top: 10px;

  div {
    padding: 10px;
    border-radius: 8px;
    background: #f7faf9;
  }

  span {
    display: block;
    color: #70847d;
    font-size: 12px;
  }

  strong {
    display: block;
    margin-top: 4px;
    color: #075f42;
    font-size: 14px;
  }
}

.annotation-list {
  max-height: 220px;
  overflow: auto;
}

.annotation-row {
  display: grid;
  grid-template-columns: 10px 1fr;
  gap: 9px;
  padding: 8px 0;
  border-bottom: 1px solid #edf4f1;

  &:last-child {
    border-bottom: none;
  }

  i {
    width: 10px;
    height: 10px;
    margin-top: 5px;
    border-radius: 50%;
  }

  strong {
    color: #2e463f;
    font-size: 12px;
  }

  p {
    margin: 4px 0 0;
    color: #71877f;
    font-size: 12px;
  }
}

.case-summary {
  margin: 0;
  color: #4b625b;
  font-size: 13px;
  line-height: 1.7;
}

.bottom-toolbar {
  display: flex;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 12px;
  padding: 12px;
  border: 1px solid #d9e8e2;
  border-radius: 8px;
  background: #ffffff;
}

.tool-group {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;

  button {
    min-width: 72px;
    height: 36px;
    border: 1px solid #d7e6df;
    border-radius: 6px;
    background: #ffffff;
    color: #36534a;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 5px;
    cursor: pointer;

    &:hover,
    &.active {
      border-color: #0f8f61;
      background: #0f8f61;
      color: #ffffff;
    }

    &.success {
      border-color: #16a36d;
      background: #16a36d;
      color: #ffffff;
    }

    &.primary {
      border-color: #1f7ed8;
      background: #1f7ed8;
      color: #ffffff;
    }
  }

  &.secondary button {
    min-width: 62px;
  }
}

@media (max-width: 1320px) {
  .workstation-topbar {
    grid-template-columns: 1fr;
  }

  .top-actions {
    justify-content: flex-start;
  }

  .workstation-body {
    grid-template-columns: 220px minmax(560px, 1fr);
  }

  .right-dock {
    grid-column: 1 / -1;
    display: grid;
    grid-template-columns: repeat(3, minmax(220px, 1fr));
  }
}

@media (max-width: 980px) {
  .workstation-body {
    grid-template-columns: 1fr;
  }

  .viewport-grid {
    grid-template-columns: 1fr;
  }

  .right-dock {
    display: flex;
  }
}
</style>
