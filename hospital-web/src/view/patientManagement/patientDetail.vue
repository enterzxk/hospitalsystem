<template>
  <div class="patient-detail-page">
    <div class="page-header">
      <h2>患者详情</h2>
      <el-button icon="el-icon-back" @click="goBack">返回列表</el-button>
    </div>
    <el-card>
      <el-descriptions title="基本信息" :column="2" border>
        <el-descriptions-item label="患者ID">{{ patientData.id }}</el-descriptions-item>
        <el-descriptions-item label="姓名">{{ patientData.name }}</el-descriptions-item>
        <el-descriptions-item label="性别">{{ patientData.gender === 1 ? '男' : '女' }}</el-descriptions-item>
        <el-descriptions-item label="年龄">{{ patientData.age }}岁</el-descriptions-item>
        <el-descriptions-item label="手机号码">{{ patientData.phone }}</el-descriptions-item>
        <el-descriptions-item label="身份证号">{{ patientData.idCard }}</el-descriptions-item>
        <el-descriptions-item label="注册时间" :span="2">{{ patientData.createTime }}</el-descriptions-item>
        <el-descriptions-item label="家庭住址" :span="2">{{ patientData.address || '暂无' }}</el-descriptions-item>
      </el-descriptions>
    </el-card>
    <el-card class="history-card">
      <div slot="header">
        <span>就诊记录</span>
      </div>
      <el-table :data="visitRecords" style="width: 100%">
        <el-table-column prop="id" label="记录ID" width="100"></el-table-column>
        <el-table-column prop="visitDate" label="就诊日期" width="150"></el-table-column>
        <el-table-column prop="department" label="科室" width="120"></el-table-column>
        <el-table-column prop="doctor" label="医生" width="120"></el-table-column>
        <el-table-column prop="diagnosis" label="诊断" show-overflow-tooltip></el-table-column>
        <el-table-column label="操作" width="100">
          <template slot-scope="scope">
            <el-button type="text" icon="el-icon-view" @click="handleViewDiagnosis(scope.row)">查看</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    <el-card class="imaging-card">
      <div slot="header">
        <span>影像记录</span>
      </div>
      <el-table :data="imagingRecords" style="width: 100%">
        <el-table-column prop="id" label="影像ID" width="100"></el-table-column>
        <el-table-column prop="type" label="类型" width="100">
          <template slot-scope="scope">
            <el-tag>{{ scope.row.type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="uploadTime" label="上传时间" width="180"></el-table-column>
        <el-table-column prop="doctor" label="上传医生" width="120"></el-table-column>
        <el-table-column label="操作" width="100">
          <template slot-scope="scope">
            <el-button type="text" icon="el-icon-view" @click="handleViewImaging(scope.row)">查看</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script>
export default {
  name: 'patientDetail',
  data() {
    return {
      patientData: {
        id: 1,
        name: '张三',
        gender: 1,
        age: 35,
        phone: '13800138001',
        idCard: '110101199001011234',
        createTime: '2024-01-15 10:00:00',
        address: '云岚市青澜区云岚宗大道88号'
      },
      visitRecords: [
        { id: 1, visitDate: '2024-12-15', department: '内科', doctor: '王医生', diagnosis: '上呼吸道感染' },
        { id: 2, visitDate: '2024-11-20', department: '内科', doctor: '李医生', diagnosis: '感冒' }
      ],
      imagingRecords: [
        { id: 1, type: 'X光', uploadTime: '2024-12-15 10:30:00', doctor: '王医生' }
      ]
    }
  },
  methods: {
    goBack() {
      this.$router.push('/patientList');
    },
    handleViewDiagnosis(row) {
      this.$router.push({ path: '/diagnosisDetail', query: { id: row.id } });
    },
    handleViewImaging(row) {
      this.$router.push({ path: '/imagingDetail', query: { id: row.id } });
    }
  },
  created() {
    const id = this.$route.query.id;
    if (id) {
      console.log('加载患者ID:', id);
    }
  }
}
</script>

<style lang="scss" scoped>
.patient-detail-page {
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

  .history-card,
  .imaging-card {
    margin-top: 20px;
  }
}
</style>
