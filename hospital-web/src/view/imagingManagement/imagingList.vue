<template>
  <div class="imaging-list-page">
    <div class="page-header">
      <div>
        <h2>影像管理</h2>
        <p>医生可查看患者检查片子，并从这里进入诊断报告填写流程。</p>
      </div>
      <el-button type="primary" icon="el-icon-upload" @click="handleUpload">上传影像</el-button>
    </div>
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="患者姓名">
          <el-input v-model="searchForm.patientName" placeholder="请输入患者姓名" clearable></el-input>
        </el-form-item>
        <el-form-item label="影像类型">
          <el-select v-model="searchForm.type" placeholder="请选择" clearable>
            <el-option label="X光" value="X光"></el-option>
            <el-option label="CT" value="CT"></el-option>
            <el-option label="MRI" value="MRI"></el-option>
            <el-option label="超声" value="超声"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="诊断状态">
          <el-select v-model="searchForm.diagnosisStatus" placeholder="请选择" clearable>
            <el-option label="待诊断" value="pending"></el-option>
            <el-option label="已诊断" value="completed"></el-option>
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
        <el-table-column prop="id" label="影像ID" width="95"></el-table-column>
        <el-table-column prop="patientName" label="患者姓名" width="120"></el-table-column>
        <el-table-column prop="type" label="影像类型" width="100">
          <template slot-scope="scope">
            <el-tag :type="getTypeTag(scope.row.type)">{{ scope.row.type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="bodyPart" label="检查部位" width="110"></el-table-column>
        <el-table-column prop="uploadTime" label="上传时间" width="170"></el-table-column>
        <el-table-column prop="doctorName" label="上传医生" width="110"></el-table-column>
        <el-table-column label="诊断状态" width="110">
          <template slot-scope="scope">
            <el-tag :type="scope.row.diagnosisStatus === 'completed' ? 'success' : 'warning'">
              {{ scope.row.diagnosisStatus === 'completed' ? '已诊断' : '待诊断' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="检查说明" show-overflow-tooltip></el-table-column>
        <el-table-column label="操作" width="260" fixed="right">
          <template slot-scope="scope">
            <el-button type="text" icon="el-icon-view" @click="handleView(scope.row)">查看片子</el-button>
            <el-button type="text" icon="el-icon-edit" @click="handleDiagnose(scope.row)">
              {{ scope.row.diagnosisStatus === 'completed' ? '查看报告' : '填写报告' }}
            </el-button>
            <el-button type="text" icon="el-icon-delete" class="danger-btn" @click="handleDelete(scope.row)">删除</el-button>
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
  { id: 10001, patientId: 30001, patientName: '张明', gender: '男', age: 46, phone: '13810010001', type: 'X光', bodyPart: '胸部', uploadTime: '2026-05-26 09:20:00', doctorName: '林医生', fileSize: '2.8MB', diagnosisStatus: 'pending', remark: '咳嗽伴低热，胸部正侧位片。' },
  { id: 10002, patientId: 30002, patientName: '李娜', gender: '女', age: 33, phone: '13810010002', type: 'CT', bodyPart: '头颅', uploadTime: '2026-05-26 10:15:00', doctorName: '林医生', fileSize: '18.4MB', diagnosisStatus: 'completed', reportId: 20001, remark: '头痛一周，头颅CT平扫。' },
  { id: 10003, patientId: 30003, patientName: '周强', gender: '男', age: 58, phone: '13810010003', type: 'MRI', bodyPart: '腰椎', uploadTime: '2026-05-25 15:40:00', doctorName: '韩医生', fileSize: '35.6MB', diagnosisStatus: 'pending', remark: '腰痛伴左下肢放射痛。' },
  { id: 10004, patientId: 30004, patientName: '赵敏', gender: '女', age: 41, phone: '13810010004', type: '超声', bodyPart: '腹部', uploadTime: '2026-05-24 14:05:00', doctorName: '韩医生', fileSize: '6.1MB', diagnosisStatus: 'completed', reportId: 20002, remark: '右上腹不适，腹部超声检查。' },
  { id: 10005, patientId: 30005, patientName: '陈晨', gender: '男', age: 27, phone: '13810010005', type: 'CT', bodyPart: '胸部', uploadTime: '2026-05-23 11:30:00', doctorName: '林医生', fileSize: '22.0MB', diagnosisStatus: 'pending', remark: '胸闷气短，胸部CT薄层扫描。' }
];

export default {
  name: 'imagingList',
  data() {
    return {
      loading: false,
      pageNum: 1,
      pageSize: 10,
      searchForm: {
        patientName: '',
        type: '',
        diagnosisStatus: ''
      },
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
    ensureDemoData() {
      if (!localStorage.getItem(IMAGING_KEY)) {
        localStorage.setItem(IMAGING_KEY, JSON.stringify(defaultImagings));
      }
      if (!localStorage.getItem(REPORT_KEY)) {
        localStorage.setItem(REPORT_KEY, JSON.stringify([
          { id: 20001, reportNo: 'YLZ-R-20260526001', imagingId: 10002, patientId: 30002, patientName: '李娜', gender: '女', age: 33, phone: '13810010002', doctorName: '林医生', reportDate: '2026-05-26 11:05:00', examinationType: 'CT', bodyPart: '头颅', clinicalDiagnosis: '头痛待查', examinationFindings: '头颅CT平扫示脑实质密度未见明显异常，脑室系统形态大小正常，中线结构居中。', diagnosticOpinion: '头颅CT未见明确急性异常征象。建议结合神经内科查体及随访。', treatment: '建议休息，监测血压；如头痛加重或伴呕吐、肢体无力，及时复诊。', reportStatus: 'submitted' },
          { id: 20002, reportNo: 'YLZ-R-20260524001', imagingId: 10004, patientId: 30004, patientName: '赵敏', gender: '女', age: 41, phone: '13810010004', doctorName: '韩医生', reportDate: '2026-05-24 15:00:00', examinationType: '超声', bodyPart: '腹部', clinicalDiagnosis: '右上腹不适', examinationFindings: '肝胆胰脾超声检查，胆囊壁稍毛糙，未见明显结石声影。', diagnosticOpinion: '胆囊壁轻度改变，建议结合肝胆功能检查。', treatment: '清淡饮食，必要时消化内科复诊。', reportStatus: 'submitted' }
        ]));
      }
    },
    loadData() {
      this.ensureDemoData();
      this.tableData = JSON.parse(localStorage.getItem(IMAGING_KEY) || '[]');
      this.handleSearch();
    },
    getTypeTag(type) {
      const map = { 'X光': '', 'CT': 'success', 'MRI': 'warning', '超声': 'info' };
      return map[type] || '';
    },
    handleUpload() {
      this.$router.push('/imagingUpload');
    },
    handleView(row) {
      this.$router.push({ path: '/imagingDetail', query: { id: row.id } });
    },
    handleDiagnose(row) {
      if (row.diagnosisStatus === 'completed' && row.reportId) {
        this.$router.push({ path: '/diagnosisDetail', query: { id: row.reportId } });
        return;
      }
      this.$router.push({ path: '/diagnosisWrite', query: { imagingId: row.id, patientId: row.patientId } });
    },
    handleDelete(row) {
      this.$confirm('确定要删除该影像记录吗？', '提示', {
        type: 'warning'
      }).then(() => {
        this.tableData = this.tableData.filter(item => item.id !== row.id);
        localStorage.setItem(IMAGING_KEY, JSON.stringify(this.tableData));
        this.handleSearch();
        this.$message.success('删除成功');
      }).catch(() => {});
    },
    handleSearch() {
      const patientName = this.searchForm.patientName.trim();
      this.filteredData = this.tableData.filter(item => {
        const matchName = !patientName || item.patientName.includes(patientName);
        const matchType = !this.searchForm.type || item.type === this.searchForm.type;
        const matchStatus = !this.searchForm.diagnosisStatus || item.diagnosisStatus === this.searchForm.diagnosisStatus;
        return matchName && matchType && matchStatus;
      });
      this.pageNum = 1;
    },
    handleReset() {
      this.searchForm = { patientName: '', type: '', diagnosisStatus: '' };
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
  }
}
</script>

<style lang="scss" scoped>
.imaging-list-page {
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

  .danger-btn {
    color: #f56c6c;

    &:hover {
      color: #f78989;
    }
  }
}
</style>
