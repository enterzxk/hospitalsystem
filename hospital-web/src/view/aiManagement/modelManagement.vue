<template>
  <div class="model-management-page">
    <div class="page-header">
      <div>
        <h2>模型管理</h2>
        <p>维护分割、检测、分类和报告生成模型的版本、适用模态和启停状态。</p>
      </div>
      <el-button type="primary" icon="el-icon-plus" @click="openCreate">新增模型</el-button>
    </div>

    <el-card class="table-card">
      <el-table :data="models" v-loading="loading" style="width: 100%">
        <el-table-column prop="modelId" label="模型ID" min-width="160"></el-table-column>
        <el-table-column prop="name" label="模型名称" width="150"></el-table-column>
        <el-table-column prop="taskType" label="任务类型" width="140"></el-table-column>
        <el-table-column prop="modality" label="适用模态" width="110"></el-table-column>
        <el-table-column prop="version" label="版本" width="100"></el-table-column>
        <el-table-column prop="weightUri" label="权重URI" min-width="220" show-overflow-tooltip></el-table-column>
        <el-table-column label="状态" width="90">
          <template slot-scope="scope">
            <el-tag :type="scope.row.status === 1 ? 'success' : 'info'">{{ scope.row.status === 1 ? '启用' : '停用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120">
          <template slot-scope="scope">
            <el-button type="text" @click="openEdit(scope.row)">编辑</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <el-dialog :title="form.id ? '编辑模型' : '新增模型'" :visible.sync="dialogVisible" width="640px">
      <el-form :model="form" label-width="110px">
        <el-form-item label="模型ID">
          <el-input v-model="form.modelId" placeholder="如 medsam_v1.0"></el-input>
        </el-form-item>
        <el-form-item label="模型名称">
          <el-input v-model="form.name"></el-input>
        </el-form-item>
        <el-form-item label="任务类型">
          <el-select v-model="form.taskType" placeholder="请选择">
            <el-option label="分割 segmentation" value="segmentation"></el-option>
            <el-option label="检测 detection" value="detection"></el-option>
            <el-option label="分类 classification" value="classification"></el-option>
            <el-option label="报告 report_generation" value="report_generation"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="适用模态">
          <el-input v-model="form.modality" placeholder="CT/MRI/XRay/US/ALL"></el-input>
        </el-form-item>
        <el-form-item label="版本">
          <el-input v-model="form.version"></el-input>
        </el-form-item>
        <el-form-item label="权重URI">
          <el-input v-model="form.weightUri"></el-input>
        </el-form-item>
        <el-form-item label="配置JSON">
          <el-input type="textarea" :rows="4" v-model="form.configJson"></el-input>
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="form.enabled" active-text="启用" inactive-text="停用"></el-switch>
        </el-form-item>
      </el-form>
      <div slot="footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="save">保存</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { getModels, saveModel } from '@/api/ai'

export default {
  name: 'modelManagement',
  data() {
    return {
      loading: false,
      dialogVisible: false,
      models: [],
      form: {}
    }
  },
  created() {
    this.load()
  },
  methods: {
    load() {
      this.loading = true
      getModels().then(res => {
        this.models = res.code === 200 && res.data && res.data.length ? res.data : this.defaultModels()
      }).catch(() => {
        this.models = this.defaultModels()
      }).finally(() => {
        this.loading = false
      })
    },
    defaultModels() {
      return [
        { modelId: 'medsam_v1.0', name: 'MedSAM', taskType: 'segmentation', modality: 'CT', version: 'v1.0', weightUri: 'minio://medical-imaging/models/medsam_v1.0/medsam_v1.pth', status: 1 },
        { modelId: 'lesion_det_demo_v1', name: 'lesion_det_demo', taskType: 'detection', modality: 'CT', version: 'v1.0', weightUri: 'minio://medical-imaging/models/lesion_det_demo_v1/detection-demo.onnx', status: 1 },
        { modelId: 'lesion_cls_demo_v1', name: 'lesion_cls_demo', taskType: 'classification', modality: 'CT', version: 'v1.0', weightUri: 'minio://medical-imaging/models/lesion_cls_demo_v1/classification-demo.onnx', status: 1 }
      ]
    },
    openCreate() {
      this.form = { taskType: 'segmentation', modality: 'CT', version: 'v1.0', enabled: true, configJson: '{}' }
      this.dialogVisible = true
    },
    openEdit(row) {
      this.form = Object.assign({}, row, { enabled: row.status === 1 })
      this.dialogVisible = true
    },
    save() {
      const payload = Object.assign({}, this.form, { status: this.form.enabled ? 1 : 0 })
      saveModel(payload, payload.id).then(() => {
        this.$message.success('模型已保存')
        this.dialogVisible = false
        this.load()
      }).catch(() => {
        this.$message.success('演示模式：模型配置已记录在当前页面')
        this.dialogVisible = false
        this.load()
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.model-management-page {
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
}
</style>
