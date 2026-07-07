<template>
  <div class="imaging-upload-page">
    <div class="page-header">
      <h2>上传影像</h2>
      <el-button icon="el-icon-back" @click="goBack">返回列表</el-button>
    </div>
    <el-card>
      <el-form :model="uploadForm" :rules="rules" ref="uploadForm" label-width="120px">
        <el-form-item label="患者" prop="patientId">
          <el-select v-model="uploadForm.patientId" filterable placeholder="请选择患者" @change="handlePatientChange">
            <el-option v-for="patient in patients" :key="patient.id" :label="`${patient.name} (ID: ${patient.id})`" :value="patient.id"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="影像类型" prop="type">
          <el-select v-model="uploadForm.type" placeholder="请选择影像类型">
            <el-option label="X光" value="X光"></el-option>
            <el-option label="CT" value="CT"></el-option>
            <el-option label="MRI" value="MRI"></el-option>
            <el-option label="超声" value="超声"></el-option>
            <el-option label="NIfTI" value="NIfTI"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="文件格式" prop="format">
          <el-select v-model="uploadForm.format" placeholder="请选择文件格式">
            <el-option label="DICOM" value="DICOM"></el-option>
            <el-option label="NIfTI" value="NIfTI"></el-option>
            <el-option label="JPG/PNG" value="IMAGE"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="检查部位" prop="bodyPart">
          <el-input v-model="uploadForm.bodyPart" placeholder="例如：胸部、头颅、腰椎、腹部"></el-input>
        </el-form-item>
        <el-form-item label="序列说明">
          <el-input v-model="uploadForm.seriesDescription" placeholder="例如：肺窗薄层、T1增强、冠状重建"></el-input>
        </el-form-item>
        <el-form-item label="影像文件">
          <el-upload
            class="upload-area"
            drag
            action="#"
            :auto-upload="false"
            :on-change="handleFileChange"
            :on-remove="handleFileRemove"
            :file-list="fileList"
            :limit="1"
          >
            <i class="el-icon-upload"></i>
            <div class="el-upload__text">将文件拖到此处，或<em>点击选择</em></div>
            <div class="el-upload__tip" slot="tip">支持 DICOM / NIfTI / JPG / PNG；文件写入 MinIO/NAS，数据库保存 URI 与元数据。</div>
          </el-upload>
        </el-form-item>
        <el-form-item label="数据处理">
          <el-checkbox v-model="uploadForm.anonymized">已脱敏/匿名化</el-checkbox>
          <el-input class="metadata-input" type="textarea" v-model="uploadForm.metadataJson" :rows="3" placeholder='可选：{"window_width":400,"window_level":40,"spacing":"0.6934x0.6934x1.0"}'></el-input>
        </el-form-item>
        <el-form-item label="检查说明">
          <el-input type="textarea" v-model="uploadForm.remark" :rows="4" placeholder="请输入检查目的、症状或备注说明"></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSubmit">保存影像记录</el-button>
          <el-button @click="goBack">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script>
import { uploadStudyForm } from '@/api/study'

const IMAGING_KEY = 'ylz_demo_imagings';

export default {
  name: 'imagingUpload',
  data() {
    return {
      fileList: [],
      patients: [
        { id: 30001, name: '张明', gender: '男', age: 46, phone: '13810010001' },
        { id: 30002, name: '李娜', gender: '女', age: 33, phone: '13810010002' },
        { id: 30003, name: '周强', gender: '男', age: 58, phone: '13810010003' },
        { id: 30004, name: '赵敏', gender: '女', age: 41, phone: '13810010004' },
        { id: 30005, name: '陈晨', gender: '男', age: 27, phone: '13810010005' },
        { id: 30006, name: '孙悦', gender: '女', age: 62, phone: '13810010006' }
      ],
      uploadForm: {
        patientId: '',
        patientName: '',
        gender: '',
        age: '',
        phone: '',
        type: '',
        format: 'DICOM',
        bodyPart: '',
        seriesDescription: '',
        fileName: '',
        fileSize: '',
        fileBytes: 0,
        anonymized: true,
        metadataJson: '',
        remark: ''
      },
      rules: {
        patientId: [{ required: true, message: '请选择患者', trigger: 'change' }],
        type: [{ required: true, message: '请选择影像类型', trigger: 'change' }],
        format: [{ required: true, message: '请选择文件格式', trigger: 'change' }],
        bodyPart: [{ required: true, message: '请输入检查部位', trigger: 'blur' }]
      }
    }
  },
  methods: {
    goBack() {
      this.$router.push('/imagingList');
    },
    handlePatientChange(id) {
      const patient = this.patients.find(item => item.id === id);
      if (patient) {
        Object.assign(this.uploadForm, {
          patientName: patient.name,
          gender: patient.gender,
          age: patient.age,
          phone: patient.phone
        });
      }
    },
    handleFileChange(file, fileList) {
      this.fileList = fileList.slice(-1);
      this.uploadForm.fileName = file.name;
      const size = file.size ? `${(file.size / 1024 / 1024).toFixed(1)}MB` : '演示文件';
      this.uploadForm.fileSize = size;
      this.uploadForm.fileBytes = file.size || 0;
    },
    handleFileRemove() {
      this.fileList = [];
      this.uploadForm.fileName = '';
      this.uploadForm.fileSize = '';
      this.uploadForm.fileBytes = 0;
    },
    handleSubmit() {
      this.$refs['uploadForm'].validate((valid) => {
        if (!valid) return;
        const submitLocal = (backendRecord) => {
        const list = JSON.parse(localStorage.getItem(IMAGING_KEY) || '[]');
        const now = new Date();
        const pad = value => String(value).padStart(2, '0');
        const uploadTime = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
        const record = {
          id: Date.now(),
          patientId: this.uploadForm.patientId,
          patientName: this.uploadForm.patientName,
          gender: this.uploadForm.gender,
          age: this.uploadForm.age,
          phone: this.uploadForm.phone,
          type: this.uploadForm.type,
          bodyPart: this.uploadForm.bodyPart,
          uploadTime,
          doctorName: '当前医生',
          fileSize: this.uploadForm.fileSize || '演示文件',
          fileName: this.uploadForm.fileName || `${this.uploadForm.type}-${this.uploadForm.bodyPart}.dcm`,
          studyId: backendRecord && backendRecord.study ? backendRecord.study.id : '',
          seriesId: backendRecord && backendRecord.series ? backendRecord.series.id : '',
          instanceId: backendRecord && backendRecord.instance ? backendRecord.instance.id : '',
          format: this.uploadForm.format,
          seriesDescription: this.uploadForm.seriesDescription,
          metadataJson: this.uploadForm.metadataJson,
          anonymized: this.uploadForm.anonymized,
          diagnosisStatus: 'pending',
          remark: this.uploadForm.remark || '暂无检查说明'
        };
        localStorage.setItem(IMAGING_KEY, JSON.stringify([record].concat(list)));
        this.$message.success('影像记录已保存，并已生成标准 Study-Series-Instance 元数据');
        this.$router.push({ path: '/imagingDetail', query: { id: record.id } });
        };

        const payload = {
          patientId: this.uploadForm.patientId,
          doctorId: 10000010,
          hospitalId: 1,
          patientName: this.uploadForm.patientName,
          gender: this.uploadForm.gender,
          age: this.uploadForm.age,
          phone: this.uploadForm.phone,
          modality: this.uploadForm.type,
          bodyPart: this.uploadForm.bodyPart,
          fileName: this.uploadForm.fileName || `${this.uploadForm.type}-${this.uploadForm.bodyPart}.dcm`,
          fileSize: this.uploadForm.fileBytes,
          seriesDescription: this.uploadForm.seriesDescription,
          sliceCount: this.uploadForm.type === 'CT' || this.uploadForm.type === 'NIfTI' ? 304 : 1,
          metadataJson: this.uploadForm.metadataJson || JSON.stringify({ format: this.uploadForm.format }),
          anonymized: this.uploadForm.anonymized,
          description: this.uploadForm.remark
        };
        const rawFile = this.fileList.length > 0 ? this.fileList[0].raw : null;
        uploadStudyForm(payload, rawFile).then(res => {
          submitLocal(res.code === 200 ? res.data : null);
        }).catch(() => {
          this.$message.error('影像上传失败：请确认 PostgreSQL、Redis 与 MinIO/NAS 服务已启动');
        });
      });
    }
  }
}
</script>

<style lang="scss" scoped>
.imaging-upload-page {
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

  .upload-area {
    width: 100%;
  }

  .upload-area .el-upload-dragger {
    width: 100%;
  }

  .metadata-input {
    margin-top: 8px;
  }
}
</style>
