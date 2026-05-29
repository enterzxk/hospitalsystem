<template>
  <div class="department-intro">
    <div class="page-header">
      <h2><i class="el-icon-office-building"></i> 科室介绍</h2>
      <p>了解医院各科室特色诊疗和专家团队</p>
    </div>

    <!-- 科室分类筛选 -->
    <div class="category-filter">
      <el-radio-group v-model="activeCategory" @change="filterDepartments">
        <el-radio-button label="">全部科室</el-radio-button>
        <el-radio-button label="non-surgery">非手术科室</el-radio-button>
        <el-radio-button label="surgery">手术科室</el-radio-button>
        <el-radio-button label="diagnostic">诊断相关科室</el-radio-button>
      </el-radio-group>
    </div>

    <!-- 科室列表 -->
    <div class="department-grid">
      <div class="dept-card" v-for="dept in filteredList" :key="dept.name" @click="viewDetail(dept)">
        <div class="dept-visual" :style="{ background: dept.gradient }">
          <div class="dept-icon">
            <i :class="dept.icon"></i>
          </div>
          <div class="dept-badge">{{ dept.category }}</div>
        </div>
        <div class="dept-content">
          <h3>{{ dept.name }}</h3>
          <p class="dept-tagline">{{ dept.tagline }}</p>
          <div class="dept-meta">
            <span><i class="el-icon-location-outline"></i> {{ dept.location }}</span>
            <span><i class="el-icon-time"></i> {{ dept.time }}</span>
          </div>
          <div class="dept-services">
            <el-tag v-for="service in dept.services.slice(0, 3)" :key="service" size="small" type="success">
              {{ service }}
            </el-tag>
          </div>
        </div>
      </div>
    </div>

    <!-- 详情弹窗 -->
    <el-dialog :title="currentDept.name + ' 详情'" :visible.sync="detailVisible" width="700px">
      <div v-if="currentDept" class="detail-content">
        <div class="detail-header" :style="{ background: currentDept.gradient }">
          <div class="detail-icon">
            <i :class="currentDept.icon"></i>
          </div>
          <div class="detail-info">
            <span class="detail-category">{{ currentDept.category }}</span>
            <h3>{{ currentDept.name }}</h3>
            <p>{{ currentDept.tagline }}</p>
          </div>
        </div>

        <el-descriptions :column="2" border class="detail-meta">
          <el-descriptions-item label="位置">
            <i class="el-icon-location-outline"></i> {{ currentDept.location }}
          </el-descriptions-item>
          <el-descriptions-item label="门诊时间">
            <i class="el-icon-time"></i> {{ currentDept.time }}
          </el-descriptions-item>
          <el-descriptions-item label="联系电话">
            <i class="el-icon-phone"></i> {{ currentDept.phone }}
          </el-descriptions-item>
          <el-descriptions-item label="科室类型">
            {{ currentDept.category }}
          </el-descriptions-item>
        </el-descriptions>

        <div class="detail-section">
          <h4>科室简介</h4>
          <p>{{ currentDept.desc }}</p>
        </div>

        <div class="detail-section">
          <h4>特色诊疗</h4>
          <div class="service-tags">
            <el-tag v-for="service in currentDept.services" :key="service" type="success">
              {{ service }}
            </el-tag>
          </div>
        </div>

        <div class="detail-section">
          <h4>推荐医生</h4>
          <div class="doctor-list">
            <div class="doctor-item" v-for="doctor in currentDept.doctors" :key="doctor.name">
              <div class="doctor-avatar">
                <i class="el-icon-user"></i>
              </div>
              <div class="doctor-info">
                <span class="doctor-name">{{ doctor.name }}</span>
                <span class="doctor-title">{{ doctor.title }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      <span slot="footer">
        <el-button @click="detailVisible = false">关闭</el-button>
        <el-button type="primary" @click="goToRegister">预约挂号</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: 'departmentIntroduction',
  data() {
    return {
      activeCategory: '',
      detailVisible: false,
      currentDept: {},
      departments: [
        {
          name: '内科学系',
          category: '非手术科室',
          tagline: '覆盖常见内科疾病、慢病管理和疑难病会诊。',
          desc: '提供心血管、呼吸、消化、内分泌等综合内科诊疗，支持多学科联合门诊。',
          icon: 'el-icon-first-aid-kit',
          gradient: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          location: '门诊楼 3 层 A 区',
          time: '周一至周六 08:00-17:00',
          phone: '0571-8808-6101',
          services: ['慢病管理', '疑难病会诊', '复诊随访'],
          doctors: [
            { name: '林知远', title: '主任医师' },
            { name: '韩清澜', title: '副主任医师' }
          ]
        },
        {
          name: '心内科',
          category: '非手术科室',
          tagline: '心血管疾病筛查、诊断、介入前评估与长期管理。',
          desc: '面向高血压、冠心病、心律失常、心衰等患者提供连续诊疗服务。',
          icon: 'el-icon-data-analysis',
          gradient: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
          location: '门诊楼 4 层 B 区',
          time: '周一至周五 08:00-17:00',
          phone: '0571-8808-6202',
          services: ['心电图判读', '心衰门诊', '用药随访'],
          doctors: [
            { name: '许明序', title: '主任医师' },
            { name: '程若水', title: '主治医师' }
          ]
        },
        {
          name: '呼吸与危重症医学科',
          category: '非手术科室',
          tagline: '呼吸系统疾病、肺部影像异常和重症呼吸支持。',
          desc: '开展慢阻肺、哮喘、肺部感染、肺结节初筛和呼吸康复评估。',
          icon: 'el-icon-odometer',
          gradient: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
          location: '门诊楼 3 层 C 区',
          time: '周一至周六 08:00-17:00',
          phone: '0571-8808-6303',
          services: ['肺功能检查', '肺结节门诊', '呼吸康复'],
          doctors: [
            { name: '白景初', title: '主任医师' },
            { name: '沈云舟', title: '副主任医师' }
          ]
        },
        {
          name: '消化内科',
          category: '非手术科室',
          tagline: '胃肠肝胆疾病、内镜评估和消化慢病管理。',
          desc: '提供胃炎、肠炎、肝功能异常、消化道出血风险评估和内镜预约指导。',
          icon: 'el-icon-receiving',
          gradient: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
          location: '门诊楼 4 层 C 区',
          time: '周一至周五 08:00-17:00',
          phone: '0571-8808-6404',
          services: ['胃肠镜预约', '肝病门诊', '营养评估'],
          doctors: [
            { name: '陆念青', title: '主任医师' },
            { name: '何星野', title: '主治医师' }
          ]
        },
        {
          name: '肾脏科',
          category: '非手术科室',
          tagline: '肾功能异常、尿检异常和透析前后连续管理。',
          desc: '为肾炎、肾病综合征、慢性肾病患者提供规范化诊疗和随访。',
          icon: 'el-icon-water-cup',
          gradient: 'linear-gradient(135deg, #fa709a 0%, #fee140 100%)',
          location: '门诊楼 5 层 A 区',
          time: '周一至周五 08:00-16:30',
          phone: '0571-8808-6505',
          services: ['慢性肾病门诊', '透析评估', '用药咨询'],
          doctors: [
            { name: '宋岚', title: '主任医师' },
            { name: '唐予安', title: '副主任医师' }
          ]
        },
        {
          name: '儿科',
          category: '非手术科室',
          tagline: '儿童常见病、成长发育评估和儿童专科随访。',
          desc: '覆盖发热咳嗽、消化问题、儿童保健、过敏与哮喘等儿童健康需求。',
          icon: 'el-icon-s-home',
          gradient: 'linear-gradient(135deg, #a8edea 0%, #fed6e3 100%)',
          location: '儿科门诊 2 层',
          time: '周一至周日 08:00-20:00',
          phone: '0571-8808-6606',
          services: ['儿童发热门诊', '生长发育', '儿童过敏'],
          doctors: [
            { name: '叶安宁', title: '主任医师' },
            { name: '夏听雨', title: '主治医师' }
          ]
        },
        {
          name: '普通外科',
          category: '手术科室',
          tagline: '腹部、甲状腺、乳腺及疝外科诊疗。',
          desc: '提供术前评估、日间手术预约、术后复查及伤口管理。',
          icon: 'el-icon-s-operation',
          gradient: 'linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%)',
          location: '外科门诊 2 层 A 区',
          time: '周一至周五 08:00-17:00',
          phone: '0571-8808-6707',
          services: ['日间手术', '术后换药', '微创评估'],
          doctors: [
            { name: '顾云川', title: '主任医师' },
            { name: '江澄', title: '副主任医师' }
          ]
        },
        {
          name: '骨科',
          category: '手术科室',
          tagline: '骨关节损伤、脊柱疾病和运动医学康复。',
          desc: '开展骨折、颈肩腰腿痛、关节退变和运动损伤综合评估。',
          icon: 'el-icon-guide',
          gradient: 'linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%)',
          location: '外科门诊 3 层 B 区',
          time: '周一至周六 08:00-17:00',
          phone: '0571-8808-6808',
          services: ['关节门诊', '脊柱门诊', '康复处方'],
          doctors: [
            { name: '秦牧', title: '主任医师' },
            { name: '闻澈', title: '主治医师' }
          ]
        },
        {
          name: '妇产科',
          category: '手术科室',
          tagline: '妇科疾病、围产保健和产后康复。',
          desc: '提供妇科常见病诊疗、孕产期管理、盆底康复和计划生育咨询。',
          icon: 'el-icon-s-female',
          gradient: 'linear-gradient(135deg, #a18cd1 0%, #fbc2eb 100%)',
          location: '妇产中心 2 层',
          time: '周一至周日 08:00-18:00',
          phone: '0571-8808-6909',
          services: ['围产保健', '妇科微创', '产后康复'],
          doctors: [
            { name: '黎若华', title: '主任医师' },
            { name: '苏青禾', title: '副主任医师' }
          ]
        },
        {
          name: '医学影像科',
          category: '诊断相关科室',
          tagline: 'CT、DR、MRI、超声检查和影像诊断报告。',
          desc: '支持检查预约、影像调阅、疑难影像会诊和报告在线查询。',
          icon: 'el-icon-picture-outline',
          gradient: 'linear-gradient(135deg, #89f7fe 0%, #66a6ff 100%)',
          location: '医技楼 1 层',
          time: '周一至周日 08:00-22:00',
          phone: '0571-8808-7001',
          services: ['CT 检查', 'MRI 检查', '影像会诊'],
          doctors: [
            { name: '宁以衡', title: '主任医师' },
            { name: '邵清越', title: '主治医师' }
          ]
        },
        {
          name: '检验医学科',
          category: '诊断相关科室',
          tagline: '临床检验、样本采集和检验报告解读。',
          desc: '提供血液、尿液、生化、免疫、微生物等检验项目和报告咨询。',
          icon: 'el-icon-files',
          gradient: 'linear-gradient(135deg, #fddb92 0%, #d1fdff 100%)',
          location: '医技楼 2 层',
          time: '周一至周日 07:30-17:30',
          phone: '0571-8808-7102',
          services: ['样本采集', '报告解读', '绿色通道'],
          doctors: [
            { name: '周澜', title: '主任技师' },
            { name: '林一诺', title: '主管技师' }
          ]
        },
        {
          name: '健康管理中心',
          category: '诊断相关科室',
          tagline: '体检套餐、健康评估和慢病风险管理。',
          desc: '面向个人、家庭和企事业单位提供体检、复查提醒和健康档案服务。',
          icon: 'el-icon-medal',
          gradient: 'linear-gradient(135deg, #96fbc4 0%, #f9f586 100%)',
          location: '健康管理楼 1 层',
          time: '周一至周六 07:30-12:00',
          phone: '0571-8808-7203',
          services: ['体检套餐', '风险评估', '复查提醒'],
          doctors: [
            { name: '温知夏', title: '主任医师' },
            { name: '施予白', title: '健康管理师' }
          ]
        }
      ]
    }
  },
  computed: {
    filteredList() {
      if (!this.activeCategory) return this.departments
      const categoryMap = {
        'non-surgery': '非手术科室',
        'surgery': '手术科室',
        'diagnostic': '诊断相关科室'
      }
      return this.departments.filter(dept => dept.category === categoryMap[this.activeCategory])
    }
  },
  methods: {
    filterDepartments() {},
    viewDetail(dept) {
      this.currentDept = dept
      this.detailVisible = true
    },
    goToRegister() {
      this.detailVisible = false
      this.$router.push('/patient/appointmentCreate')
    }
  }
}
</script>

<style lang="scss" scoped>
$primary: #075f42;
$primary-light: #20a978;

.department-intro {
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

.category-filter {
  margin-bottom: 24px;
  background: white;
  padding: 16px 20px;
  border-radius: 8px;
  border: 1px solid rgba(0, 122, 77, 0.08);
  box-shadow: 0 2px 12px rgba(8, 83, 61, 0.05);
}

.department-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
  gap: 20px;
}

.dept-card {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(0,0,0,0.06);
  cursor: pointer;
  transition: all 0.3s;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0,0,0,0.12);
  }
}

.dept-visual {
  height: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;

  .dept-icon {
    width: 70px;
    height: 70px;
    background: rgba(255, 255, 255, 0.2);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    backdrop-filter: blur(8px);

    i {
      font-size: 32px;
      color: white;
    }
  }

  .dept-badge {
    position: absolute;
    top: 12px;
    right: 12px;
    padding: 4px 10px;
    background: rgba(255, 255, 255, 0.25);
    border-radius: 12px;
    font-size: 11px;
    color: white;
    backdrop-filter: blur(4px);
  }
}

.dept-content {
  padding: 18px;

  h3 {
    font-size: 18px;
    color: #333;
    margin: 0 0 8px;
  }

  .dept-tagline {
    font-size: 13px;
    color: #666;
    margin: 0 0 12px;
    line-height: 1.5;
  }

  .dept-meta {
    display: flex;
    gap: 16px;
    margin-bottom: 12px;

    span {
      font-size: 12px;
      color: #999;
      display: flex;
      align-items: center;
      gap: 4px;

      i { color: $primary-light; }
    }
  }

  .dept-services {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
  }
}

.detail-content {
  .detail-header {
    display: flex;
    align-items: center;
    gap: 20px;
    padding: 24px;
    border-radius: 8px;
    margin-bottom: 20px;

    .detail-icon {
      width: 80px;
      height: 80px;
      background: rgba(255, 255, 255, 0.2);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;

      i {
        font-size: 40px;
        color: white;
      }
    }

    .detail-info {
      color: white;

      .detail-category {
        font-size: 12px;
        opacity: 0.8;
      }

      h3 {
        font-size: 24px;
        margin: 4px 0 8px;
      }

      p {
        margin: 0;
        opacity: 0.9;
        font-size: 14px;
      }
    }
  }

  .detail-meta {
    margin-bottom: 20px;

    i {
      color: $primary-light;
      margin-right: 4px;
    }
  }

  .detail-section {
    margin-bottom: 20px;

    h4 {
      font-size: 16px;
      color: $primary;
      margin: 0 0 12px;
      padding-bottom: 8px;
      border-bottom: 1px solid #eee;
    }

    p {
      color: #666;
      line-height: 1.8;
      margin: 0;
    }
  }

  .service-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }

  .doctor-list {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }

  .doctor-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px;
    background: #f8f9fa;
    border-radius: 8px;

    .doctor-avatar {
      width: 44px;
      height: 44px;
      background: linear-gradient(135deg, $primary, $primary-light);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;

      i {
        font-size: 20px;
        color: white;
      }
    }

    .doctor-info {
      display: flex;
      flex-direction: column;

      .doctor-name {
        font-size: 14px;
        font-weight: 600;
        color: #333;
      }

      .doctor-title {
        font-size: 12px;
        color: #999;
      }
    }
  }
}
</style>
