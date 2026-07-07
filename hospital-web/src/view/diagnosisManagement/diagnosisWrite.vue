<template>
  <div class="diagnosis-write-page">
    <div class="page-header">
      <div>
        <h2>{{ pageTitle }}</h2>
        <p>{{ pageDescription }}</p>
      </div>
      <el-button icon="el-icon-back" @click="goBack">返回列表</el-button>
    </div>

    <div class="report-workbench">
      <section class="viewer-report-pane">
        <el-card class="viewer-card">
          <div slot="header" class="card-header-row">
            <div>
              <span>同屏阅片参考</span>
              <small>{{ selectedImaging.id ? selectedImaging.type + ' / ' + selectedImaging.bodyPart : '请选择影像' }}</small>
            </div>
            <el-button size="mini" type="text" icon="el-icon-full-screen" :disabled="!selectedImaging.id" @click="viewImaging">完整标注工作站</el-button>
          </div>

          <div v-if="selectedImaging.id" class="imaging-summary">
            <div class="case-meta-strip">
              <span>患者 {{ selectedImaging.patientName }}</span>
              <span>{{ selectedImaging.gender }} / {{ selectedImaging.age }}岁</span>
              <span>{{ selectedImaging.uploadTime }}</span>
              <span>{{ selectedImaging.remark || '暂无送检说明' }}</span>
            </div>

            <div class="inline-viewer">
              <div class="inline-viewer-toolbar">
                <el-radio-group v-model="inlineView" size="mini">
                  <el-radio-button v-for="view in inlineViews" :key="view.key" :label="view.key">{{ view.name }}</el-radio-button>
                </el-radio-group>
                <div class="inline-switches">
                  <el-checkbox v-model="inlineShowOverlay">AI 层</el-checkbox>
                  <el-checkbox v-model="inlineShowMask">Mask</el-checkbox>
                  <el-checkbox v-model="inlineShowCrosshair">十字线</el-checkbox>
                </div>
              </div>

              <div class="film-grid" :class="'view-' + inlineView" :style="viewerToneStyle">
                <div
                  v-for="view in inlineViews"
                  :key="view.key"
                  class="film-panel"
                  :class="{ active: inlineView === view.key }"
                  @click="inlineView = view.key">
                  <div class="film-title">
                    <span>{{ view.label }}</span>
                    <small>Slice {{ inlineSlice }}</small>
                  </div>
                  <div class="film-canvas">
                    <div class="scan-body" :class="'scan-' + view.key">
                      <span class="spine"></span>
                      <span class="lung left"></span>
                      <span class="lung right"></span>
                      <span class="soft-tissue"></span>
                    </div>
                    <div v-if="inlineShowCrosshair" class="viewer-crosshair horizontal"></div>
                    <div v-if="inlineShowCrosshair" class="viewer-crosshair vertical"></div>
                    <div v-if="inlineShowOverlay" class="candidate-box primary">
                      <span>{{ inlinePrimaryCandidateLabel }}</span>
                    </div>
                    <div v-if="inlineShowOverlay && detectionBoxes.length > 1" class="candidate-box secondary">
                      <span>{{ detectionBoxes[1].label || 'candidate' }}</span>
                    </div>
                    <div v-if="inlineShowMask" class="mask-overlay"></div>
                  </div>
                </div>
              </div>

              <div class="viewer-controls">
                <div>
                  <span>切片</span>
                  <el-slider v-model="inlineSlice" :min="1" :max="304" :show-tooltip="false"></el-slider>
                  <b>{{ inlineSlice }}/304</b>
                </div>
                <div>
                  <span>窗宽</span>
                  <el-slider v-model="inlineWindowWidth" :min="240" :max="640" :step="20" :show-tooltip="false"></el-slider>
                  <b>{{ inlineWindowWidth }}</b>
                </div>
                <div>
                  <span>窗位</span>
                  <el-slider v-model="inlineWindowLevel" :min="-80" :max="120" :step="5" :show-tooltip="false"></el-slider>
                  <b>{{ inlineWindowLevel }}</b>
                </div>
              </div>
            </div>

            <div class="archive-summary" v-if="selectedImaging.medsamResult">
              <div class="archive-title">影像标注归档</div>
              <div class="archive-line">
                <span>模式</span>
                <strong>{{ selectedImaging.medsamResult.workflowMode === 'manual-first' ? '人工标注' : '模型辅助' }}</strong>
              </div>
              <div class="archive-line">
                <span>标注数</span>
                <strong>{{ getManualCount(selectedImaging.medsamResult) }} 条</strong>
              </div>
              <div class="archive-line">
                <span>测量</span>
                <strong>{{ getMeasurementText(selectedImaging.medsamResult) }}</strong>
              </div>
              <div class="archive-line">
                <span>数据/标注</span>
                <strong>{{ getVolumePairText(selectedImaging.medsamResult) }}</strong>
              </div>
            </div>

            <div class="ai-reference-card">
              <div class="archive-title">
                <span>AI 诊断参考</span>
                <el-tag size="mini" :type="aiReferenceReport.ready ? 'success' : 'info'">{{ aiReferenceReport.ready ? '已生成' : '待分析' }}</el-tag>
              </div>
              <p>{{ aiReferenceReport.findings }}</p>
              <p class="ai-impression">{{ aiReferenceReport.impression }}</p>
              <div class="evidence-tags">
                <span v-for="item in aiReferenceReport.evidence" :key="item">{{ item }}</span>
              </div>
              <div class="ai-actions">
                <el-button size="mini" type="primary" icon="el-icon-document-copy" :disabled="!aiReferenceReport.ready" @click="applyAiReferenceToFindings">带入检查所见</el-button>
                <el-button size="mini" icon="el-icon-refresh" @click="refreshAiSuggestion">刷新 AI 提示</el-button>
              </div>
              <small>{{ aiNoticeText }}</small>
            </div>
          </div>
          <el-empty v-else description="请先选择患者和影像，报告页将同屏显示阅片参考"></el-empty>
        </el-card>
      </section>

      <section class="report-editor-pane">
        <el-card class="report-card">
          <el-form :model="diagnosisForm" :rules="activeRules" ref="diagnosisForm" label-width="120px">
            <el-form-item label="报告编号">
              <el-input v-model="diagnosisForm.reportNo" disabled></el-input>
            </el-form-item>
            <el-form-item label="患者" prop="patientId">
              <el-select v-model="diagnosisForm.patientId" filterable placeholder="请选择患者" @change="handlePatientChange">
                <el-option v-for="patient in patients" :key="patient.id" :label="`${patient.name} (ID: ${patient.id})`" :value="patient.id"></el-option>
              </el-select>
            </el-form-item>
            <el-form-item label="关联影像" prop="imagingId">
              <el-select v-model="diagnosisForm.imagingId" filterable placeholder="请选择关联影像" @change="handleImagingChange">
                <el-option
                  v-for="item in patientImagings"
                  :key="getImagingSelectId(item)"
                  :label="`${item.type} - ${item.bodyPart} - ${item.uploadTime}`"
                  :value="getImagingSelectId(item)">
                </el-option>
              </el-select>
            </el-form-item>
            <el-form-item label="检查类型" prop="examinationType">
              <el-input v-model="diagnosisForm.examinationType" placeholder="例如：CT、MRI、X光"></el-input>
            </el-form-item>
            <el-form-item label="检查部位" prop="bodyPart">
              <el-input v-model="diagnosisForm.bodyPart" placeholder="请输入检查部位"></el-input>
            </el-form-item>
            <el-form-item label="临床诊断">
              <el-input type="textarea" v-model="diagnosisForm.clinicalDiagnosis" :rows="2" placeholder="请输入临床诊断或送检原因"></el-input>
            </el-form-item>
            <el-form-item label="检查所见" prop="examinationFindings">
              <el-input type="textarea" v-model="diagnosisForm.examinationFindings" :rows="5" placeholder="请根据片子描述影像所见"></el-input>
            </el-form-item>
            <el-form-item label="诊断意见" prop="diagnosticOpinion">
              <el-input
                type="textarea"
                v-model="diagnosisForm.diagnosticOpinion"
                :rows="4"
                :disabled="isRadiologist"
                :placeholder="isRadiologist ? '由主治医生填写，放射科医生不可编辑' : '请输入诊断意见'">
              </el-input>
              <div v-if="isRadiologist" class="role-field-tip">诊断意见由主治医生填写，放射科医生只提交影像所见和 AI 辅助草稿。</div>
            </el-form-item>
            <el-form-item label="处理建议">
              <el-input
                type="textarea"
                v-model="diagnosisForm.treatment"
                :rows="3"
                :disabled="isRadiologist"
                :placeholder="isRadiologist ? '由主治医生填写' : '请输入治疗建议、复诊建议或随访计划'">
              </el-input>
              <div v-if="isRadiologist" class="role-field-tip">处理建议由主治医生结合诊疗方案填写。</div>
            </el-form-item>
            <el-form-item>
              <el-button @click="saveDraft">{{ draftButtonText }}</el-button>
              <el-button type="primary" @click="handleSubmit">{{ submitButtonText }}</el-button>
              <el-button @click="goBack">取消</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </section>
    </div>
  </div>
</template>

<script>
import { getCookie } from "@/utils/cookies";

const IMAGING_KEY = 'ylz_demo_imagings';
const REPORT_KEY = 'ylz_demo_reports';
const VIEWER_CONTEXT_KEY = 'ylz_viewer_context';

export default {
  name: 'diagnosisWrite',
  data() {
    return {
      isEdit: false,
      inlineView: 'axial',
      inlineSlice: 239,
      inlineWindowWidth: 420,
      inlineWindowLevel: 40,
      inlineShowOverlay: true,
      inlineShowMask: true,
      inlineShowCrosshair: true,
      patients: [
        { id: 30001, name: '张明', gender: '男', age: 46, phone: '13810010001' },
        { id: 30002, name: '李娜', gender: '女', age: 33, phone: '13810010002' },
        { id: 30003, name: '周强', gender: '男', age: 58, phone: '13810010003' },
        { id: 30004, name: '赵敏', gender: '女', age: 41, phone: '13810010004' },
        { id: 30005, name: '陈晨', gender: '男', age: 27, phone: '13810010005' },
        { id: 30006, name: '孙悦', gender: '女', age: 62, phone: '13810010006' }
      ],
      imagings: [],
      reports: [],
      selectedImaging: {},
      diagnosisForm: {
        id: '',
        reportNo: '',
        patientId: '',
        patientName: '',
        gender: '',
        age: '',
        phone: '',
        imagingId: '',
        doctorName: '当前医生',
        examinationType: '',
        bodyPart: '',
        clinicalDiagnosis: '',
        examinationFindings: '',
        diagnosticOpinion: '',
        treatment: '',
        medsamResult: null,
        aiSuggestion: '',
        aiResults: null,
        reportStatus: 'draft'
      },
      rules: {
        patientId: [{ required: true, message: '请选择患者', trigger: 'change' }],
        imagingId: [{ required: true, message: '请选择关联影像', trigger: 'change' }],
        examinationType: [{ required: true, message: '请输入检查类型', trigger: 'blur' }],
        bodyPart: [{ required: true, message: '请输入检查部位', trigger: 'blur' }],
        examinationFindings: [{ required: true, message: '请输入检查所见', trigger: 'blur' }],
        diagnosticOpinion: [{ required: true, message: '请输入诊断意见', trigger: 'blur' }]
      }
    }
  },
  computed: {
    accountIdentify() {
      return getCookie('username') || sessionStorage.getItem('username') || sessionStorage.getItem('accountID') || '';
    },
    isRadiologist() {
      return this.accountIdentify && this.accountIdentify.startsWith('radiologist');
    },
    pageTitle() {
      if (this.isRadiologist) return '影像报告草稿';
      return this.isEdit ? '编辑诊断报告' : '填写诊断报告';
    },
    pageDescription() {
      if (this.isRadiologist) return '放射科医生仅填写影像所见和 AI 辅助草稿，诊断意见由主治医生填写。';
      return '根据患者检查片子填写检查所见、诊断意见，并上传为正式报告。';
    },
    aiNoticeText() {
      if (this.isRadiologist) return 'AI 辅助内容仅用于生成影像所见草稿，最终诊断意见由主治医生填写。';
      return '该内容仅用于辅助医生撰写影像所见，诊断意见必须由医生确认填写。';
    },
    draftButtonText() {
      return this.isRadiologist ? '保存影像草稿' : '保存草稿';
    },
    submitButtonText() {
      return this.isRadiologist ? '提交给主治医生' : '上传诊断报告';
    },
    activeRules() {
      const rules = { ...this.rules };
      if (this.isRadiologist) {
        delete rules.diagnosticOpinion;
      }
      return rules;
    },
    inlineViews() {
      return [
        { key: 'axial', name: '轴位', label: 'Axial 轴位' },
        { key: 'coronal', name: '冠状', label: 'Coronal 冠状' },
        { key: 'sagittal', name: '矢状', label: 'Sagittal 矢状' }
      ];
    },
    viewerToneStyle() {
      const brightness = Math.max(0.72, Math.min(1.34, 1 + (this.inlineWindowLevel - 40) / 210));
      const contrast = Math.max(0.78, Math.min(1.35, this.inlineWindowWidth / 420));
      return {
        '--viewer-brightness': brightness,
        '--viewer-contrast': contrast
      };
    },
    aiArchive() {
      const medsamResult = this.selectedImaging && this.selectedImaging.medsamResult ? this.selectedImaging.medsamResult : {};
      return this.diagnosisForm.aiResults || medsamResult.aiResults || {};
    },
    detectionBoxes() {
      const rows = this.aiArchive.detectionResults || [];
      const latest = this.normalizeAiResult(rows[0]);
      return latest && latest.parsed && latest.parsed.boxes ? latest.parsed.boxes : [];
    },
    segmentationMeasurements() {
      const rows = this.aiArchive.segmentationResults || [];
      const latest = this.normalizeAiResult(rows[0]);
      const parsedMeasurements = latest && latest.parsed ? latest.parsed.measurements || {} : {};
      const archivedMeasurements = this.selectedImaging && this.selectedImaging.medsamResult
        ? this.selectedImaging.medsamResult.measurements || {}
        : {};
      return Object.assign({}, archivedMeasurements, parsedMeasurements);
    },
    classificationResult() {
      const rows = this.aiArchive.classificationResults || [];
      const latest = this.normalizeAiResult(rows[0]);
      return latest && latest.parsed ? latest.parsed : {};
    },
    inlinePrimaryCandidateLabel() {
      const box = this.detectionBoxes[0] || {};
      const confidence = box.confidence ? Math.round(Number(box.confidence) * 100) + '%' : '';
      return (box.label || 'AI candidate') + (confidence ? ' ' + confidence : '');
    },
    aiReferenceReport() {
      const modality = this.diagnosisForm.examinationType || this.selectedImaging.type || '影像';
      const bodyPart = this.diagnosisForm.bodyPart || this.selectedImaging.bodyPart || '检查部位';
      const m = this.segmentationMeasurements;
      const label = this.classificationResult.label || '';
      const confidence = this.classificationResult.confidence ? Math.round(Number(this.classificationResult.confidence) * 100) + '%' : '';
      const detectionCount = this.detectionBoxes.length;
      const manualCount = this.getManualCount(this.selectedImaging.medsamResult);
      const hasMeasurements = !!(m.long_diameter_mm || m.longDiameter || m.area_mm2 || m.area);
      const ready = !!(detectionCount || hasMeasurements || label || manualCount);
      const evidence = [];

      if (detectionCount) evidence.push('检测候选框 ' + detectionCount + ' 个');
      if (m.long_diameter_mm || m.longDiameter) evidence.push('长径 ' + (m.long_diameter_mm || m.longDiameter) + ' mm');
      if (m.short_diameter_mm || m.shortDiameter) evidence.push('短径 ' + (m.short_diameter_mm || m.shortDiameter) + ' mm');
      if (m.area_mm2 || m.area) evidence.push('面积 ' + (m.area_mm2 || m.area) + ' mm²');
      if (m.volume_cm3 || m.volume) evidence.push('体积 ' + (m.volume_cm3 || m.volume) + ' cm³');
      if (label) evidence.push('分类 ' + label + (confidence ? ' ' + confidence : ''));
      if (manualCount) evidence.push('人工标注 ' + manualCount + ' 条');

      const sizeText = hasMeasurements
        ? '长径约 ' + (m.long_diameter_mm || m.longDiameter || '-') + ' mm，短径约 ' + (m.short_diameter_mm || m.shortDiameter || '-') + ' mm，面积约 ' + (m.area_mm2 || m.area || '-') + ' mm²，体积约 ' + (m.volume_cm3 || m.volume || '-') + ' cm³'
        : '';
      const findings = ready
        ? bodyPart + modality + '检查。AI 阅片参考提示已形成候选区域' + (sizeText ? '，分割测量提示病灶' + sizeText : '') + '。建议结合原始切片、窗宽窗位、Overlay 与人工标注结果复核。'
        : '当前影像暂无已归档 AI 检测、分割或分类结果，请先在完整标注工作站完成 AI 分析或人工标注。';
      const impression = label
        ? '辅助印象：分类模型提示“' + label + '”' + (confidence ? '，置信度 ' + confidence : '') + '。该内容仅用于报告草稿参考。'
        : (ready ? '辅助印象：已有候选区域和测量信息，分类结论仍需医生结合临床资料判断。' : '辅助印象：暂无。');

      return {
        ready,
        findings,
        impression,
        evidence: evidence.length ? evidence : ['等待 AI 分析结果']
      };
    },
    patientImagings() {
      if (!this.diagnosisForm.patientId) return this.imagings;
      return this.imagings.filter(item => Number(item.patientId) === Number(this.diagnosisForm.patientId));
    }
  },
  methods: {
    goBack() {
      this.$router.push('/diagnosisList');
    },
    viewImaging() {
      if (this.selectedImaging.id) {
        this.$router.push({ path: '/imagingViewer', query: { id: this.selectedImaging.id } });
      }
    },
    normalizeAiResult(row) {
      if (!row) return null;
      if (row.parsed) return row;
      const parsed = this.safeParseJson(row.resultJson || row.result_json || row.outputJson || row.output_json || '{}');
      return Object.assign({}, row, {
        taskType: row.taskType || row.task_type,
        modelName: row.modelName || row.model_name || row.modelId || row.model_id || '',
        modelVersion: row.modelVersion || row.model_version || row.version || '',
        confirmStatus: row.confirmStatus === undefined ? row.confirm_status : row.confirmStatus,
        parsed
      });
    },
    safeParseJson(value) {
      if (!value) return {};
      if (typeof value === 'object') return value;
      try {
        return JSON.parse(value);
      } catch (e) {
        return {};
      }
    },
    syncInlineViewerFromImaging(imaging) {
      const result = imaging && imaging.medsamResult ? imaging.medsamResult : {};
      this.inlineSlice = Number(result.slice || result.sliceIndex || 239);
      this.inlineView = ['axial', 'coronal', 'sagittal'].includes(result.view) ? result.view : 'axial';
    },
    applyAiReferenceToFindings() {
      if (!this.aiReferenceReport.ready) {
        this.$message.warning('当前影像还没有可带入的 AI 参考结果');
        return;
      }
      const text = this.aiReferenceReport.findings;
      if (!this.diagnosisForm.examinationFindings) {
        this.diagnosisForm.examinationFindings = text;
      } else if (!this.diagnosisForm.examinationFindings.includes(text)) {
        this.diagnosisForm.examinationFindings = this.diagnosisForm.examinationFindings + '\n' + text;
      }
      this.refreshAiSuggestion(false);
      this.$message.success('已带入检查所见，诊断意见仍需医生填写');
    },
    refreshAiSuggestion(showMessage = true) {
      this.diagnosisForm.aiSuggestion = this.aiReferenceReport.ready
        ? this.aiReferenceReport.findings + '\n' + this.aiReferenceReport.impression
        : '';
      if (showMessage) {
        this.$message.success(this.diagnosisForm.aiSuggestion ? 'AI 辅助提示已刷新' : '暂无可刷新的 AI 辅助提示');
      }
    },
    loadData() {
      this.imagings = JSON.parse(localStorage.getItem(IMAGING_KEY) || '[]');
      this.reports = JSON.parse(localStorage.getItem(REPORT_KEY) || '[]');
      this.diagnosisForm.reportNo = this.createReportNo();
    },
    createReportNo() {
      const now = new Date();
      const pad = value => String(value).padStart(2, '0');
      return `YLZ-R-${now.getFullYear()}${pad(now.getMonth() + 1)}${pad(now.getDate())}${pad(now.getHours())}${pad(now.getMinutes())}`;
    },
    handlePatientChange(id) {
      this.diagnosisForm.patientId = id;
      const patient = this.patients.find(item => item.id === id);
      if (patient) {
        Object.assign(this.diagnosisForm, {
          patientName: patient.name,
          gender: patient.gender,
          age: patient.age,
          phone: patient.phone
        });
      }
      if (!this.patientImagings.some(item => this.matchesImagingId(item, this.diagnosisForm.imagingId))) {
        this.diagnosisForm.imagingId = '';
        this.selectedImaging = {};
      }
    },
    getImagingSelectId(item) {
      return item.backendImagingId || item.compatibleImagingId || item.imagingId || item.id;
    },
    matchesImagingId(item, id) {
      const target = Number(id);
      if (!target || !item) return false;
      return [
        item.id,
        item.backendImagingId,
        item.compatibleImagingId,
        item.imagingId,
        item.studyRecordId
      ].some(value => Number(value) === target);
    },
    handleImagingChange(id) {
      const imaging = this.imagings.find(item => this.matchesImagingId(item, id));
      if (!imaging) return;
      this.selectedImaging = imaging;
      const patient = this.patients.find(item => item.id === imaging.patientId) || imaging;
      Object.assign(this.diagnosisForm, {
        patientId: imaging.patientId,
        patientName: imaging.patientName,
        gender: patient.gender || imaging.gender,
        age: patient.age || imaging.age,
        phone: patient.phone || imaging.phone,
        imagingId: this.getImagingSelectId(imaging),
        examinationType: imaging.type,
        bodyPart: imaging.bodyPart,
        clinicalDiagnosis: this.diagnosisForm.clinicalDiagnosis || imaging.remark,
        medsamResult: this.diagnosisForm.medsamResult || imaging.medsamResult || null,
        aiResults: this.diagnosisForm.aiResults || (imaging.medsamResult && imaging.medsamResult.aiResults) || null
      });
      this.syncInlineViewerFromImaging(imaging);
      this.applyViewerContext(id, imaging);
      if (!this.diagnosisForm.aiSuggestion) {
        this.refreshAiSuggestion(false);
      }
    },
    applyViewerContext(imagingId, imaging) {
      try {
        const saved = sessionStorage.getItem(VIEWER_CONTEXT_KEY);
        if (!saved) return;
        const context = JSON.parse(saved);
        const contextMatches = Number(context.imagingId) === Number(imagingId) ||
          this.matchesImagingId(imaging, context.imagingId) ||
          Number(context.displayImagingId) === Number(imaging && imaging.id) ||
          Number(context.studyRecordId) === Number(imaging && imaging.studyRecordId);
        if (!contextMatches) return;
        Object.assign(this.diagnosisForm, {
          examinationFindings: this.diagnosisForm.examinationFindings || context.findings,
          diagnosticOpinion: this.diagnosisForm.diagnosticOpinion,
          aiSuggestion: context.aiSuggestion || (context.reportDraft && context.reportDraft.aiSuggestion) || '',
          aiResults: context.aiResults || null,
          medsamResult: {
            promptBox: context.promptBox,
            aiScore: context.aiScore,
            measurements: context.measurements,
            machineAnnotations: context.machineAnnotations || [],
            manualAnnotations: context.manualAnnotations || [],
            annotationMarks: context.annotationMarks || [],
            aiResults: context.aiResults || null,
            reportDraft: context.reportDraft || null,
            workflowMode: 'manual-first'
          }
        });
      } catch (e) {
        sessionStorage.removeItem(VIEWER_CONTEXT_KEY);
      }
    },
    loadFromRoute() {
      const reportId = Number(this.$route.query.id);
      const imagingId = Number(this.$route.query.imagingId);
      const patientId = Number(this.$route.query.patientId);
      if (reportId) {
        const report = this.reports.find(item => item.id === reportId);
        if (report) {
          this.isEdit = true;
          Object.assign(this.diagnosisForm, report);
          this.handleImagingChange(report.imagingId);
        }
        return;
      }
      if (imagingId) {
        this.handleImagingChange(imagingId);
        return;
      }
      if (patientId) {
        this.handlePatientChange(patientId);
      }
    },
    persistReport(status) {
      const now = new Date();
      const pad = value => String(value).padStart(2, '0');
      const reportDate = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
      const formData = { ...this.diagnosisForm };
      if (this.isRadiologist) {
        formData.diagnosticOpinion = '';
        formData.treatment = '';
      }
      const report = {
        ...formData,
        id: this.diagnosisForm.id || Date.now(),
        doctorName: this.accountIdentify || this.diagnosisForm.doctorName,
        reportStatus: status,
        reportDate,
        medsamResult: this.diagnosisForm.medsamResult || (this.selectedImaging && this.selectedImaging.medsamResult) || null
      };
      const reportIndex = this.reports.findIndex(item => item.id === report.id);
      if (reportIndex >= 0) {
        this.reports.splice(reportIndex, 1, report);
      } else {
        this.reports.unshift(report);
      }
      const imagingIndex = this.imagings.findIndex(item => this.matchesImagingId(item, report.imagingId));
      if (imagingIndex >= 0) {
        this.imagings.splice(imagingIndex, 1, {
          ...this.imagings[imagingIndex],
          diagnosisStatus: status === 'submitted' ? 'completed' : 'pending',
          radiologyStatus: status === 'submitted' ? '诊断报告已上传' : (status === 'pending_attending' ? '已提交主治医生' : (this.imagings[imagingIndex].radiologyStatus || '已提交主治医生')),
          reportId: report.id
        });
      }
      localStorage.setItem(REPORT_KEY, JSON.stringify(this.reports));
      localStorage.setItem(IMAGING_KEY, JSON.stringify(this.imagings));
      return report;
    },
    getManualCount(result) {
      if (!result) return 0;
      if (result.annotationMarks) return result.annotationMarks.filter(item => item.type !== 'ruler').length;
      if (result.manualAnnotations) return result.manualAnnotations.length;
      return 0;
    },
    getMeasurementText(result) {
      if (!result || !result.measurements) return '暂无';
      return `${result.measurements.area || '-'} mm² / ${result.measurements.volume || '-'} cm³`;
    },
    getVolumePairText(result) {
      if (!result) return '暂无';
      const meta = result.datasetMeta || {};
      const source = result.sourceVolume || meta.sourceVolume || {};
      const label = result.labelVolume || meta.labelVolume || {};
      return `${source.fileName || 'lung_001.nii.gz'} / ${label.fileName || 'lung_001.nii（标注）.gz'}`;
    },
    saveDraft() {
      if (!this.diagnosisForm.patientId || !this.diagnosisForm.imagingId) {
        this.$message.warning('请先选择患者和关联影像');
        return;
      }
      const report = this.persistReport('draft');
      this.$message.success(this.isRadiologist ? '影像草稿已保存' : '草稿已保存');
      this.$router.push({ path: '/diagnosisDetail', query: { id: report.id } });
    },
    handleSubmit() {
      this.$refs['diagnosisForm'].validate((valid) => {
        if (!valid) return;
        const status = this.isRadiologist ? 'pending_attending' : 'submitted';
        const report = this.persistReport(status);
        this.$message.success(this.isRadiologist ? '影像报告草稿已提交给主治医生' : '诊断报告已上传');
        this.$router.push({ path: '/diagnosisDetail', query: { id: report.id } });
      });
    }
  },
  created() {
    this.loadData();
    this.loadFromRoute();
  }
}
</script>

<style lang="scss" scoped>
.diagnosis-write-page {
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

    p {
      margin: 6px 0 0;
      color: #6b7280;
      font-size: 13px;
    }
  }

  .report-workbench {
    display: grid;
    grid-template-columns: minmax(500px, 0.95fr) minmax(520px, 1.05fr);
    gap: 16px;
    align-items: start;
  }

  .viewer-report-pane,
  .report-editor-pane {
    min-width: 0;
  }

  .viewer-card {
    position: sticky;
    top: 76px;
  }

  .card-header-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;

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
      color: #7a8f88;
      font-size: 12px;
    }
  }

  .imaging-summary {
    p {
      margin: 10px 0;
      color: #4b5563;
      line-height: 1.6;
    }
  }

  .case-meta-strip {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 12px;

    span {
      max-width: 100%;
      padding: 6px 9px;
      border-radius: 6px;
      background: #edf8f3;
      color: #2f5d4f;
      font-size: 12px;
      line-height: 1.4;
      word-break: break-word;
    }
  }

  .inline-viewer {
    border: 1px solid #d9e8e2;
    border-radius: 8px;
    background: #f9fcfb;
    padding: 10px;
  }

  .inline-viewer-toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
    margin-bottom: 10px;
  }

  .inline-switches {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    justify-content: flex-end;
    font-size: 12px;
  }

  .film-grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 8px;
  }

  .film-panel {
    min-width: 0;
    border: 2px solid #d5e6df;
    border-radius: 8px;
    overflow: hidden;
    background: #071013;
    cursor: pointer;

    &.active {
      border-color: #0f8f61;
      box-shadow: 0 0 0 3px rgba(15, 143, 97, 0.12);
    }
  }

  .film-title {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    padding: 7px 9px;
    background: #ffffff;

    span {
      color: #075f42;
      font-weight: 700;
      font-size: 12px;
    }

    small {
      color: #71877f;
      font-size: 12px;
    }
  }

  .film-canvas {
    position: relative;
    aspect-ratio: 1 / 1;
    min-height: 150px;
    overflow: hidden;
    background:
      linear-gradient(90deg, rgba(255, 255, 255, 0.08), transparent 18%, transparent 82%, rgba(255, 255, 255, 0.08)),
      radial-gradient(circle at 50% 52%, #dce3e5 0, #a9b5b8 26%, #4b5b60 48%, #05090b 75%);
    filter: brightness(var(--viewer-brightness)) contrast(var(--viewer-contrast));
  }

  .scan-body,
  .scan-body span,
  .viewer-crosshair,
  .candidate-box,
  .mask-overlay {
    position: absolute;
    pointer-events: none;
  }

  .scan-body {
    inset: 8% 7%;
  }

  .lung {
    top: 25%;
    width: 27%;
    height: 38%;
    border-radius: 45% 45% 50% 50%;
    background:
      radial-gradient(circle at 45% 42%, rgba(20, 29, 33, 0.92), rgba(65, 75, 80, 0.7) 58%, rgba(226, 232, 235, 0.22) 100%);
    box-shadow: inset 0 0 18px rgba(255, 255, 255, 0.08);

    &.left {
      left: 19%;
      transform: rotate(-7deg);
    }

    &.right {
      right: 19%;
      transform: rotate(7deg);
    }
  }

  .spine {
    left: 45%;
    top: 34%;
    width: 10%;
    height: 18%;
    border-radius: 50%;
    background: radial-gradient(circle, #f7f7f7, #c5ccd0 45%, #647279 78%);
  }

  .soft-tissue {
    left: 18%;
    right: 18%;
    bottom: 13%;
    height: 18%;
    border-radius: 50% 50% 42% 42%;
    background: radial-gradient(circle, rgba(235, 240, 242, 0.28), rgba(110, 122, 128, 0.25), transparent 74%);
  }

  .scan-coronal .lung {
    top: 18%;
    height: 56%;
  }

  .scan-sagittal .lung.left {
    left: 35%;
    width: 31%;
    height: 55%;
  }

  .scan-sagittal .lung.right {
    display: none;
  }

  .viewer-crosshair {
    background: rgba(255, 255, 255, 0.28);

    &.horizontal {
      left: 7%;
      right: 7%;
      top: 50%;
      height: 1px;
    }

    &.vertical {
      top: 7%;
      bottom: 7%;
      left: 50%;
      width: 1px;
    }
  }

  .candidate-box {
    border: 2px solid #38bdf8;
    background: rgba(56, 189, 248, 0.08);

    span {
      position: absolute;
      left: -2px;
      top: -24px;
      max-width: 150px;
      padding: 3px 6px;
      border-radius: 4px;
      background: rgba(15, 23, 42, 0.82);
      color: #ffffff;
      font-size: 11px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    &.primary {
      left: 39%;
      top: 34%;
      width: 25%;
      height: 28%;
    }

    &.secondary {
      left: 59%;
      top: 44%;
      width: 18%;
      height: 16%;
      border-color: #f59e0b;
      background: rgba(245, 158, 11, 0.08);
    }
  }

  .mask-overlay {
    left: 43%;
    top: 37%;
    width: 18%;
    height: 22%;
    border-radius: 48% 52% 45% 55%;
    background: rgba(24, 188, 126, 0.45);
    box-shadow: 0 0 18px rgba(24, 188, 126, 0.3);
  }

  .viewer-controls {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 10px;
    margin-top: 10px;

    > div {
      display: grid;
      grid-template-columns: 42px 1fr 58px;
      align-items: center;
      gap: 8px;
      color: #556b63;
      font-size: 12px;
    }

    b {
      color: #075f42;
      text-align: right;
      font-weight: 600;
    }
  }

  .archive-summary {
    margin: 14px 0;
    padding: 12px;
    border: 1px solid #d8eee5;
    border-radius: 8px;
    background: #f0f9f5;

    .archive-title {
      color: #075f42;
      font-weight: 600;
      margin-bottom: 8px;
    }

    .archive-line {
      display: flex;
      justify-content: space-between;
      gap: 12px;
      padding: 5px 0;
      color: #60756e;
      font-size: 13px;

      strong {
        color: #24312d;
      }
    }
  }

  .ai-reference-card {
    margin-top: 14px;
    padding: 12px;
    border: 1px solid #bfe7d4;
    border-radius: 8px;
    background: #f6fffb;

    p {
      margin: 8px 0 0;
      color: #48625a;
      line-height: 1.7;
      font-size: 13px;
    }

    .ai-impression {
      color: #674d12;
    }

    small {
      display: block;
      margin-top: 10px;
      color: #9a6b00;
      line-height: 1.5;
    }
  }

  .archive-title {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 8px;
    color: #075f42;
    font-weight: 600;
    margin-bottom: 8px;
  }

  .evidence-tags {
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

  .ai-actions {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 12px;

    .el-button {
      margin-left: 0;
    }
  }

  .role-field-tip {
    margin-top: 6px;
    color: #8a6d3b;
    font-size: 12px;
    line-height: 1.5;
  }

  @media (max-width: 1320px) {
    .report-workbench {
      grid-template-columns: 1fr;
    }

    .viewer-card {
      position: static;
    }
  }

  @media (max-width: 760px) {
    .inline-viewer-toolbar,
    .card-header-row {
      align-items: flex-start;
      flex-direction: column;
    }

    .film-grid,
    .viewer-controls {
      grid-template-columns: 1fr;
    }
  }
}
</style>
