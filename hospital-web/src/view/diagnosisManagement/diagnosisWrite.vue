<template>
  <div class="diagnosis-write-page">
    <div class="page-header">
      <div>
        <h2>{{ isEdit ? '编辑诊断报告' : '填写诊断报告' }}</h2>
        <p>根据患者检查片子填写检查所见、诊断意见，并上传为正式报告。</p>
      </div>
      <el-button icon="el-icon-back" @click="goBack">返回列表</el-button>
    </div>

    <el-row :gutter="20">
      <el-col :span="8">
        <el-card class="side-card">
          <div slot="header">
            <span>关联影像</span>
          </div>
          <div v-if="selectedImaging.id" class="imaging-summary">
            <div class="film-thumb">
              <span>{{ selectedImaging.type }}</span>
              <strong>{{ selectedImaging.bodyPart }}</strong>
            </div>
            <p><b>患者：</b>{{ selectedImaging.patientName }}（{{ selectedImaging.gender }}，{{ selectedImaging.age }}岁）</p>
            <p><b>检查：</b>{{ selectedImaging.type }} / {{ selectedImaging.bodyPart }}</p>
            <p><b>时间：</b>{{ selectedImaging.uploadTime }}</p>
            <p><b>说明：</b>{{ selectedImaging.remark }}</p>
            <el-button type="text" icon="el-icon-view" @click="viewImaging">查看完整片子</el-button>
          </div>
          <el-empty v-else description="请先选择患者和影像"></el-empty>
        </el-card>
      </el-col>

      <el-col :span="16">
        <el-card>
          <el-form :model="diagnosisForm" :rules="rules" ref="diagnosisForm" label-width="120px">
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
                  :key="item.id"
                  :label="`${item.type} - ${item.bodyPart} - ${item.uploadTime}`"
                  :value="item.id">
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
              <el-input type="textarea" v-model="diagnosisForm.diagnosticOpinion" :rows="4" placeholder="请输入诊断意见"></el-input>
            </el-form-item>
            <el-form-item label="处理建议">
              <el-input type="textarea" v-model="diagnosisForm.treatment" :rows="3" placeholder="请输入治疗建议、复诊建议或随访计划"></el-input>
            </el-form-item>
            <el-form-item>
              <el-button @click="saveDraft">保存草稿</el-button>
              <el-button type="primary" @click="handleSubmit">上传诊断报告</el-button>
              <el-button @click="goBack">取消</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script>
const IMAGING_KEY = 'ylz_demo_imagings';
const REPORT_KEY = 'ylz_demo_reports';
const VIEWER_CONTEXT_KEY = 'ylz_viewer_context';

export default {
  name: 'diagnosisWrite',
  data() {
    return {
      isEdit: false,
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
    patientImagings() {
      if (!this.diagnosisForm.patientId) return this.imagings;
      return this.imagings.filter(item => item.patientId === this.diagnosisForm.patientId);
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
      const patient = this.patients.find(item => item.id === id);
      if (patient) {
        Object.assign(this.diagnosisForm, {
          patientName: patient.name,
          gender: patient.gender,
          age: patient.age,
          phone: patient.phone
        });
      }
      if (!this.patientImagings.some(item => item.id === this.diagnosisForm.imagingId)) {
        this.diagnosisForm.imagingId = '';
        this.selectedImaging = {};
      }
    },
    handleImagingChange(id) {
      const imaging = this.imagings.find(item => item.id === id);
      if (!imaging) return;
      this.selectedImaging = imaging;
      const patient = this.patients.find(item => item.id === imaging.patientId) || imaging;
      Object.assign(this.diagnosisForm, {
        patientId: imaging.patientId,
        patientName: imaging.patientName,
        gender: patient.gender || imaging.gender,
        age: patient.age || imaging.age,
        phone: patient.phone || imaging.phone,
        imagingId: imaging.id,
        examinationType: imaging.type,
        bodyPart: imaging.bodyPart,
        clinicalDiagnosis: this.diagnosisForm.clinicalDiagnosis || imaging.remark
      });
      this.applyViewerContext(imaging.id);
    },
    applyViewerContext(imagingId) {
      try {
        const saved = sessionStorage.getItem(VIEWER_CONTEXT_KEY);
        if (!saved) return;
        const context = JSON.parse(saved);
        if (Number(context.imagingId) !== Number(imagingId)) return;
        Object.assign(this.diagnosisForm, {
          examinationFindings: this.diagnosisForm.examinationFindings || context.findings,
          diagnosticOpinion: this.diagnosisForm.diagnosticOpinion || context.opinion
        });
      } catch (e) {
        sessionStorage.removeItem(VIEWER_CONTEXT_KEY);
      }
    },
    loadFromRoute() {
      const reportId = Number(this.$route.query.id);
      const imagingId = Number(this.$route.query.imagingId);
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
      }
    },
    persistReport(status) {
      const now = new Date();
      const pad = value => String(value).padStart(2, '0');
      const reportDate = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
      const report = {
        ...this.diagnosisForm,
        id: this.diagnosisForm.id || Date.now(),
        reportStatus: status,
        reportDate
      };
      const reportIndex = this.reports.findIndex(item => item.id === report.id);
      if (reportIndex >= 0) {
        this.reports.splice(reportIndex, 1, report);
      } else {
        this.reports.unshift(report);
      }
      const imagingIndex = this.imagings.findIndex(item => item.id === report.imagingId);
      if (imagingIndex >= 0) {
        this.imagings.splice(imagingIndex, 1, {
          ...this.imagings[imagingIndex],
          diagnosisStatus: status === 'submitted' ? 'completed' : 'pending',
          reportId: report.id
        });
      }
      localStorage.setItem(REPORT_KEY, JSON.stringify(this.reports));
      localStorage.setItem(IMAGING_KEY, JSON.stringify(this.imagings));
      return report;
    },
    saveDraft() {
      if (!this.diagnosisForm.patientId || !this.diagnosisForm.imagingId) {
        this.$message.warning('请先选择患者和关联影像');
        return;
      }
      const report = this.persistReport('draft');
      this.$message.success('草稿已保存');
      this.$router.push({ path: '/diagnosisDetail', query: { id: report.id } });
    },
    handleSubmit() {
      this.$refs['diagnosisForm'].validate((valid) => {
        if (!valid) return;
        const report = this.persistReport('submitted');
        this.$message.success('诊断报告已上传');
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

  .side-card {
    position: sticky;
    top: 80px;
  }

  .imaging-summary {
    p {
      margin: 10px 0;
      color: #4b5563;
      line-height: 1.6;
    }
  }

  .film-thumb {
    height: 180px;
    border-radius: 10px;
    background:
      radial-gradient(circle at center, rgba(241, 245, 249, 0.45), rgba(71, 85, 105, 0.28) 42%, rgba(15, 23, 42, 0.92) 72%),
      repeating-linear-gradient(90deg, rgba(255, 255, 255, 0.04) 0 1px, transparent 1px 10px);
    color: white;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 18px;
    margin-bottom: 16px;

    span {
      font-size: 13px;
      opacity: 0.8;
    }

    strong {
      font-size: 28px;
      letter-spacing: 2px;
    }
  }
}
</style>
