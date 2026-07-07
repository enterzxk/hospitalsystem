<template>
  <section class="dock-panel ai-result-panel">
    <div class="ai-panel-head">
      <div>
        <span>AI 多任务结果</span>
        <small>候选检测、MedSAM 分割、分类与草稿生成</small>
      </div>
      <em :class="{ active: running }">{{ running ? '推理中' : '可操作' }}</em>
    </div>

    <div class="ai-panel-body">
      <div class="ai-action-grid">
        <el-button size="mini" type="primary" icon="el-icon-aim" :loading="runningTask === 'detection'" @click="$emit('run-detection')">候选检测</el-button>
        <el-button size="mini" type="success" icon="el-icon-crop" :loading="runningTask === 'segmentation'" @click="$emit('run-segmentation')">MedSAM 分割</el-button>
        <el-button size="mini" type="warning" icon="el-icon-data-analysis" :loading="runningTask === 'classification'" @click="$emit('run-classification')">病灶分类</el-button>
        <el-button size="mini" icon="el-icon-document" @click="$emit('create-draft')">报告草稿</el-button>
      </div>

      <div class="model-line">
        <span>模型链路</span>
        <strong>Det demo / MedSAM v1.0 / Cls demo</strong>
      </div>

      <div class="summary-strip">
        <div>
          <span>候选</span>
          <strong>{{ detectionBoxes.length }} 个</strong>
        </div>
        <div>
          <span>分割</span>
          <strong>{{ segmentationSummary.status }}</strong>
        </div>
        <div>
          <span>分类</span>
          <strong>{{ classificationSummary.confidence }}</strong>
        </div>
      </div>

      <div class="result-block">
        <div class="block-title">
          <span>检测候选框</span>
          <em>{{ detectionBoxes.length }} 个</em>
        </div>
        <div v-if="detectionBoxes.length" class="candidate-list">
          <button
            v-for="box in detectionBoxes"
            :key="box.id"
            type="button"
            class="candidate-row"
            :class="{ active: box.id === selectedCandidateId }"
            @click="$emit('apply-box', box)">
            <span>{{ box.label }}</span>
            <strong>{{ percent(box.confidence) }}</strong>
          </button>
        </div>
        <el-empty v-else description="暂无候选框" :image-size="42"></el-empty>
      </div>

      <div class="result-block">
        <div class="block-title">
          <span>分割测量</span>
          <em>{{ segmentationSummary.status }}</em>
        </div>
        <div class="measure-grid">
          <div>
            <span>长径</span>
            <strong>{{ segmentationSummary.longDiameter }}</strong>
          </div>
          <div>
            <span>短径</span>
            <strong>{{ segmentationSummary.shortDiameter }}</strong>
          </div>
          <div>
            <span>面积</span>
            <strong>{{ segmentationSummary.area }}</strong>
          </div>
          <div>
            <span>体积</span>
            <strong>{{ segmentationSummary.volume }}</strong>
          </div>
        </div>
      </div>

      <div class="result-block classification-block">
        <div class="block-title">
          <span>分类提示</span>
          <em>{{ classificationSummary.confidence }}</em>
        </div>
        <div class="classification-line">
          <strong>{{ classificationSummary.label }}</strong>
          <span>AI 结果仅供医生参考</span>
        </div>
      </div>

      <div class="ai-reference-card">
        <div class="reference-heading">
          <div>
            <span>AI 诊断参考</span>
            <small>{{ aiReferenceReport.status }}</small>
          </div>
          <el-button size="mini" type="text" icon="el-icon-document" @click="$emit('create-draft')">生成草稿</el-button>
        </div>
        <div class="reference-section">
          <strong>影像所见建议</strong>
          <p>{{ aiReferenceReport.findings }}</p>
        </div>
        <div class="reference-section">
          <strong>辅助印象</strong>
          <p>{{ aiReferenceReport.impression }}</p>
        </div>
        <div class="reference-evidence">
          <span v-for="line in aiReferenceReport.evidence" :key="line">{{ line }}</span>
        </div>
        <div class="reference-notice">
          AI 诊断参考不得作为最终诊断结论，正式诊断意见必须由主治医生结合临床资料填写。
        </div>
      </div>

      <div class="confirm-list" v-if="allResults.length">
        <div class="block-title compact">
          <span>结果确认</span>
          <em>{{ allResults.length }} 条</em>
        </div>
        <div v-for="item in allResults" :key="item.localId" class="confirm-row">
          <div>
            <strong>{{ taskName(item.taskType) }}</strong>
            <span>{{ item.modelName }} {{ item.modelVersion }}</span>
          </div>
          <el-tag size="mini" :type="item.confirmStatus === 1 ? 'success' : 'info'">
            {{ item.confirmStatus === 1 ? '已采纳' : '待确认' }}
          </el-tag>
          <el-button size="mini" type="text" @click="$emit('confirm-result', item)">采纳</el-button>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: 'AiResultPanel',
  props: {
    caseInfo: { type: Object, default: () => ({}) },
    manualAnnotationCount: { type: Number, default: 0 },
    detectionResults: { type: Array, default: () => [] },
    segmentationResults: { type: Array, default: () => [] },
    classificationResults: { type: Array, default: () => [] },
    selectedCandidateId: { type: String, default: '' },
    runningTask: { type: String, default: '' }
  },
  computed: {
    running() {
      return !!this.runningTask
    },
    detectionBoxes() {
      const latest = this.detectionResults[0]
      if (!latest || !latest.parsed || !latest.parsed.boxes) return []
      return latest.parsed.boxes
    },
    segmentationSummary() {
      const latest = this.segmentationResults[0]
      const measurements = latest && latest.parsed ? latest.parsed.measurements || {} : {}
      return {
        status: latest ? (latest.confirmStatus === 1 ? '已采纳' : '待确认') : '暂无',
        longDiameter: measurements.long_diameter_mm ? measurements.long_diameter_mm + ' mm' : '-',
        shortDiameter: measurements.short_diameter_mm ? measurements.short_diameter_mm + ' mm' : '-',
        area: measurements.area_mm2 ? measurements.area_mm2 + ' mm²' : '-',
        volume: measurements.volume_cm3 ? measurements.volume_cm3 + ' cm³' : '-'
      }
    },
    classificationSummary() {
      const latest = this.classificationResults[0]
      if (!latest || !latest.parsed) {
        return { label: '暂无分类结果', confidence: '-' }
      }
      return {
        label: latest.parsed.label || '未命名类别',
        confidence: this.percent(latest.parsed.confidence)
      }
    },
    aiReferenceReport() {
      const modality = this.caseInfo.type || this.caseInfo.modality || '影像'
      const bodyPart = this.caseInfo.bodyPart || this.caseInfo.body_part || '检查部位'
      const detectionCount = this.detectionBoxes.length
      const segmentation = this.segmentationResults[0]
      const classification = this.classificationResults[0]
      const measurements = segmentation && segmentation.parsed ? segmentation.parsed.measurements || {} : {}
      const classificationLabel = classification && classification.parsed ? classification.parsed.label : ''
      const classificationConfidence = classification && classification.parsed ? this.percent(classification.parsed.confidence) : '-'
      const evidence = []

      if (detectionCount) {
        evidence.push('检测候选框 ' + detectionCount + ' 个')
      }
      if (measurements.area_mm2) {
        evidence.push('面积 ' + measurements.area_mm2 + ' mm²')
      }
      if (measurements.volume_cm3) {
        evidence.push('体积 ' + measurements.volume_cm3 + ' cm³')
      }
      if (classificationLabel) {
        evidence.push('分类 ' + classificationLabel + ' ' + classificationConfidence)
      }
      if (this.manualAnnotationCount) {
        evidence.push('人工标注 ' + this.manualAnnotationCount + ' 条')
      }

      const hasAiEvidence = detectionCount || segmentation || classification
      const sizeText = measurements.long_diameter_mm
        ? '长径约 ' + measurements.long_diameter_mm + ' mm，短径约 ' + (measurements.short_diameter_mm || '-') + ' mm，面积约 ' + (measurements.area_mm2 || '-') + ' mm²，体积约 ' + (measurements.volume_cm3 || '-') + ' cm³'
        : ''
      const findings = hasAiEvidence
        ? bodyPart + ' ' + modality + ' 检查中，AI 已完成候选区域分析' + (sizeText ? '，分割测量提示病灶' + sizeText : '') + '。建议结合原始切片、窗宽窗位和人工标注结果复核。'
        : '尚未形成 AI 参考报告。请先运行候选检测、MedSAM 分割或病灶分类后再查看。'
      const impression = classificationLabel
        ? 'AI 辅助分类倾向为“' + classificationLabel + '”，置信度 ' + classificationConfidence + '。该提示仅用于辅助阅片和报告草稿撰写。'
        : (hasAiEvidence ? 'AI 已形成候选区域和测量结果，但尚未给出分类倾向；建议继续运行病灶分类或由医生人工判断。' : '暂无辅助印象。')

      return {
        status: hasAiEvidence ? '已生成' : '待生成',
        findings,
        impression,
        evidence: evidence.length ? evidence : ['等待 AI 分析结果']
      }
    },
    allResults() {
      return [].concat(this.detectionResults, this.segmentationResults, this.classificationResults)
    }
  },
  methods: {
    percent(value) {
      if (value === undefined || value === null || value === '') return '-'
      return Math.round(Number(value) * 100) + '%'
    },
    taskName(taskType) {
      const map = { detection: '候选检测', segmentation: '分割测量', classification: '病灶分类' }
      return map[taskType] || taskType
    }
  }
}
</script>

<style lang="scss" scoped>
.ai-result-panel {
  padding: 0;
  overflow: hidden;
  border-color: #c6e3d8;

  .ai-panel-head {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 12px;
    padding: 12px 14px;
    border-bottom: 1px solid #d8eee5;
    background: #f7fbf9;

    span,
    small {
      display: block;
    }

    span {
      color: #075f42;
      font-weight: 700;
      font-size: 15px;
    }

    small {
      margin-top: 3px;
      color: #6f837c;
      font-size: 12px;
      line-height: 1.4;
    }

    em {
      flex: 0 0 auto;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      height: 24px;
      min-width: 56px;
      padding: 0 8px;
      border-radius: 999px;
      background: #e8f4ee;
      color: #0f694a;
      font-size: 12px;
      font-style: normal;

      &.active {
        background: #0f8f61;
        color: #ffffff;
      }
    }
  }

  .ai-panel-body {
    display: flex;
    flex-direction: column;
    gap: 9px;
    padding: 12px;
  }

  .ai-action-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 8px;

    .el-button {
      width: 100%;
      min-height: 34px;
      margin-left: 0;
      display: inline-flex;
      align-items: center;
      justify-content: center;
    }
  }

  .model-line {
    display: grid;
    grid-template-columns: 58px minmax(0, 1fr);
    align-items: center;
    gap: 8px;
    padding: 9px 10px;
    border-radius: 8px;
    background: #f0f9f5;
    color: #6b7f78;
    font-size: 12px;

    strong {
      color: #075f42;
      text-align: right;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }

  .summary-strip {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 8px;

    div {
      min-width: 0;
      padding: 8px 10px;
      border: 1px solid #d8eee5;
      border-radius: 8px;
      background: #fbfffd;
    }

    span,
    strong {
      display: block;
    }

    span {
      color: #789087;
      font-size: 12px;
    }

    strong {
      margin-top: 4px;
      color: #064e3b;
      font-size: 13px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }

  .result-block {
    padding: 9px;
    border: 1px solid #d8eee5;
    border-radius: 8px;
    background: #fbfffd;
  }

  .block-title,
  .confirm-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
  }

  .block-title {
    margin-bottom: 9px;
    color: #075f42;
    font-weight: 700;

    &.compact {
      margin-bottom: 4px;
    }

    em {
      color: #7a9189;
      font-style: normal;
      font-size: 12px;
      font-weight: 400;
    }
  }

  .candidate-list {
    display: flex;
    flex-direction: column;
    gap: 6px;
    max-height: 108px;
    overflow-y: auto;
    padding-right: 2px;
  }

  .candidate-row {
    border: 1px solid #dbece5;
    background: #fff;
    border-radius: 6px;
    padding: 8px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    cursor: pointer;
    color: #33423e;

    span {
      min-width: 0;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      text-align: left;
    }

    strong {
      flex: 0 0 auto;
      color: #102d25;
    }

    &.active {
      border-color: #18bc7e;
      background: #eaf8f2;
      color: #075f42;
    }
  }

  .measure-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 8px;

    div {
      background: #f5faf8;
      border-radius: 6px;
      padding: 7px 8px;
    }

    span {
      display: block;
      color: #789087;
      font-size: 12px;
    }

    strong {
      color: #064e3b;
      font-size: 13px;
    }
  }

  .classification-line {
    padding: 8px 10px;
    border-radius: 8px;
    background: #f3faf7;

    strong,
    span {
      display: block;
    }

    strong {
      color: #064e3b;
      margin-bottom: 4px;
    }

    span {
      color: #789087;
      font-size: 12px;
    }
  }

  .ai-reference-card {
    max-height: 270px;
    overflow-y: auto;
    padding: 11px;
    border: 1px solid #bfe7d4;
    border-radius: 8px;
    background: #f6fffb;
  }

  .reference-heading {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 10px;
    margin-bottom: 10px;

    span,
    small {
      display: block;
    }

    span {
      color: #075f42;
      font-weight: 700;
    }

    small {
      margin-top: 2px;
      color: #7a9189;
      font-size: 12px;
    }

    .el-button {
      padding: 0;
      white-space: nowrap;
    }
  }

  .reference-section {
    padding-top: 8px;
    border-top: 1px dashed #d6eee4;

    strong {
      display: block;
      margin-bottom: 4px;
      color: #26463b;
      font-size: 13px;
    }

    p {
      margin: 0;
      color: #48625a;
      font-size: 12px;
      line-height: 1.65;
    }
  }

  .reference-evidence {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    margin-top: 10px;

    span {
      padding: 4px 7px;
      border-radius: 999px;
      background: #e7f6ef;
      color: #075f42;
      font-size: 12px;
    }
  }

  .reference-notice {
    margin-top: 10px;
    padding: 8px;
    border-radius: 6px;
    background: #fffbeb;
    color: #8a5a00;
    font-size: 12px;
    line-height: 1.6;
  }

  .confirm-list {
    max-height: 178px;
    overflow-y: auto;
    padding: 10px;
    border: 1px solid #e0eee8;
    border-radius: 8px;
    background: #fbfffd;
  }

  .confirm-row {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto auto;
    align-items: center;
    gap: 8px;
    border-top: 1px solid #edf4f1;
    padding: 8px 0;

    &:first-of-type {
      border-top: 0;
    }

    div {
      min-width: 0;
    }

    strong,
    span {
      display: block;
    }

    span {
      color: #7a9189;
      font-size: 12px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }
}
</style>
