<template>
  <div class="radiology-result-list">
    <div class="page-header">
      <h2>放射科诊断结果</h2>
      <el-button type="primary" icon="el-icon-refresh" @click="refreshList">刷新</el-button>
    </div>

    <el-card>
      <div class="filter-bar">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索患者姓名/影像类型"
          prefix-icon="el-icon-search"
          clearable
          style="width: 300px"
        />
        <el-select v-model="filterStatus" placeholder="诊断状态" clearable style="width: 150px; margin-left: 10px;">
          <el-option label="全部" value="" />
          <el-option label="待诊断" value="pending" />
          <el-option label="已诊断" value="completed" />
        </el-select>
      </div>

      <el-table :data="filteredList" stripe style="width: 100%" v-loading="loading">
        <el-table-column prop="patientName" label="患者姓名" width="120" />
        <el-table-column prop="gender" label="性别" width="80" />
        <el-table-column prop="age" label="年龄" width="80" />
        <el-table-column prop="type" label="影像类型" width="100">
          <template slot-scope="scope">
            <el-tag size="small">{{ scope.row.type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="bodyPart" label="检查部位" width="100" />
        <el-table-column prop="uploadTime" label="上传时间" width="180" />
        <el-table-column label="诊断状态" width="100">
          <template slot-scope="scope">
            <el-tag :type="scope.row.diagnosisStatus === 'completed' ? 'success' : 'warning'" size="small">
              {{ scope.row.diagnosisStatus === 'completed' ? '已诊断' : '待诊断' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="放射科结果" min-width="200">
          <template slot-scope="scope">
            <div v-if="scope.row.radiologyResult" class="result-brief">
              <span class="result-type">{{ scope.row.radiologyResult.type }}</span>
              <span class="result-opinion">{{ scope.row.radiologyResult.opinion }}</span>
            </div>
            <span v-else class="no-result">暂无结果</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template slot-scope="scope">
            <el-button size="mini" type="primary" icon="el-icon-view" @click="viewDetail(scope.row)">查看详情</el-button>
            <el-button size="mini" type="success" icon="el-icon-edit" @click="goToDiagnosis(scope.row)" v-if="scope.row.radiologyResult">去诊断</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 详情弹窗 -->
    <el-dialog title="放射科诊断结果详情" :visible.sync="detailVisible" width="700px">
      <div v-if="currentResult" class="detail-content">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="患者姓名">{{ currentResult.patientName }}</el-descriptions-item>
          <el-descriptions-item label="性别">{{ currentResult.gender }}</el-descriptions-item>
          <el-descriptions-item label="年龄">{{ currentResult.age }}岁</el-descriptions-item>
          <el-descriptions-item label="影像类型">{{ currentResult.type }}</el-descriptions-item>
          <el-descriptions-item label="检查部位">{{ currentResult.bodyPart }}</el-descriptions-item>
          <el-descriptions-item label="上传时间">{{ currentResult.uploadTime }}</el-descriptions-item>
        </el-descriptions>

        <div v-if="currentResult.radiologyResult" class="radiology-detail">
          <h4>放射科诊断结果</h4>
          <el-card shadow="never">
            <div class="result-header">
              <span class="result-type">{{ currentResult.radiologyResult.type }}</span>
              <span class="result-date">{{ currentResult.radiologyResult.date }}</span>
            </div>
            <div class="result-body">
              <p><strong>检查所见：</strong>{{ currentResult.radiologyResult.findings }}</p>
              <p><strong>诊断意见：</strong>{{ currentResult.radiologyResult.opinion }}</p>
            </div>
            <div v-if="currentResult.radiologyResult.images && currentResult.radiologyResult.images.length" class="result-images">
              <span class="image-tag" v-for="(img, idx) in currentResult.radiologyResult.images" :key="idx">
                <i class="el-icon-picture-outline"></i> {{ img }}
              </span>
            </div>
          </el-card>
        </div>
        <div v-else class="no-radiology-detail">
          <i class="el-icon-warning"></i>
          <span>暂无放射科诊断结果</span>
        </div>
      </div>
      <span slot="footer">
        <el-button @click="detailVisible = false">关闭</el-button>
        <el-button type="primary" @click="goToDiagnosis(currentResult)" v-if="currentResult && currentResult.radiologyResult">去诊断</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
const DEMO_RESULTS = [
  {
    id: 10001,
    patientName: '张明',
    gender: '男',
    age: 46,
    type: 'CT',
    bodyPart: '胸部',
    uploadTime: '2026-05-26 09:20:00',
    diagnosisStatus: 'pending',
    radiologyResult: {
      type: 'CT',
      date: '2026-05-28',
      findings: '右肺上叶见一大小约2.3cm×1.8cm结节影，边缘毛糙，分叶征阳性。纵隔未见明显肿大淋巴结。',
      opinion: '右肺上叶结节，建议进一步检查排除恶性可能。',
      images: ['lung_001.nii.gz']
    }
  },
  {
    id: 10002,
    patientName: '李娜',
    gender: '女',
    age: 33,
    type: 'CT',
    bodyPart: '头颅',
    uploadTime: '2026-05-26 10:15:00',
    diagnosisStatus: 'completed',
    radiologyResult: {
      type: 'CT',
      date: '2026-05-27',
      findings: '头颅MRI平扫未见明显异常信号影。脑室系统形态正常，中线结构居中。',
      opinion: '头颅MRI未见明显异常。建议结合临床，必要时进一步检查。',
      images: []
    }
  },
  {
    id: 10003,
    patientName: '周强',
    gender: '男',
    age: 58,
    type: 'MRI',
    bodyPart: '腰椎',
    uploadTime: '2026-05-25 15:40:00',
    diagnosisStatus: 'pending',
    radiologyResult: null
  },
  {
    id: 10005,
    patientName: '陈晨',
    gender: '男',
    age: 27,
    type: 'CT',
    bodyPart: '胸部',
    uploadTime: '2026-05-23 11:30:00',
    diagnosisStatus: 'pending',
    radiologyResult: {
      type: 'CT',
      date: '2026-05-28',
      findings: '双肺纹理增粗，右肺下叶见片状模糊影，边界不清。',
      opinion: '右肺下叶炎症可能大，建议抗感染治疗后复查。',
      images: ['chest_002.nii.gz']
    }
  }
]

export default {
  name: 'radiologyResultList',
  data() {
    return {
      resultList: [],
      loading: false,
      searchKeyword: '',
      filterStatus: '',
      detailVisible: false,
      currentResult: null
    }
  },
  computed: {
    filteredList() {
      return this.resultList.filter(item => {
        const matchKeyword = !this.searchKeyword ||
          item.patientName.includes(this.searchKeyword) ||
          item.type.includes(this.searchKeyword)
        const matchStatus = !this.filterStatus || item.diagnosisStatus === this.filterStatus
        return matchKeyword && matchStatus
      })
    }
  },
  created() {
    this.loadList()
  },
  methods: {
    loadList() {
      this.loading = true
      setTimeout(() => {
        this.resultList = DEMO_RESULTS
        this.loading = false
      }, 300)
    },
    refreshList() {
      this.loadList()
      this.$message.success('列表已刷新')
    },
    viewDetail(row) {
      this.currentResult = row
      this.detailVisible = true
    },
    goToDiagnosis(row) {
      if (!row || !row.radiologyResult) return
      this.$router.push({
        path: '/diagnosisWrite',
        query: { patientId: row.id }
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.radiology-result-list {
  padding: 20px;
  background: #f5f7fa;
  min-height: 100vh;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;

  h2 {
    margin: 0;
    font-size: 22px;
    color: #333;
  }
}

.filter-bar {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
}

.result-brief {
  display: flex;
  flex-direction: column;
  gap: 4px;

  .result-type {
    font-weight: bold;
    color: #409eff;
    font-size: 13px;
  }

  .result-opinion {
    font-size: 12px;
    color: #666;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    max-width: 250px;
  }
}

.no-result {
  color: #999;
  font-size: 13px;
}

.detail-content {
  .radiology-detail {
    margin-top: 20px;

    h4 {
      margin: 0 0 10px;
      color: #409eff;
      font-size: 16px;
    }
  }

  .result-header {
    display: flex;
    justify-content: space-between;
    margin-bottom: 10px;

    .result-type {
      font-weight: bold;
      color: #333;
    }

    .result-date {
      color: #999;
      font-size: 13px;
    }
  }

  .result-body {
    p {
      margin: 8px 0;
      line-height: 1.6;
      color: #555;
    }
  }

  .result-images {
    margin-top: 10px;
    display: flex;
    gap: 10px;

    .image-tag {
      padding: 4px 10px;
      background: #e1f3d8;
      border-radius: 4px;
      font-size: 12px;
      color: #67c23a;

      i {
        margin-right: 4px;
      }
    }
  }

  .no-radiology-detail {
    margin-top: 20px;
    padding: 20px;
    text-align: center;
    background: #fdf6ec;
    border-radius: 8px;
    color: #e6a23c;

    i {
      font-size: 24px;
      margin-bottom: 8px;
      display: block;
    }
  }
}
</style>
