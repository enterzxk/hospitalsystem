<template>
  <div class="patient-list-page">
    <div class="page-header">
      <h2>患者列表</h2>
      <el-button type="primary" icon="el-icon-plus" @click="handleAdd">添加患者</el-button>
    </div>
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="患者姓名">
          <el-input v-model="searchForm.name" placeholder="请输入患者姓名" clearable></el-input>
        </el-form-item>
        <el-form-item label="手机号码">
          <el-input v-model="searchForm.phone" placeholder="请输入手机号码" clearable></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="el-icon-search" @click="handleSearch">搜索</el-button>
          <el-button icon="el-icon-refresh" @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
    <el-card class="table-card">
      <el-table :data="tableData" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="ID" width="80"></el-table-column>
        <el-table-column prop="name" label="患者姓名" width="120"></el-table-column>
        <el-table-column prop="gender" label="性别" width="80">
          <template slot-scope="scope">
            {{ scope.row.gender === 1 ? '男' : '女' }}
          </template>
        </el-table-column>
        <el-table-column prop="age" label="年龄" width="80"></el-table-column>
        <el-table-column prop="phone" label="手机号码" width="140"></el-table-column>
        <el-table-column prop="idCard" label="身份证号" width="180"></el-table-column>
        <el-table-column prop="createTime" label="注册时间" width="180"></el-table-column>
        <el-table-column label="操作" width="200">
          <template slot-scope="scope">
            <el-button type="text" icon="el-icon-view" @click="handleView(scope.row)">查看</el-button>
            <el-button type="text" icon="el-icon-edit" @click="handleEdit(scope.row)">编辑</el-button>
            <el-button type="text" icon="el-icon-delete" class="danger-btn" @click="handleDelete(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-pagination
        class="pagination"
        background
        layout="total, sizes, prev, pager, next"
        :total="total"
        :page-sizes="[10, 20, 50]"
        @current-change="handleCurrentChange"
        @size-change="handleSizeChange">
      </el-pagination>
    </el-card>
  </div>
</template>

<script>
export default {
  name: 'patientList',
  data() {
    return {
      loading: false,
      searchForm: {
        name: '',
        phone: ''
      },
      tableData: [
        { id: 1, name: '张三', gender: 1, age: 35, phone: '13800138001', idCard: '110101199001011234', createTime: '2024-01-15 10:00:00' },
        { id: 2, name: '李四', gender: 2, age: 28, phone: '13800138002', idCard: '110101199601021234', createTime: '2024-03-20 14:30:00' },
        { id: 3, name: '王五', gender: 1, age: 52, phone: '13800138003', idCard: '110101197201031234', createTime: '2024-06-10 09:15:00' }
      ],
      total: 3
    }
  },
  methods: {
    handleAdd() {
      this.$message.info('添加患者功能开发中');
    },
    handleView(row) {
      this.$router.push({ path: '/patientDetail', query: { id: row.id } });
    },
    handleEdit(row) {
      this.$message.info('编辑患者功能开发中');
    },
    handleDelete(row) {
      this.$confirm('确定要删除该患者记录吗？', '提示', {
        type: 'warning'
      }).then(() => {
        this.$message.success('删除成功');
      }).catch(() => {});
    },
    handleSearch() {
      this.$message.info('搜索功能开发中');
    },
    handleReset() {
      this.searchForm = { name: '', phone: '' };
    },
    handleCurrentChange(val) {
      console.log('当前页:', val);
    },
    handleSizeChange(val) {
      console.log('每页条数:', val);
    }
  }
}
</script>

<style lang="scss" scoped>
.patient-list-page {
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
