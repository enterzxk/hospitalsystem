<template>
  <div class="diagnosis-reports-page">
    <div class="page-header">
      <h2>我的诊断报告</h2>
      <el-button type="primary" icon="el-icon-refresh" @click="refreshList">刷新列表</el-button>
    </div>

    <!-- 筛选栏 -->
    <el-card class="filter-card">
      <el-form :inline="true" :model="filterForm">
        <el-form-item label="报告状态">
          <el-select v-model="filterForm.reportStatus" placeholder="全部状态" clearable>
            <el-option label="草稿" :value="0"></el-option>
            <el-option label="已提交" :value="1"></el-option>
            <el-option label="已审核" :value="2"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="检查类型">
          <el-select v-model="filterForm.examinationType" placeholder="全部类型" clearable>
            <el-option label="CT" value="CT"></el-option>
            <el-option label="MRI" value="MRI"></el-option>
            <el-option label="X光" value="X光"></el-option>
            <el-option label="超声" value="超声"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleFilter">查询</el-button>
          <el-button @click="resetFilter">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 报告列表 -->
    <el-card class="list-card">
      <el-table :data="reportList" style="width: 100%" v-loading="loading">
        <el-table-column prop="reportNo" label="报告编号" width="150"></el-table-column>
        <el-table-column prop="patientName" label="患者姓名" width="120"></el-table-column>
        <el-table-column prop="gender" label="性别" width="80">
          <template slot-scope="scope">
            <el-tag :type="scope.row.gender === '男' ? '' : 'danger'" size="mini">
              {{ scope.row.gender }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="age" label="年龄" width="80"></el-table-column>
        <el-table-column prop="examinationType" label="检查类型" width="100">
          <template slot-scope="scope">
            <el-tag>{{ scope.row.examinationType }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="bodyPart" label="检查部位" width="120"></el-table-column>
        <el-table-column prop="reportDate" label="报告日期" width="120"></el-table-column>
        <el-table-column prop="reportStatus" label="报告状态" width="100">
          <template slot-scope="scope">
            <el-tag :type="getStatusType(scope.row.reportStatus)">
              {{ getStatusText(scope.row.reportStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template slot-scope="scope">
            <el-button size="mini" type="primary" @click="viewReport(scope.row)">查看</el-button>
            <el-button size="mini" type="warning" v-if="scope.row.reportStatus === 0" @click="editReport(scope.row)">编辑</el-button>
            <el-button size="mini" type="success" v-if="scope.row.reportStatus === 0" @click="submitReport(scope.row)">提交</el-button>
            <el-button size="mini" type="danger" v-if="scope.row.reportStatus === 0" @click="deleteReport(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrapper">
        <el-pagination
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          :current-page="pagination.pageNum"
          :page-sizes="[10, 20, 50]"
          :page-size="pagination.pageSize"
          layout="total, sizes, prev, pager, next, jumper"
          :total="pagination.total">
        </el-pagination>
      </div>
    </el-card>

    <!-- 查看报告详情对话框 -->
    <el-dialog title="诊断报告详情" :visible.sync="detailVisible" width="80%" top="5vh">
      <div class="report-detail" v-if="currentReport">
        <el-descriptions title="基本信息" :column="3" border>
          <el-descriptions-item label="报告编号">{{ currentReport.reportNo }}</el-descriptions-item>
          <el-descriptions-item label="患者姓名">{{ currentReport.patientName }}</el-descriptions-item>
          <el-descriptions-item label="性别">{{ currentReport.gender }}</el-descriptions-item>
          <el-descriptions-item label="年龄">{{ currentReport.age }}岁</el-descriptions-item>
          <el-descriptions-item label="身份证号">{{ currentReport.idCard }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ currentReport.phone }}</el-descriptions-item>
          <el-descriptions-item label="检查类型">{{ currentReport.examinationType }}</el-descriptions-item>
          <el-descriptions-item label="检查部位">{{ currentReport.bodyPart }}</el-descriptions-item>
          <el-descriptions-item label="报告日期">{{ currentReport.reportDate }}</el-descriptions-item>
        </el-descriptions>

        <el-divider></el-divider>

        <el-row :gutter="20">
          <el-col :span="12">
            <div class="report-section">
              <h4>临床诊断</h4>
              <p>{{ currentReport.clinicalDiagnosis || '暂无' }}</p>
            </div>
          </el-col>
          <el-col :span="12">
            <div class="report-section">
              <h4>检查所见</h4>
              <p>{{ currentReport.examinationFindings || '暂无' }}</p>
            </div>
          </el-col>
        </el-row>

        <el-row :gutter="20" style="margin-top: 20px">
          <el-col :span="24">
            <div class="report-section">
              <h4>诊断意见</h4>
              <p>{{ currentReport.diagnosticOpinion || '暂无' }}</p>
            </div>
          </el-col>
        </el-row>

        <el-divider></el-divider>

        <el-descriptions title="审核信息" :column="2" border v-if="currentReport.reportStatus === 2">
          <el-descriptions-item label="审核人">{{ currentReport.reviewerName || '未知' }}</el-descriptions-item>
          <el-descriptions-item label="审核时间">{{ currentReport.reviewTime }}</el-descriptions-item>
          <el-descriptions-item label="审核意见" :span="2">{{ currentReport.reviewOpinion || '暂无' }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <span slot="footer" class="dialog-footer">
        <el-button @click="detailVisible = false">关闭</el-button>
        <el-button type="primary" @click="printReport">打印报告</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import { getReportList, deleteReport as deleteReportApi, submitReport as submitReportApi } from '@/api/diagnosis'

export default {
  name: 'diagnosisReports',
  data() {
    return {
      loading: false,
      reportList: [],
      filterForm: {
        reportStatus: '',
        examinationType: ''
      },
      pagination: {
        pageNum: 1,
        pageSize: 10,
        total: 0
      },
      detailVisible: false,
      currentReport: null
    }
  },
  created() {
    this.loadReportList()
  },
  methods: {
    async loadReportList() {
      this.loading = true
      try {
        const params = {
          pageNum: this.pagination.pageNum,
          pageSize: this.pagination.pageSize
        }
        if (this.filterForm.reportStatus !== '') {
          params.reportStatus = this.filterForm.reportStatus
        }
        if (this.filterForm.examinationType) {
          params.examinationType = this.filterForm.examinationType
        }

        const res = await getReportList(params)
        if (res.code === 200) {
          this.reportList = res.data.list || []
          this.pagination.total = res.data.total || 0
        }
      } catch (e) {
        console.error('加载报告列表失败:', e)
        // Demo数据
        this.reportList = [
          {
            id: 1,
            reportNo: 'RPT20240319001',
            patientName: '张三',
            gender: '男',
            age: 45,
            idCard: '110101197901011234',
            phone: '13800138001',
            examinationType: 'CT',
            bodyPart: '胸部',
            reportDate: '2024-03-19',
            reportStatus: 2,
            clinicalDiagnosis: '咳嗽、胸痛3天',
            examinationFindings: '双肺纹理增粗，右下肺可见片状模糊影',
            diagnosticOpinion: '考虑右下肺感染可能',
            reviewerName: '李主任',
            reviewTime: '2024-03-19 16:30',
            reviewOpinion: '诊断明确，建议抗感染治疗'
          },
          {
            id: 2,
            reportNo: 'RPT20240319002',
            patientName: '李四',
            gender: '女',
            age: 38,
            idCard: '110101198601021234',
            phone: '13800138002',
            examinationType: 'MRI',
            bodyPart: '头部',
            reportDate: '2024-03-19',
            reportStatus: 1,
            clinicalDiagnosis: '头痛1周',
            examinationFindings: '脑实质未见明显异常信号',
            diagnosticOpinion: '头颅MRI未见明显异常'
          }
        ]
        this.pagination.total = this.reportList.length
      } finally {
        this.loading = false
      }
    },

    getStatusType(status) {
      const types = {
        0: 'info',
        1: 'warning',
        2: 'success'
      }
      return types[status] || 'info'
    },

    getStatusText(status) {
      const texts = {
        0: '草稿',
        1: '已提交',
        2: '已审核'
      }
      return texts[status] || '未知'
    },

    handleFilter() {
      this.pagination.pageNum = 1
      this.loadReportList()
    },

    resetFilter() {
      this.filterForm = {
        reportStatus: '',
        examinationType: ''
      }
      this.handleFilter()
    },

    refreshList() {
      this.loadReportList()
      this.$message.success('列表已刷新')
    },

    viewReport(row) {
      this.currentReport = row
      this.detailVisible = true
    },

    editReport(row) {
      this.$router.push({
        path: '/diagnosisWrite',
        query: { id: row.id }
      })
    },

    async submitReport(row) {
      try {
        await this.$confirm('确认提交该报告？提交后将无法修改。', '提示', {
          type: 'warning'
        })
        const res = await submitReportApi(row.id)
        if (res.code === 200) {
          this.$message.success('报告已提交')
          this.loadReportList()
        }
      } catch (e) {
        if (e !== 'cancel') {
          this.$message.error('提交失败: ' + e.message)
        }
      }
    },

    async deleteReport(row) {
      try {
        await this.$confirm('确认删除该报告？', '提示', {
          type: 'warning'
        })
        const res = await deleteReportApi(row.id)
        if (res.code === 200) {
          this.$message.success('报告已删除')
          this.loadReportList()
        }
      } catch (e) {
        if (e !== 'cancel') {
          this.$message.error('删除失败: ' + e.message)
        }
      }
    },

    printReport() {
      this.$message.info('打印功能开发中')
    },

    handleSizeChange(val) {
      this.pagination.pageSize = val
      this.loadReportList()
    },

    handleCurrentChange(val) {
      this.pagination.pageNum = val
      this.loadReportList()
    }
  }
}
</script>

<style lang="scss" scoped>
.diagnosis-reports-page {
  padding: 20px;
}

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

.filter-card,
.list-card {
  margin-bottom: 20px;
}

.pagination-wrapper {
  display: flex;
  justify-content: flex-end;
  margin-top: 20px;
}

.report-detail {
  .report-section {
    background: #f5f7fa;
    padding: 15px;
    border-radius: 8px;
    margin-bottom: 15px;

    h4 {
      margin: 0 0 10px 0;
      color: #409eff;
      font-size: 14px;
    }

    p {
      margin: 0;
      line-height: 1.8;
      color: #666;
    }
  }
}
</style>
