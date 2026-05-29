<template>
  <div class="payment-records">
    <div class="page-header">
      <h2><i class="el-icon-wallet"></i> 缴费记录</h2>
      <p>查看您的挂号费、检查费等缴费明细</p>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-row">
      <div class="stat-card">
        <div class="stat-icon" style="background: linear-gradient(135deg, #075f42, #20a978);">
          <i class="el-icon-wallet"></i>
        </div>
        <div class="stat-info">
          <div class="stat-value">¥{{ totalPaid }}</div>
          <div class="stat-label">累计缴费</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: linear-gradient(135deg, #2980b9, #3498db);">
          <i class="el-icon-document"></i>
        </div>
        <div class="stat-info">
          <div class="stat-value">{{ paymentList.length }}</div>
          <div class="stat-label">缴费笔数</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: linear-gradient(135deg, #e67e22, #f39c12);">
          <i class="el-icon-time"></i>
        </div>
        <div class="stat-info">
          <div class="stat-value">¥{{ unpaidAmount }}</div>
          <div class="stat-label">待缴费</div>
        </div>
      </div>
    </div>

    <!-- 筛选栏 -->
    <div class="filter-bar">
      <el-input
        v-model="searchKeyword"
        placeholder="搜索项目名称/订单号"
        prefix-icon="el-icon-search"
        clearable
        style="width: 300px"
      />
      <el-select v-model="filterStatus" placeholder="缴费状态" clearable style="width: 150px; margin-left: 10px;">
        <el-option label="全部" value="" />
        <el-option label="已缴费" value="paid" />
        <el-option label="待缴费" value="unpaid" />
        <el-option label="已退款" value="refunded" />
      </el-select>
      <el-date-picker
        v-model="dateRange"
        type="daterange"
        range-separator="至"
        start-placeholder="开始日期"
        end-placeholder="结束日期"
        value-format="yyyy-MM-dd"
        style="margin-left: 10px;"
      />
    </div>

    <!-- 缴费列表 -->
    <el-table :data="filteredList" stripe style="width: 100%" v-loading="loading">
      <el-table-column prop="orderNo" label="订单号" width="180" />
      <el-table-column prop="itemName" label="项目名称" min-width="150" />
      <el-table-column prop="category" label="费用类型" width="100">
        <template slot-scope="scope">
          <el-tag size="small" :type="getCategoryType(scope.row.category)">{{ scope.row.category }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="amount" label="金额" width="100">
        <template slot-scope="scope">
          <span class="amount">¥{{ scope.row.amount }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="payTime" label="缴费时间" width="180" />
      <el-table-column label="状态" width="100">
        <template slot-scope="scope">
          <el-tag :type="getStatusType(scope.row.status)" size="small">
            {{ getStatusText(scope.row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="100" fixed="right">
        <template slot-scope="scope">
          <el-button size="mini" type="text" icon="el-icon-view" @click="viewDetail(scope.row)">详情</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <div class="pagination-wrap" v-if="total > pageSize">
      <el-pagination background layout="prev, pager, next"
                     :total="total" :page-size="pageSize"
                     :current-page.sync="currentPage"
                     @current-change="handlePageChange">
      </el-pagination>
    </div>

    <!-- 详情弹窗 -->
    <el-dialog title="缴费详情" :visible.sync="detailVisible" width="500px">
      <div v-if="currentPayment" class="detail-content">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="订单号">{{ currentPayment.orderNo }}</el-descriptions-item>
          <el-descriptions-item label="项目名称">{{ currentPayment.itemName }}</el-descriptions-item>
          <el-descriptions-item label="费用类型">{{ currentPayment.category }}</el-descriptions-item>
          <el-descriptions-item label="金额">
            <span class="amount">¥{{ currentPayment.amount }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="缴费时间">{{ currentPayment.payTime || '-' }}</el-descriptions-item>
          <el-descriptions-item label="支付方式">{{ currentPayment.payMethod || '-' }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="getStatusType(currentPayment.status)" size="small">
              {{ getStatusText(currentPayment.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="备注">{{ currentPayment.remark || '-' }}</el-descriptions-item>
        </el-descriptions>
      </div>
      <span slot="footer">
        <el-button @click="detailVisible = false">关闭</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import { getToken } from '@/utils/auth'
import { getCookie } from '@/utils/cookies'

export default {
  name: 'paymentRecords',
  data() {
    return {
      isDemo: false,
      paymentList: [],
      loading: false,
      searchKeyword: '',
      filterStatus: '',
      dateRange: null,
      detailVisible: false,
      currentPayment: null,
      currentPage: 1,
      pageSize: 10,
      total: 0
    }
  },
  computed: {
    totalPaid() {
      return this.paymentList
        .filter(item => item.status === 'paid')
        .reduce((sum, item) => sum + Number(item.amount), 0)
        .toFixed(2)
    },
    unpaidAmount() {
      return this.paymentList
        .filter(item => item.status === 'unpaid')
        .reduce((sum, item) => sum + Number(item.amount), 0)
        .toFixed(2)
    },
    filteredList() {
      return this.paymentList.filter(item => {
        const matchKeyword = !this.searchKeyword ||
          item.itemName.includes(this.searchKeyword) ||
          item.orderNo.includes(this.searchKeyword)
        const matchStatus = !this.filterStatus || item.status === this.filterStatus
        let matchDate = true
        if (this.dateRange && this.dateRange.length === 2) {
          const payDate = (item.payTime || item.createTime || '').slice(0, 10)
          matchDate = payDate >= this.dateRange[0] && payDate <= this.dateRange[1]
        }
        return matchKeyword && matchStatus && matchDate
      })
    }
  },
  created() {
    const token = getToken()
    this.isDemo = token && token.indexOf('demo-token') !== -1
    this.loadPayments()
  },
  methods: {
    getDemoPayments() {
      return [
        { id: 1, orderNo: 'PAY20260525001', itemName: '呼吸内科门诊挂号费', category: '挂号费', amount: '15.00', payTime: '2026-05-25 08:30:00', payMethod: '微信支付', status: 'paid', remark: '普通门诊' },
        { id: 2, orderNo: 'PAY20260525002', itemName: '胸部CT检查费', category: '检查费', amount: '450.00', payTime: '2026-05-25 09:15:00', payMethod: '支付宝', status: 'paid', remark: 'CT平扫' },
        { id: 3, orderNo: 'PAY20260520001', itemName: '骨科门诊挂号费', category: '挂号费', amount: '12.00', payTime: '2026-05-20 08:45:00', payMethod: '微信支付', status: 'paid', remark: '专家门诊' },
        { id: 4, orderNo: 'PAY20260520002', itemName: '腰椎MRI检查费', category: '检查费', amount: '800.00', payTime: '2026-05-20 10:00:00', payMethod: '银行卡', status: 'paid', remark: 'MRI平扫' },
        { id: 5, orderNo: 'PAY20260528001', itemName: '内科复诊挂号费', category: '挂号费', amount: '10.00', payTime: '', payMethod: '', status: 'unpaid', remark: '待缴费' },
        { id: 6, orderNo: 'PAY20260515001', itemName: '皮肤科门诊挂号费', category: '挂号费', amount: '12.00', payTime: '2026-05-15 14:00:00', payMethod: '微信支付', status: 'refunded', remark: '已取消预约退款' }
      ]
    },
    loadPayments() {
      this.loading = true
      setTimeout(() => {
        this.paymentList = this.getDemoPayments()
        this.total = this.paymentList.length
        this.loading = false
      }, 300)
    },
    getCategoryType(category) {
      const map = { '挂号费': 'primary', '检查费': 'warning', '药品费': 'success', '治疗费': 'danger' }
      return map[category] || 'info'
    },
    getStatusType(status) {
      const map = { paid: 'success', unpaid: 'warning', refunded: 'info' }
      return map[status] || 'info'
    },
    getStatusText(status) {
      const map = { paid: '已缴费', unpaid: '待缴费', refunded: '已退款' }
      return map[status] || '未知'
    },
    viewDetail(row) {
      this.currentPayment = row
      this.detailVisible = true
    },
    handlePageChange(page) {
      this.currentPage = page
    }
  }
}
</script>

<style lang="scss" scoped>
$primary: #075f42;
$primary-light: #20a978;

.payment-records {
  padding: 20px;
}

.page-header {
  margin-bottom: 24px;
  h2 {
    font-size: 22px;
    color: $primary;
    margin: 0 0 8px;
    i { margin-right: 8px; }
  }
  p { color: #999; font-size: 14px; margin: 0; }
}

.stats-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  display: flex;
  align-items: center;
  box-shadow: 0 2px 12px rgba(0,0,0,0.05);
  transition: transform 0.3s;
  &:hover {
    transform: translateY(-2px);
  }
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 16px;
  i {
    font-size: 28px;
    color: white;
  }
}

.stat-info {
  .stat-value {
    font-size: 28px;
    font-weight: 600;
    color: #333;
    line-height: 1;
    margin-bottom: 4px;
  }
  .stat-label {
    font-size: 13px;
    color: #999;
  }
}

.filter-bar {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  background: white;
  padding: 16px 20px;
  border-radius: 8px;
  border: 1px solid rgba(0, 122, 77, 0.08);
  box-shadow: 0 2px 12px rgba(8, 83, 61, 0.05);
}

.amount {
  color: #e6a23c;
  font-weight: 600;
}

.pagination-wrap {
  display: flex;
  justify-content: center;
  padding: 20px 0;
}

.detail-content {
  .amount {
    font-size: 18px;
  }
}
</style>
