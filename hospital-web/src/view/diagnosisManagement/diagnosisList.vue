<template>
  <div class="diagnosis-list-page">
    <div class="page-header">
      <div>
        <h2>诊断报告</h2>
        <p>管理医生根据患者影像片子填写并上传的诊断报告。</p>
      </div>
      <el-button type="primary" icon="el-icon-edit" @click="handleNewDiagnosis">新建报告</el-button>
    </div>
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="患者姓名">
          <el-input v-model="searchForm.patientName" placeholder="请输入患者姓名" clearable></el-input>
        </el-form-item>
        <el-form-item label="报告状态">
          <el-select v-model="searchForm.status" placeholder="请选择" clearable>
            <el-option label="待诊断" value="pending"></el-option>
            <el-option label="草稿" value="draft"></el-option>
            <el-option label="已上传" value="submitted"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" @click="handleSearch">搜索</el-button>
          <el-button icon="el-icon-refresh" @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
    <el-card class="table-card">
      <el-table :data="pagedData" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="ID" width="90"></el-table-column>
        <el-table-column prop="reportNo" label="报告编号" width="170">
          <template slot-scope="scope">
            <span>{{ scope.row.reportNo || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="patientName" label="患者姓名" width="120"></el-table-column>
        <el-table-column prop="examinationType" label="检查类型" width="100"></el-table-column>
        <el-table-column prop="bodyPart" label="检查部位" width="110"></el-table-column>
        <el-table-column label="影像标注" width="130">
          <template slot-scope="scope">
            <el-tag :type="getAnnotationTag(scope.row)" size="small">{{ getAnnotationText(scope.row) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="doctorName" label="诊断医生" width="120"></el-table-column>
        <el-table-column prop="reportDate" label="报告日期" width="170">
          <template slot-scope="scope">
            <span>{{ scope.row.reportDate || scope.row.uploadTime || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template slot-scope="scope">
            <el-tag :type="getStatusTag(scope.row.reportStatus)">
              {{ getStatusText(scope.row.reportStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="diagnosticOpinion" label="诊断意见" show-overflow-tooltip>
          <template slot-scope="scope">
            <span>{{ scope.row.diagnosticOpinion || scope.row.remark || '等待医生填写报告' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="240" fixed="right">
          <template slot-scope="scope">
            <el-button v-if="scope.row.reportStatus !== 'pending'" type="text" icon="el-icon-view" @click="handleView(scope.row)">查看</el-button>
            <el-button type="text" icon="el-icon-edit" @click="handleEdit(scope.row)">
              {{ scope.row.reportStatus === 'pending' ? '填写报告' : '编辑' }}
            </el-button>
            <el-button type="text" icon="el-icon-picture-outline" @click="handleViewImaging(scope.row)">看片子</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        class="pagination"
        background
        layout="total, sizes, prev, pager, next"
        :total="filteredData.length"
        :current-page="pageNum"
        :page-size="pageSize"
        :page-sizes="[5, 10, 20]"
        @current-change="handleCurrentChange"
        @size-change="handleSizeChange">
      </el-pagination>
    </el-card>
  </div>
</template>

<script>
const IMAGING_KEY = 'ylz_demo_imagings';
const REPORT_KEY = 'ylz_demo_reports';

const defaultImagings = [
  { id: 10001, patientId: 30001, patientName: '张明', gender: '男', age: 46, phone: '13810010001', type: 'CT', bodyPart: '胸部', uploadTime: '2026-05-26 09:20:00', doctorName: '沈放射', fileSize: '114.8MB', diagnosisStatus: 'pending', radiologyStatus: '待标注', remark: '胸部 CT 肺窗薄层扫描，已导入 lung_001.nii.gz，需完成肺部病灶人工标注。' },
  { id: 10002, patientId: 30002, patientName: '李娜', gender: '女', age: 33, phone: '13810010002', type: 'CT', bodyPart: '头颅', uploadTime: '2026-05-26 10:15:00', doctorName: '林医生', fileSize: '18.4MB', diagnosisStatus: 'completed', reportId: 20001, remark: '头痛一周，头颅CT平扫。' },
  { id: 10003, patientId: 30003, patientName: '周强', gender: '男', age: 58, phone: '13810010003', type: 'MRI', bodyPart: '腰椎', uploadTime: '2026-05-25 15:40:00', doctorName: '韩医生', fileSize: '35.6MB', diagnosisStatus: 'pending', remark: '腰痛伴左下肢放射痛。' },
  { id: 10004, patientId: 30004, patientName: '赵敏', gender: '女', age: 41, phone: '13810010004', type: '超声', bodyPart: '腹部', uploadTime: '2026-05-24 14:05:00', doctorName: '韩医生', fileSize: '6.1MB', diagnosisStatus: 'completed', reportId: 20002, remark: '右上腹不适，腹部超声检查。' }
];

const defaultReports = [
  { id: 20001, reportNo: 'YLZ-R-20260526001', imagingId: 10002, patientId: 30002, patientName: '李娜', gender: '女', age: 33, phone: '13810010002', doctorName: '林医生', reportDate: '2026-05-26 11:05:00', examinationType: 'CT', bodyPart: '头颅', clinicalDiagnosis: '头痛待查', examinationFindings: '头颅CT平扫示脑实质密度未见明显异常，脑室系统形态大小正常，中线结构居中。', diagnosticOpinion: '头颅CT未见明确急性异常征象。建议结合神经内科查体及随访。', treatment: '建议休息，监测血压；如头痛加重或伴呕吐、肢体无力，及时复诊。', reportStatus: 'submitted' },
  { id: 20002, reportNo: 'YLZ-R-20260524001', imagingId: 10004, patientId: 30004, patientName: '赵敏', gender: '女', age: 41, phone: '13810010004', doctorName: '韩医生', reportDate: '2026-05-24 15:00:00', examinationType: '超声', bodyPart: '腹部', clinicalDiagnosis: '右上腹不适', examinationFindings: '肝胆胰脾超声检查，胆囊壁稍毛糙，未见明显结石声影。', diagnosticOpinion: '胆囊壁轻度改变，建议结合肝胆功能检查。', treatment: '清淡饮食，必要时消化内科复诊。', reportStatus: 'submitted' }
];

export default {
  name: 'diagnosisList',
  data() {
    return {
      loading: false,
      pageNum: 1,
      pageSize: 10,
      searchForm: {
        patientName: '',
        status: ''
      },
      reports: [],
      imagings: [],
      tableData: [],
      filteredData: []
    }
  },
  computed: {
    pagedData() {
      const start = (this.pageNum - 1) * this.pageSize;
      return this.filteredData.slice(start, start + this.pageSize);
    }
  },
  methods: {
    loadData() {
      if (!localStorage.getItem(IMAGING_KEY)) {
        localStorage.setItem(IMAGING_KEY, JSON.stringify(defaultImagings));
      }
      if (!localStorage.getItem(REPORT_KEY)) {
        localStorage.setItem(REPORT_KEY, JSON.stringify(defaultReports));
      }
      this.reports = JSON.parse(localStorage.getItem(REPORT_KEY) || '[]');
      this.imagings = JSON.parse(localStorage.getItem(IMAGING_KEY) || '[]').map(item => {
        if (Number(item.id) !== 10001) return item;
        return Object.assign({}, item, {
          type: 'CT',
          bodyPart: '胸部',
          doctorName: item.doctorName || '沈放射',
          fileSize: '114.8MB',
          radiologyStatus: item.radiologyStatus || '待标注',
          remark: item.remark && item.remark.indexOf('lung_001') !== -1 ? item.remark : defaultImagings[0].remark
        });
      });
      localStorage.setItem(IMAGING_KEY, JSON.stringify(this.imagings));
      const reportRows = this.reports.map(item => ({
        ...item,
        examinationType: item.examinationType,
        reportStatus: item.reportStatus || 'submitted'
      }));
      const pendingRows = this.imagings
        .filter(item => item.diagnosisStatus !== 'completed')
        .map(item => ({
          id: item.id,
          imagingId: item.id,
          patientId: item.patientId,
          patientName: item.patientName,
          doctorName: item.doctorName,
          reportDate: '',
          uploadTime: item.uploadTime,
          examinationType: item.type,
          bodyPart: item.bodyPart,
          radiologyStatus: item.radiologyStatus || '待标注',
          medsamResult: item.medsamResult || null,
          reportStatus: 'pending',
          remark: item.remark
        }));
      this.tableData = pendingRows.concat(reportRows);
      this.handleSearch();
    },
    getStatusText(status) {
      const map = { pending: '待诊断', draft: '草稿', submitted: '已上传' };
      return map[status] || '已上传';
    },
    getStatusTag(status) {
      const map = { pending: 'warning', draft: 'info', submitted: 'success' };
      return map[status] || 'success';
    },
    getAnnotationText(row) {
      if (row.medsamResult) return row.radiologyStatus || '已标注';
      return row.reportStatus === 'submitted' ? '已归档' : '待标注';
    },
    getAnnotationTag(row) {
      if (row.medsamResult) return 'success';
      return row.reportStatus === 'submitted' ? 'info' : 'warning';
    },
    handleNewDiagnosis() {
      this.$router.push('/diagnosisWrite');
    },
    handleView(row) {
      this.$router.push({ path: '/diagnosisDetail', query: { id: row.id } });
    },
    handleEdit(row) {
      if (row.reportStatus === 'pending') {
        this.$router.push({ path: '/diagnosisWrite', query: { imagingId: row.imagingId || row.id, patientId: row.patientId } });
        return;
      }
      this.$router.push({ path: '/diagnosisWrite', query: { id: row.id } });
    },
    handleViewImaging(row) {
      this.$router.push({ path: '/imagingViewer', query: { id: row.imagingId || row.id } });
    },
    handleSearch() {
      const patientName = this.searchForm.patientName.trim();
      this.filteredData = this.tableData.filter(item => {
        const matchName = !patientName || item.patientName.includes(patientName);
        const matchStatus = !this.searchForm.status || item.reportStatus === this.searchForm.status;
        return matchName && matchStatus;
      });
      this.pageNum = 1;
    },
    handleReset() {
      this.searchForm = { patientName: '', status: '' };
      this.handleSearch();
    },
    handleCurrentChange(val) {
      this.pageNum = val;
    },
    handleSizeChange(val) {
      this.pageSize = val;
      this.pageNum = 1;
    }
  },
  created() {
    this.loadData();
  },
  activated() {
    this.loadData();
  }
}
</script>

<style lang="scss" scoped>
.diagnosis-list-page {
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

  .search-card {
    margin-bottom: 20px;
  }

  .table-card {
    .pagination {
      margin-top: 20px;
      text-align: right;
    }
  }
}
</style>
