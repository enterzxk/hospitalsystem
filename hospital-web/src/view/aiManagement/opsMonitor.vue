<template>
  <div class="ops-monitor-page">
    <div class="page-header">
      <div>
        <h2>{{ pageTitle }}</h2>
        <p>{{ pageDescription }}</p>
      </div>
      <el-button icon="el-icon-refresh" @click="load">刷新</el-button>
    </div>

    <el-row v-if="!isAuditRoute" :gutter="16">
      <el-col v-for="item in cards" :key="item.key" :span="6">
        <el-card class="status-card">
          <span>{{ item.label }}</span>
          <strong>{{ item.value }}</strong>
        </el-card>
      </el-col>
    </el-row>

    <el-card class="audit-card">
      <div slot="header" class="audit-header">
        <span>{{ isAuditRoute ? '审计日志查询' : '最近审计日志' }}</span>
        <small>覆盖登录、上传、推理、确认、报告提交、模型变更等关键动作</small>
      </div>
      <el-form :inline="true" :model="auditFilters" class="audit-filter">
        <el-form-item label="账号">
          <el-input v-model="auditFilters.accountName" placeholder="用户账号" clearable></el-input>
        </el-form-item>
        <el-form-item label="动作">
          <el-select v-model="auditFilters.action" placeholder="全部动作" clearable>
            <el-option label="登录" value="login"></el-option>
            <el-option label="影像上传" value="study_upload"></el-option>
            <el-option label="AI 推理" value="ai_infer"></el-option>
            <el-option label="结果确认" value="result_confirm"></el-option>
            <el-option label="报告提交" value="report_submit"></el-option>
            <el-option label="模型变更" value="model_update"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="资源">
          <el-input v-model="auditFilters.resourceType" placeholder="study/report/model" clearable></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" @click="load">查询</el-button>
          <el-button @click="resetAuditFilters">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="logs" height="360">
        <el-table-column prop="accountName" label="账号" width="105"></el-table-column>
        <el-table-column prop="actionLabel" label="动作类型" width="105"></el-table-column>
        <el-table-column prop="description" label="动作说明" min-width="150" show-overflow-tooltip></el-table-column>
        <el-table-column prop="resourceType" label="资源类型" width="95"></el-table-column>
        <el-table-column prop="uri" label="资源" min-width="170" show-overflow-tooltip></el-table-column>
        <el-table-column prop="resultStatus" label="结果" width="76">
          <template slot-scope="scope">
            <el-tooltip v-if="scope.row.resultDetail" :content="scope.row.resultDetail" placement="top">
              <el-tag size="mini" :type="resultTagType(scope.row.resultStatus)">{{ scope.row.resultStatus }}</el-tag>
            </el-tooltip>
            <el-tag v-else size="mini" :type="resultTagType(scope.row.resultStatus)">{{ scope.row.resultStatus }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="displayTime" label="时间" width="170" class-name="audit-time-column"></el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script>
import { getOpsStatus, getAuditLogs } from '@/api/ai'

export default {
  name: 'opsMonitor',
  data() {
    return {
      status: {},
      logs: [],
      auditFilters: {
        accountName: '',
        action: '',
        resourceType: ''
      }
    }
  },
  computed: {
    isAuditRoute() {
      return this.$route.path === '/auditLogs'
    },
    pageTitle() {
      return this.isAuditRoute ? '审计日志' : 'AI 运维监控'
    },
    pageDescription() {
      return this.isAuditRoute
        ? '按用户、动作和资源追踪影像上传、AI 推理、结果确认、报告提交与模型变更。'
        : '查看 API、AI Worker、队列、对象存储、数据库和 GPU 服务状态。'
    },
    cards() {
      return [
        { key: 'api', label: '后端 API', value: this.status.api || 'UNKNOWN' },
        { key: 'postgresql', label: 'PostgreSQL', value: this.componentState(this.status.postgresql) },
        { key: 'redis', label: 'Redis 队列', value: this.componentState(this.status.redis) },
        { key: 'aiGateway', label: 'AI Gateway', value: this.status.aiGateway || 'UNKNOWN' },
        { key: 'queueLength', label: '队列长度', value: this.status.queueLength === undefined ? '-' : this.status.queueLength },
        { key: 'gpu', label: 'GPU', value: this.status.gpu || 'OPTIONAL' },
        { key: 'seg', label: '分割 Worker', value: this.status.segmentationWorker || 'DEMO_READY' },
        { key: 'det', label: '检测 Worker', value: this.status.detectionWorker || 'DEMO_READY' },
        { key: 'cls', label: '分类 Worker', value: this.status.classificationWorker || 'DEMO_READY' },
        { key: 'storage', label: 'MinIO/NAS', value: this.componentState(this.status.objectStorage) }
      ]
    }
  },
  created() {
    this.load()
  },
  methods: {
    load() {
      if (!this.isAuditRoute) {
        getOpsStatus().then(res => {
          this.status = res.code === 200 ? res.data : {}
        }).catch(() => {
          this.status = {
            api: 'DOWN',
            postgresql: { state: 'UNKNOWN' },
            redis: { state: 'UNKNOWN' },
            objectStorage: { state: 'UNKNOWN' },
            aiGateway: 'UNKNOWN',
            queueLength: -1
          }
        })
      }
      getAuditLogs(Object.assign({ pageNum: 1, pageSize: 20 }, this.buildAuditParams())).then(res => {
        const rows = res.code === 200 && res.data && res.data.list ? res.data.list : []
        this.logs = this.applyLocalAuditFilters(rows.length ? rows : this.defaultAuditLogs())
      }).catch(() => {
        this.logs = this.applyLocalAuditFilters(this.defaultAuditLogs())
      })
    },
    buildAuditParams() {
      return {
        accountName: this.auditFilters.accountName || undefined,
        action: this.auditFilters.action || undefined,
        resourceType: this.auditFilters.resourceType || undefined
      }
    },
    resetAuditFilters() {
      this.auditFilters = {
        accountName: '',
        action: '',
        resourceType: ''
      }
      this.load()
    },
    applyLocalAuditFilters(rows) {
      return rows.map(this.normalizeAuditLog).filter(item => {
        const accountMatch = !this.auditFilters.accountName || String(item.accountName || '').includes(this.auditFilters.accountName)
        const actionMatch = !this.auditFilters.action || item.action === this.auditFilters.action
        const resourceMatch = !this.auditFilters.resourceType || String(item.resourceType || '').toLowerCase().includes(this.auditFilters.resourceType.toLowerCase())
        return accountMatch && actionMatch && resourceMatch
      })
    },
    normalizeAuditLog(item) {
      const action = this.resolveAuditAction(item)
      const resultStatus = this.resolveAuditResult(item.result)
      return Object.assign({}, item, {
        action,
        actionLabel: this.auditActionLabel(action, item),
        description: item.description || this.auditActionLabel(action, item),
        resourceType: item.resourceType || this.resolveResourceType(item),
        uri: item.uri || item.url || '-',
        resultStatus,
        resultDetail: this.formatResultDetail(item.result),
        displayTime: this.formatAuditTime(item.gmtCreate || item.createTime || item.startTime || item.time)
      })
    },
    resolveAuditAction(item) {
      if (item.action) {
        return item.action
      }
      const text = [item.description, item.uri, item.url, item.parameter].filter(Boolean).join(' ')
      if (/登录|login/i.test(text)) return 'login'
      if (/上传|studies\/upload|影像标准数据入库/i.test(text)) return 'study_upload'
      if (/推理|infer|AI/i.test(text)) return 'ai_infer'
      if (/确认|confirm/i.test(text)) return 'result_confirm'
      if (/报告|reports/i.test(text)) return 'report_submit'
      if (/模型|models/i.test(text)) return 'model_update'
      return item.method || 'API'
    },
    auditActionLabel(action, item) {
      const labels = {
        login: '登录',
        study_upload: '影像上传',
        ai_infer: 'AI 推理',
        result_confirm: '结果确认',
        report_submit: '报告提交',
        model_update: '模型变更'
      }
      return labels[action] || item.description || action || 'API'
    },
    resolveResourceType(item) {
      const uri = String(item.uri || item.url || '')
      if (uri.includes('/studies') || uri.includes('/imaging')) return 'study'
      if (uri.includes('/ai/infer')) return 'inference_job'
      if (uri.includes('/results')) return 'ai_result'
      if (uri.includes('/reports')) return 'report'
      if (uri.includes('/models')) return 'model'
      if (uri.includes('/ops')) return 'ops'
      if (uri.includes('/audit-logs')) return 'audit'
      return item.method || 'api'
    },
    resolveAuditResult(result) {
      const value = String(result || '').trim()
      if (!value) {
        return '成功'
      }
      if (/fail|error|exception|失败|错误/i.test(value)) {
        return '失败'
      }
      if (/CommonResult|success|SUCCESS|code=200|code":200|成功/i.test(value)) {
        return '成功'
      }
      return value.length > 8 ? '已记录' : value
    },
    formatResultDetail(result) {
      const value = String(result || '').trim()
      if (!value || value === 'SUCCESS') {
        return ''
      }
      return value.length > 120 ? value.slice(0, 120) + '...' : value
    },
    resultTagType(status) {
      if (status === '失败') {
        return 'danger'
      }
      if (status === '已记录') {
        return 'info'
      }
      return 'success'
    },
    formatAuditTime(value) {
      if (!value) {
        return '-'
      }
      if (typeof value === 'string' && /^\d+$/.test(value.trim())) {
        value = Number(value.trim())
      }
      if (typeof value === 'number') {
        value = value < 100000000000 ? value * 1000 : value
      }
      const date = value instanceof Date ? value : new Date(value)
      if (Number.isNaN(date.getTime())) {
        return String(value)
      }
      const pad = number => String(number).padStart(2, '0')
      return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
    },
    defaultAuditLogs() {
      return [
        { accountName: 'admin', action: 'study_upload', description: '上传胸部 CT NIfTI 影像并生成 Study-Series-Instance 记录', resourceType: 'study', uri: '/api/studies/upload ST10001', result: 'SUCCESS', gmtCreate: '2026-07-07 09:12:20' },
        { accountName: 'radiologist1', action: 'ai_infer', description: '创建候选检测任务 lesion_det_demo_v1', resourceType: 'inference_job', uri: '/api/ai/infer/detection JOB202607070001', result: 'SUCCESS', gmtCreate: '2026-07-07 09:15:42' },
        { accountName: 'radiologist1', action: 'ai_infer', description: '创建 MedSAM 分割任务 medsam_v1.0', resourceType: 'segmentation_result', uri: '/api/ai/infer/segmentation SEG202607070001', result: 'SUCCESS', gmtCreate: '2026-07-07 09:16:10' },
        { accountName: 'radiologist1', action: 'result_confirm', description: '采纳 AI 分割测量和分类辅助提示', resourceType: 'ai_result', uri: '/api/results/SEG202607070001/confirm', result: 'SUCCESS', gmtCreate: '2026-07-07 09:18:36' },
        { accountName: 'doctor1', action: 'report_submit', description: '提交结构化诊断报告，诊断意见由医生填写', resourceType: 'report', uri: '/api/reports/RPT202607070001/submit', result: 'SUCCESS', gmtCreate: '2026-07-07 09:26:05' },
        { accountName: 'admin', action: 'model_update', description: '启用分类模型 lesion_cls_demo_v1', resourceType: 'model', uri: '/api/models/lesion_cls_demo_v1', result: 'SUCCESS', gmtCreate: '2026-07-07 09:40:11' }
      ]
    },
    componentState(value) {
      if (!value) {
        return 'UNKNOWN'
      }
      if (typeof value === 'string') {
        return value
      }
      return value.state || 'UNKNOWN'
    }
  }
}
</script>

<style lang="scss" scoped>
.ops-monitor-page {
  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;

    h2 {
      margin: 0;
      font-size: 20px;
    }

    p {
      margin: 6px 0 0;
      color: #6b7280;
      font-size: 13px;
    }
  }

  .status-card {
    margin-bottom: 16px;

    span,
    strong {
      display: block;
    }

    span {
      color: #6b7280;
      font-size: 13px;
      margin-bottom: 8px;
    }

    strong {
      color: #075f42;
      font-size: 22px;
    }
  }

  .audit-card {
    margin-top: 10px;
  }

  .audit-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;

    span {
      color: #075f42;
      font-weight: 700;
    }

    small {
      color: #7c8f88;
      font-size: 12px;
    }
  }

  .audit-filter {
    margin-bottom: 12px;
    padding: 10px 12px;
    border-radius: 8px;
    background: #f7faf9;
  }
}
</style>
