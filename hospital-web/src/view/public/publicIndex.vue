<template>
  <div class="public-page" id="top">
    <header class="header">
      <div class="header-container">
        <button class="logo" type="button" @click="scrollToSection('top')">
          <div class="logo-icon">
            <i class="el-icon-first-aid-kit"></i>
          </div>
          <div class="logo-text">
            <h1>云岚宗医院</h1>
            <p>YUNLANZONG MEDICAL CENTER</p>
          </div>
        </button>
        <nav class="nav-menu">
          <button class="nav-item active" type="button" @click="scrollToSection('top')">首页</button>
          <button class="nav-item" type="button" @click="scrollToSection('about')">医院概况</button>
          <button class="nav-item" type="button" @click="scrollToSection('departments')">科室导航</button>
          <button class="nav-item" type="button" @click="scrollToSection('guide')">就医指南</button>
          <button class="nav-item" type="button" @click="scrollToSection('news')">新闻动态</button>
        </nav>
        <div class="header-actions">
          <el-button class="register-btn" @click="goToRegister">预约挂号</el-button>
          <el-button type="primary" class="login-btn" @click="goToLogin">管理登录</el-button>
        </div>
      </div>
    </header>

    <section class="banner-section">
      <el-carousel height="500px" :interval="5000" arrow="hover">
        <el-carousel-item v-for="(item, index) in banners" :key="index">
          <div class="banner-item" :style="bannerStyle(item)">
            <div class="banner-content">
              <span>{{ item.kicker }}</span>
              <h2>{{ item.title }}</h2>
              <p>{{ item.desc }}</p>
              <el-button type="primary" class="banner-btn" @click="handleBannerAction(item)">
                {{ item.action }}
              </el-button>
            </div>
          </div>
        </el-carousel-item>
      </el-carousel>
    </section>

    <section class="quick-entry">
      <div class="entry-container">
        <button
          class="entry-item"
          v-for="(item, index) in quickEntries"
          :key="index"
          type="button"
          @click="handleEntry(item)"
        >
          <div class="entry-icon" :style="item.image ? null : { background: item.color }">
            <img v-if="item.image" :src="item.image" :alt="item.title">
            <i v-else :class="item.icon"></i>
          </div>
          <h3>{{ item.title }}</h3>
          <p>{{ item.desc }}</p>
        </button>
      </div>
    </section>

    <section class="about-section" id="about">
      <div class="section-container">
        <div class="section-header">
          <span>About</span>
          <h2>医院概况</h2>
          <div class="header-line"></div>
        </div>
        <div class="about-content">
          <div class="about-text">
            <p>云岚宗医院是一所虚构的现代化综合医疗中心，面向城市居民提供门诊、住院、影像、诊疗随访与健康管理服务。</p>
            <p>医院以智慧门诊和多学科协作为特色，建设了数字化预约、检查报告在线查询、诊疗记录归档等一体化服务流程。</p>
            <p>医院倡导“仁心云岚，生命至上”的服务理念，为患者提供稳定、温和且高效的就医体验。</p>
            <el-button type="primary" class="more-btn" @click="openHospitalIntro">了解更多</el-button>
          </div>
          <div class="about-visual">
            <img :src="aboutImages[0]" alt="云岚宗医院门诊环境">
            <img :src="aboutImages[1]" alt="云岚宗医院住院环境">
          </div>
          <div class="about-stats">
            <button class="stat-item" v-for="(stat, index) in stats" :key="index" type="button" @click="openStat(stat)">
              <div class="stat-number">{{ stat.number }}</div>
              <div class="stat-label">{{ stat.label }}</div>
            </button>
          </div>
        </div>
      </div>
    </section>

    <section class="departments-section" id="departments">
      <div class="section-container">
        <div class="section-header">
          <span>Departments</span>
          <h2>科室导航</h2>
          <div class="header-line"></div>
        </div>
        <div class="department-browser">
          <div class="department-hero" :style="departmentHeroStyle">
            <div class="department-hero-mask">
              <span>{{ selectedDepartment.category }}</span>
              <h3>{{ selectedDepartment.name }}</h3>
              <p>{{ selectedDepartment.tagline }}</p>
              <el-button class="hero-detail-btn" @click="openDepartmentDetail(selectedDepartment)">
                查看科室详情
              </el-button>
            </div>
          </div>
          <div class="department-panel">
            <div class="department-tabs">
              <button
                v-for="category in departmentCategories"
                :key="category"
                type="button"
                :class="['department-tab', { active: activeDeptCategory === category }]"
                @click="selectDepartmentCategory(category)"
              >
                {{ category }}
              </button>
            </div>
            <div class="department-list">
              <button
                v-for="dept in filteredDepartments"
                :key="dept.name"
                type="button"
                :class="['department-pill', { active: selectedDepartment.name === dept.name }]"
                @click="selectDepartment(dept)"
              >
                <i class="el-icon-arrow-left"></i>
                <span>{{ dept.name }}</span>
              </button>
            </div>
            <div class="department-actions">
              <button type="button" @click="goToRegister">
                <i class="el-icon-user"></i>
                <span>预约挂号</span>
              </button>
              <button type="button" @click="openDepartmentDetail(selectedDepartment)">
                <i class="el-icon-document"></i>
                <span>出诊信息</span>
              </button>
              <button type="button" @click="openLocation(selectedDepartment)">
                <i class="el-icon-location-outline"></i>
                <span>科室位置</span>
              </button>
            </div>
          </div>
        </div>
        <div class="departments-grid">
          <button
            class="department-card"
            v-for="dept in departments.slice(0, 6)"
            :key="dept.name"
            type="button"
            @click="openDepartmentDetail(dept)"
          >
            <div class="dept-icon">
              <i :class="dept.icon"></i>
            </div>
            <h3>{{ dept.name }}</h3>
            <p>{{ dept.desc }}</p>
            <span class="detail-btn">查看详情 <i class="el-icon-arrow-right"></i></span>
          </button>
        </div>
      </div>
    </section>

    <section class="guide-section" id="guide">
      <div class="section-container">
        <div class="section-header">
          <span>Guide</span>
          <h2>就医指南</h2>
          <div class="header-line"></div>
        </div>
        <div class="guide-tabs">
          <button
            v-for="guide in guideTabs"
            :key="guide.key"
            type="button"
            :class="['guide-tab', { active: activeGuide === guide.key }]"
            @click="activeGuide = guide.key"
          >
            {{ guide.title }}
          </button>
        </div>
        <div class="guide-layout">
          <aside class="guide-sidebar">
            <div class="guide-menu">
              <button
                v-for="article in activeGuideData.articles"
                :key="article.title"
                type="button"
                @click="openGuideArticle(article)"
              >
                <span>{{ article.title }}</span>
                <i class="el-icon-arrow-right"></i>
              </button>
            </div>
            <div class="guide-query">
              <h3>出诊信息查询</h3>
              <el-input v-model="guideQuery.disease" placeholder="疾病名称"></el-input>
              <el-input v-model="guideQuery.department" placeholder="科室名称"></el-input>
              <el-input v-model="guideQuery.doctor" placeholder="医生名称"></el-input>
              <el-button type="primary" @click="queryGuide">选好了，去查询</el-button>
            </div>
          </aside>
          <article class="guide-detail">
            <div class="guide-ruler"></div>
            <span class="guide-kicker">{{ activeGuideData.kicker }}</span>
            <h3>{{ activeGuideData.title }}</h3>
            <p>{{ activeGuideData.summary }}</p>
            <div class="guide-sections">
              <button
                v-for="section in activeGuideData.sections"
                :key="section.title"
                type="button"
                class="guide-section-card"
                @click="openGuideArticle(section)"
              >
                <i :class="section.icon"></i>
                <div>
                  <h4>{{ section.title }}</h4>
                  <p>{{ section.desc }}</p>
                </div>
              </button>
            </div>
          </article>
        </div>
      </div>
    </section>

    <section class="news-section" id="news">
      <div class="section-container">
        <div class="section-header">
          <span>News</span>
          <h2>新闻动态</h2>
          <div class="header-line"></div>
        </div>
        <div class="news-cards">
          <article class="news-card" v-for="group in newsGroups" :key="group.title">
            <button class="news-cover" type="button" @click="openNewsGroup(group)">
              <img :src="group.image" :alt="group.title">
            </button>
            <div class="news-card-body">
              <div class="news-card-title">
                <h3>{{ group.title }}</h3>
                <el-button size="mini" @click="openNewsGroup(group)">查看更多</el-button>
              </div>
              <button
                class="news-line"
                v-for="item in group.items"
                :key="item.title"
                type="button"
                @click="openNewsDetail(item)"
              >
                <span>{{ item.title }}</span>
                <small>{{ item.date }}</small>
              </button>
            </div>
          </article>
        </div>
      </div>
    </section>

    <div class="floating-tools">
      <button v-for="tool in floatingTools" :key="tool.title" type="button" @click="handleFloatingTool(tool)">
        <i :class="tool.icon"></i>
        <span>{{ tool.title }}</span>
      </button>
    </div>

    <footer class="footer">
      <div class="footer-container">
        <div class="footer-main">
          <button class="footer-logo" type="button" @click="scrollToSection('top')">
            <div class="logo-icon">
              <i class="el-icon-first-aid-kit"></i>
            </div>
            <h3>云岚宗医院</h3>
            <p>YUNLANZONG MEDICAL CENTER</p>
          </button>
          <div class="footer-links">
            <div class="link-group">
              <h4>快速链接</h4>
              <button type="button" @click="goToRegister">预约挂号</button>
              <button type="button" @click="goToLogin">报告查询</button>
              <button type="button" @click="scrollToSection('departments')">专家介绍</button>
              <button type="button" @click="scrollToSection('departments')">科室导航</button>
            </div>
            <div class="link-group">
              <h4>联系我们</h4>
              <button type="button" @click="openContact('address')">
                <i class="el-icon-location"></i> 云岚市青澜区云岚宗大道88号
              </button>
              <button type="button" @click="openContact('phone')">
                <i class="el-icon-phone"></i> 0571-8808-6677
              </button>
              <button type="button" @click="openContact('mail')">
                <i class="el-icon-message"></i> service@yunlanzong.example
              </button>
            </div>
          </div>
        </div>
        <div class="footer-bottom">
          <p>© 2024 云岚宗医院 版权所有 | 云ICP备20241208号</p>
        </div>
      </div>
    </footer>

    <el-dialog :visible.sync="detailDialog.visible" :title="detailDialog.title" width="760px" class="public-dialog">
      <div v-if="detailDialog.type === 'department'" class="dialog-section">
        <p class="dialog-lead">{{ detailDialog.payload.desc }}</p>
        <div class="dialog-meta">
          <span><i class="el-icon-location-outline"></i>{{ detailDialog.payload.location }}</span>
          <span><i class="el-icon-time"></i>{{ detailDialog.payload.time }}</span>
          <span><i class="el-icon-phone-outline"></i>{{ detailDialog.payload.phone }}</span>
        </div>
        <h4>特色诊疗</h4>
        <div class="tag-row">
          <el-tag v-for="service in detailDialog.payload.services" :key="service" type="success">
            {{ service }}
          </el-tag>
        </div>
        <h4>推荐医生</h4>
        <div class="doctor-row">
          <div v-for="doctor in detailDialog.payload.doctors" :key="doctor.name">
            <strong>{{ doctor.name }}</strong>
            <span>{{ doctor.title }}</span>
          </div>
        </div>
      </div>
      <div v-else-if="detailDialog.type === 'guide'" class="dialog-section">
        <p class="dialog-lead">{{ detailDialog.payload.desc }}</p>
        <ul>
          <li v-for="item in detailDialog.payload.details" :key="item">{{ item }}</li>
        </ul>
      </div>
      <div v-else-if="detailDialog.type === 'news'" class="dialog-section">
        <p class="dialog-lead">{{ detailDialog.payload.desc }}</p>
        <ul>
          <li v-for="item in detailDialog.payload.details" :key="item">{{ item }}</li>
        </ul>
      </div>
      <div v-else class="dialog-section">
        <p class="dialog-lead">{{ detailDialog.payload.desc }}</p>
        <ul>
          <li v-for="item in detailDialog.payload.details" :key="item">{{ item }}</li>
        </ul>
      </div>
      <span slot="footer" class="dialog-footer">
        <el-button @click="detailDialog.visible = false">关闭</el-button>
        <el-button type="primary" @click="dialogPrimaryAction">继续办理</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
const hospitalHero = require('../../../../医院背景图.png')
const entryPatient = require('../../../../小图标1.png')
const entryRegister = require('../../../../小图标2.png')
const entryDepartment = require('../../../../小图标3.png')
const entryImage = require('../../../../小图标4.png')
const entryStaff = require('../../../../小图标5.png')
const entryInternational = require('../../../../小图标6.png')
const hallwayImage = require('@/assets/hospital3.jpg')
const wardImage = require('@/assets/hospital5.jpg')

export default {
  name: 'publicIndex',
  data() {
    const departments = [
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

    return {
      banners: [
        {
          kicker: '仁心云岚 生命至上',
          title: '云岚宗医院',
          desc: '面向未来的智慧医疗与温暖照护中心',
          action: '进入患者服务',
          image: hospitalHero,
          route: '/login',
          bg: 'linear-gradient(90deg, rgba(0, 72, 51, 0.88), rgba(0, 132, 94, 0.32))'
        },
        {
          kicker: '门诊 住院 影像 随访',
          title: '一站式就医服务',
          desc: '预约、签到、检查、报告查询全流程协同',
          action: '查看就医指南',
          image: hallwayImage,
          target: 'guide',
          bg: 'linear-gradient(90deg, rgba(12, 78, 103, 0.86), rgba(12, 133, 157, 0.38))'
        },
        {
          kicker: '专科协同 精准诊断',
          title: '智慧诊疗中心',
          desc: '多学科团队协作，让诊疗路径更清晰',
          action: '了解科室导航',
          image: wardImage,
          target: 'departments',
          bg: 'linear-gradient(90deg, rgba(7, 90, 72, 0.84), rgba(36, 166, 119, 0.36))'
        }
      ],
      aboutImages: [hallwayImage, wardImage],
      quickEntries: [
        { title: '患者版', desc: '预约挂号、报告查询', icon: 'el-icon-date', image: entryPatient, route: '/login', color: '#2980b9' },
        { title: '预约挂号', desc: '按科室和专家快速预约', icon: 'el-icon-user', image: entryRegister, route: '/login', color: '#27ae60' },
        { title: '科室导航', desc: '科室信息和位置查询', icon: 'el-icon-guide', image: entryDepartment, target: 'departments', color: '#c18f2e' },
        { title: '医技影像', desc: '检查片子与诊断报告', icon: 'el-icon-document', image: entryImage, route: '/login', color: '#7d67b8' },
        { title: '员工入口', desc: '院内业务协同处理', icon: 'el-icon-question', image: entryStaff, route: '/login', color: '#ba4a3d' },
        { title: '就医指南', desc: '须知、医保、位置服务', icon: 'el-icon-first-aid-kit', image: entryInternational, target: 'guide', color: '#1f8e86' }
      ],
      stats: [
        { number: '18+', label: '重点专科', desc: '覆盖内科、外科、妇产、儿科、医技等重点专科方向。' },
        { number: '120万', label: '年服务人次', desc: '虚拟演示数据，用于展示医院综合服务能力。' },
        { number: '1800+', label: '医护人员', desc: '多学科医生、护理、医技和行政协同团队。' },
        { number: '36+', label: '临床科室', desc: '门诊、住院、检查、随访全流程联动。' }
      ],
      departments,
      departmentCategories: ['非手术科室', '手术科室', '诊断相关科室', '更多科室介绍'],
      activeDeptCategory: '非手术科室',
      selectedDepartment: departments[0],
      guideTabs: [
        {
          key: 'notice',
          title: '就医须知',
          kicker: '实名就诊',
          summary: '为保护患者权益、维护医院正常医疗秩序，请各位患者及家属自觉遵守实名制就诊管理规定。',
          articles: [
            { title: '门诊患者就诊须知', desc: '实名预约、签到、候诊和复诊注意事项。', details: ['携带身份证、医保卡或电子凭证。', '按预约时段提前 30 分钟到院签到。', '请勿冒用他人身份信息挂号就诊。'] },
            { title: '预约采血须知', desc: '采血时间、空腹要求和报告查看方式。', details: ['常规采血建议 07:30-10:30 完成。', '需空腹项目请前一晚 22:00 后避免进食。', '报告可在患者端或自助机查询。'] },
            { title: '门诊就诊流程', desc: '预约、签到、候诊、检查、缴费、取药。', details: ['线上预约或现场挂号。', '到院后完成签到并等待叫号。', '根据医嘱完成检查检验和复诊。'] }
          ],
          sections: [
            { title: '门诊出诊表', desc: '查看各科室近期出诊安排。', icon: 'el-icon-date', details: ['支持按科室、医生和日期筛选。', '临时停诊以当天系统提示为准。'] },
            { title: '就医流程', desc: '从预约到取药的完整说明。', icon: 'el-icon-notebook-2', details: ['预约挂号。', '就诊签到。', '候诊就医。', '检查检验。', '缴费取药。'] },
            { title: '位置及服务时间', desc: '院区楼宇、门诊和医技服务时间。', icon: 'el-icon-location-outline', details: ['门诊服务 08:00-17:00。', '急诊 24 小时开放。', '医技检查按预约时段到达。'] },
            { title: '专科专病', desc: '按疾病和专科找到合适门诊。', icon: 'el-icon-search', details: ['慢病管理门诊。', '肺结节门诊。', '心衰门诊。', '产后康复门诊。'] }
          ]
        },
        {
          key: 'insurance',
          title: '医保指南',
          kicker: '医保结算',
          summary: '支持医保电子凭证、实体医保卡和自费结算，特殊药品及异地医保请提前完成备案确认。',
          articles: [
            { title: '医保患者结算说明', desc: '医保凭证、结算窗口和线上支付说明。', details: ['支持医保电子凭证扫码。', '异地医保请确认备案状态。', '特殊病种按政策完成登记。'] },
            { title: '门诊慢病报销提示', desc: '慢病处方、复诊和报销材料提示。', details: ['复诊时携带既往病历和检查报告。', '处方天数按医保政策执行。', '报销比例以当地政策为准。'] }
          ],
          sections: [
            { title: '医保凭证', desc: '电子凭证与实体卡均可使用。', icon: 'el-icon-bank-card', details: ['请提前激活医保电子凭证。', '儿童医保可由监护人协助绑定。'] },
            { title: '异地就医', desc: '备案后按政策直接结算。', icon: 'el-icon-position', details: ['就诊前确认备案城市。', '急诊备案按当地规则补办。'] },
            { title: '费用清单', desc: '支持窗口、自助机和线上查询。', icon: 'el-icon-tickets', details: ['可查询门诊清单。', '住院清单由病区或结算窗口提供。'] }
          ]
        },
        {
          key: 'location',
          title: '医院位置及服务时间',
          kicker: '到院服务',
          summary: '医院位于云岚市青澜区云岚宗大道88号，门诊、医技、住院和急诊区域分区清晰。',
          articles: [
            { title: '院区交通指南', desc: '公交、地铁、停车和网约车落客点。', details: ['地铁青澜湖站 A 口步行约 8 分钟。', 'P1 停车场靠近门诊楼。', '急诊落客点位于东门。'] },
            { title: '服务时间汇总', desc: '门诊、急诊、检验和药房服务时间。', details: ['门诊 08:00-17:00。', '急诊 24 小时开放。', '门诊药房 08:00-18:00。'] }
          ],
          sections: [
            { title: '门诊楼', desc: '挂号、候诊、缴费、药房。', icon: 'el-icon-office-building', details: ['1 层综合服务中心。', '2-5 层各专科门诊。'] },
            { title: '医技楼', desc: '影像、检验、超声、心电。', icon: 'el-icon-camera', details: ['影像科 1 层。', '检验医学科 2 层。'] },
            { title: '急诊中心', desc: '24 小时急诊与抢救服务。', icon: 'el-icon-alarm-clock', details: ['急诊入口位于东门。', '危急重症请直接前往急诊分诊台。'] }
          ]
        },
        {
          key: 'service',
          title: '查询服务',
          kicker: '便民查询',
          summary: '提供出诊、报告、价格、院内导航和健康科普等便民查询入口。',
          articles: [
            { title: '报告查询说明', desc: '影像和检验报告查询入口说明。', details: ['登录患者端后可查看报告。', '部分报告需医生审核后发布。', '历史报告按就诊日期归档。'] },
            { title: '价格公示', desc: '检查、检验、治疗项目价格查询。', details: ['价格仅作演示。', '最终以院内结算系统为准。'] }
          ],
          sections: [
            { title: '报告查询', desc: '登录患者端查看检查报告。', icon: 'el-icon-document-checked', details: ['支持检验报告。', '支持影像诊断报告。'] },
            { title: '院内导航', desc: '按楼宇和科室定位服务点。', icon: 'el-icon-map-location', details: ['科室位置。', '检查地点。', '药房和收费窗口。'] },
            { title: '健康科普', desc: '阅读常见疾病和健康管理内容。', icon: 'el-icon-reading', details: ['慢病管理。', '用药安全。', '复查提醒。'] }
          ]
        }
      ],
      activeGuide: 'notice',
      guideQuery: {
        disease: '',
        department: '',
        doctor: ''
      },
      newsGroups: [
        {
          title: '医院公告',
          image: hospitalHero,
          items: [
            { title: '云岚宗医院门诊服务时间优化公告', date: '12-15', desc: '门诊服务窗口和自助服务时间调整，方便患者错峰就医。', details: ['门诊服务延长至 17:30。', '自助机支持预约签到和报告查询。', '急诊服务不受影响。'] },
            { title: '冬季呼吸道疾病就诊提示', date: '12-10', desc: '请患者根据症状选择普通门诊、发热门诊或急诊通道。', details: ['轻症患者建议预约就诊。', '高热、呼吸困难请及时急诊。', '就诊时佩戴口罩。'] },
            { title: '检验报告线上查询功能开放', date: '12-05', desc: '登录患者端后可按就诊记录查看检验报告。', details: ['支持按日期筛选。', '异常指标以医生解释为准。'] }
          ]
        },
        {
          title: '重大新闻',
          image: hallwayImage,
          items: [
            { title: '智慧影像诊断流程完成院内联调', date: '12-12', desc: '影像查看、诊断报告填写和上传流程已完成演示闭环。', details: ['医生可查看患者检查片子。', '可填写并上传诊断报告。', '报告与患者影像记录自动关联。'] },
            { title: '多学科联合门诊试运行', date: '12-08', desc: '围绕慢病、呼吸、心血管和康复建立联合诊疗路径。', details: ['减少患者多次往返。', '提高疑难病例会诊效率。'] },
            { title: '院内自助服务终端升级', date: '12-02', desc: '新增预约签到、缴费、报告查询和路线指引。', details: ['门诊大厅新增 6 台终端。', '支持身份证和医保电子凭证。'] }
          ]
        },
        {
          title: '健康科普',
          image: wardImage,
          items: [
            { title: '冬季血压管理：规律监测更重要', date: '12-13', desc: '天气变化可能影响血压波动，请遵医嘱规律监测和用药。', details: ['固定时间测量血压。', '避免自行停药或换药。', '出现胸痛、气短请及时就医。'] },
            { title: '肺部检查报告如何看', date: '12-09', desc: '影像报告需要结合症状、既往病史和医生判断。', details: ['报告结论不等同最终诊断。', '复查时间听从医生建议。'] },
            { title: '儿童发热家庭护理提示', date: '12-01', desc: '关注精神状态、饮水量和体温变化，必要时及时就诊。', details: ['不建议重复叠加退热药。', '小月龄婴儿发热请尽快就医。'] }
          ]
        }
      ],
      floatingTools: [
        { title: '预约记录', icon: 'el-icon-time', route: '/login' },
        { title: '报告查询', icon: 'el-icon-document-checked', route: '/login' },
        { title: '科室导航', icon: 'el-icon-office-building', target: 'departments' },
        { title: '就医指南', icon: 'el-icon-notebook-2', target: 'guide' },
        { title: '返回顶部', icon: 'el-icon-top', target: 'top' }
      ],
      detailDialog: {
        visible: false,
        type: '',
        title: '',
        payload: {
          desc: '',
          details: []
        }
      }
    }
  },
  computed: {
    filteredDepartments() {
      if (this.activeDeptCategory === '更多科室介绍') {
        return this.departments
      }
      return this.departments.filter(item => item.category === this.activeDeptCategory)
    },
    activeGuideData() {
      return this.guideTabs.find(item => item.key === this.activeGuide) || this.guideTabs[0]
    },
    departmentHeroStyle() {
      return {
        background: this.selectedDepartment.gradient
      }
    }
  },
  mounted() {
    const section = this.$route.query && this.$route.query.section
    if (section) {
      this.$nextTick(() => {
        setTimeout(() => this.scrollToSection(section), 120)
      })
    }
  },
  methods: {
    bannerStyle(item) {
      return {
        backgroundImage: `${item.bg}, url(${item.image})`
      }
    },
    scrollToSection(id) {
      if (id === 'top') {
        window.scrollTo({ top: 0, behavior: 'smooth' })
        return
      }
      const el = document.getElementById(id)
      if (el) {
        el.scrollIntoView({ behavior: 'smooth', block: 'start' })
      }
    },
    goToLogin() {
      this.$router.push('/login')
    },
    goToRegister() {
      this.$router.push('/login')
    },
    handleBannerAction(item) {
      if (item.route) {
        this.$router.push(item.route)
        return
      }
      if (item.target) {
        this.scrollToSection(item.target)
      }
    },
    handleEntry(item) {
      if (item.route) {
        this.$router.push(item.route)
        return
      }
      if (item.target) {
        this.scrollToSection(item.target)
      }
    },
    selectDepartmentCategory(category) {
      this.activeDeptCategory = category
      const first = this.filteredDepartments[0]
      if (first) {
        this.selectedDepartment = first
      }
    },
    selectDepartment(dept) {
      this.selectedDepartment = dept
    },
    openDepartmentDetail(dept) {
      this.selectedDepartment = dept
      this.detailDialog = {
        visible: true,
        type: 'department',
        title: `${dept.name}详情`,
        payload: dept
      }
    },
    openLocation(dept) {
      this.detailDialog = {
        visible: true,
        type: 'guide',
        title: `${dept.name}位置`,
        payload: {
          desc: `${dept.name}位于${dept.location}，服务时间为${dept.time}。`,
          details: ['建议按预约时间提前 30 分钟到院。', '到院后可通过自助机或服务台完成签到。', `咨询电话：${dept.phone}`]
        }
      }
    },
    openGuideArticle(article) {
      this.detailDialog = {
        visible: true,
        type: 'guide',
        title: article.title,
        payload: {
          desc: article.desc,
          details: article.details || []
        }
      }
    },
    queryGuide() {
      const fields = [this.guideQuery.disease, this.guideQuery.department, this.guideQuery.doctor].filter(Boolean)
      if (fields.length) {
        this.$message.success(`已根据“${fields.join(' / ')}”生成查询入口，请登录后查看实时出诊信息。`)
        return
      }
      this.$message.info('请输入疾病、科室或医生名称后再查询。')
    },
    openNewsGroup(group) {
      this.detailDialog = {
        visible: true,
        type: 'news',
        title: group.title,
        payload: {
          desc: `这里汇总展示“${group.title}”栏目近期内容。`,
          details: group.items.map(item => `${item.date}  ${item.title}`)
        }
      }
    },
    openNewsDetail(news) {
      this.detailDialog = {
        visible: true,
        type: 'news',
        title: news.title,
        payload: news
      }
    },
    openHospitalIntro() {
      this.detailDialog = {
        visible: true,
        type: 'intro',
        title: '云岚宗医院概况',
        payload: {
          desc: '云岚宗医院以智慧门诊、影像协同、诊疗随访和健康管理为核心，面向患者提供一站式就医服务。',
          details: ['门诊、住院、医技、药房和随访流程在线协同。', '医生可基于患者检查片子填写并上传诊断报告。', '患者端支持预约、报告查询和就诊记录查看。']
        }
      }
    },
    openStat(stat) {
      this.detailDialog = {
        visible: true,
        type: 'intro',
        title: stat.label,
        payload: {
          desc: stat.desc,
          details: ['此处为演示站点数据，用于完善前台展示效果。', '真实项目可接入后端统计接口进行动态展示。']
        }
      }
    },
    handleFloatingTool(tool) {
      if (tool.route) {
        this.$router.push(tool.route)
        return
      }
      this.scrollToSection(tool.target)
    },
    openContact(type) {
      const messages = {
        address: '地址已定位：云岚市青澜区云岚宗大道88号。',
        phone: '咨询电话：0571-8808-6677。',
        mail: '服务邮箱：service@yunlanzong.example。'
      }
      this.$message.info(messages[type])
    },
    dialogPrimaryAction() {
      if (this.detailDialog.type === 'department') {
        this.goToRegister()
        return
      }
      this.detailDialog.visible = false
      this.goToRegister()
    }
  }
}
</script>

<style lang="scss" scoped>
.public-page {
  min-height: 100vh;
  background: #f4f8f6;
  color: #24312d;
}

button {
  font-family: inherit;
}

.header {
  background: rgba(255, 255, 255, 0.96);
  box-shadow: 0 2px 14px rgba(0, 55, 42, 0.10);
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
}

.header-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 30px;
  height: 80px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
}

.logo,
.footer-logo {
  border: 0;
  background: transparent;
  display: flex;
  align-items: center;
  cursor: pointer;
  text-align: left;
}

.logo-icon {
  width: 50px;
  height: 50px;
  background: linear-gradient(135deg, #006d47, #1da272);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 14px;

  i {
    color: white;
    font-size: 24px;
  }
}

.logo-text {
  h1 {
    font-size: 22px;
    color: #075f42;
    margin: 0;
    font-weight: 600;
    letter-spacing: 0;
  }

  p {
    font-size: 10px;
    color: #60726b;
    margin: 0;
    letter-spacing: 0;
  }
}

.nav-menu {
  display: flex;
  gap: 28px;
  align-items: center;
  white-space: nowrap;

  .nav-item {
    border: 0;
    background: transparent;
    color: #26342f;
    font-size: 16px;
    cursor: pointer;
    transition: color 0.2s;
    position: relative;
    padding: 8px 0;

    &:hover,
    &.active {
      color: #007a4d;

      &::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        height: 2px;
        background: #007a4d;
      }
    }
  }
}

.header-actions {
  display: flex;
  gap: 10px;
  white-space: nowrap;
}

.login-btn {
  background: linear-gradient(135deg, #007a4d, #20a978);
  border: none;
  padding: 10px 24px;

  &:hover {
    background: linear-gradient(135deg, #06643f, #159464);
  }
}

.register-btn {
  border: 1px solid #007a4d;
  color: #007a4d;
  padding: 10px 24px;

  &:hover {
    background: #007a4d;
    color: white;
  }
}

.banner-section {
  margin-top: 80px;
}

.banner-item {
  height: 500px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-size: cover;
  background-position: center;
}

.banner-content {
  width: min(1180px, calc(100% - 60px));
  text-align: left;
  color: white;
  text-shadow: 0 2px 12px rgba(0, 0, 0, 0.28);

  span {
    display: inline-flex;
    padding: 7px 16px;
    border-radius: 999px;
    background: rgba(255, 255, 255, 0.18);
    border: 1px solid rgba(255, 255, 255, 0.38);
    font-size: 14px;
    margin-bottom: 18px;
  }

  h2 {
    font-size: 52px;
    margin: 0 0 20px;
    font-weight: 600;
    letter-spacing: 0;
  }

  p {
    font-size: 20px;
    margin: 0 0 30px;
    opacity: 0.92;
  }
}

.banner-btn {
  padding: 15px 36px;
  font-size: 16px;
  background: rgba(255, 255, 255, 0.18);
  border: 2px solid white;
  border-radius: 24px;

  &:hover {
    background: white;
    color: #007a4d;
  }
}

.quick-entry {
  position: relative;
  z-index: 2;
  margin-top: -58px;
  padding: 0 0 58px;
  background: linear-gradient(180deg, rgba(244, 248, 246, 0), #f4f8f6 44px);
}

.entry-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 30px;
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 18px;
}

.entry-item {
  text-align: center;
  padding: 24px 16px 22px;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.94);
  border: 1px solid rgba(0, 122, 77, 0.12);
  box-shadow: 0 14px 34px rgba(8, 83, 61, 0.12);
  transition: all 0.2s;
  cursor: pointer;

  &:hover {
    transform: translateY(-5px);
    box-shadow: 0 18px 36px rgba(8, 83, 61, 0.16);
  }

  h3 {
    font-size: 18px;
    color: #26342f;
    margin: 14px 0 8px;
  }

  p {
    font-size: 14px;
    color: #60726b;
    margin: 0;
  }
}

.entry-icon {
  width: 76px;
  height: 76px;
  border-radius: 8px;
  background: linear-gradient(135deg, rgba(0, 122, 77, 0.10), rgba(32, 169, 120, 0.18));
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
  overflow: hidden;

  i {
    font-size: 34px;
    color: white;
  }

  img {
    width: 60px;
    height: 60px;
    object-fit: contain;
  }
}

.section-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 30px;
}

.section-header {
  text-align: center;
  margin-bottom: 42px;

  span {
    color: #8d6b1f;
    font-size: 13px;
    font-weight: 600;
  }

  h2 {
    font-size: 32px;
    color: #075f42;
    margin: 8px 0 14px;
    font-weight: 600;
    letter-spacing: 0;
  }

  .header-line {
    width: 60px;
    height: 3px;
    background: linear-gradient(135deg, #007a4d, #20a978);
    margin: 0 auto;
  }
}

.about-section,
.guide-section {
  padding: 80px 0;
  background: linear-gradient(135deg, #f6faf8, #eaf4ef);
}

.about-content {
  display: grid;
  grid-template-columns: 1.05fr 0.95fr 0.9fr;
  gap: 36px;
  align-items: center;
}

.about-text {
  p {
    font-size: 16px;
    line-height: 1.8;
    color: #4d625a;
    margin-bottom: 20px;
  }
}

.more-btn {
  margin-top: 18px;
  padding: 12px 30px;
  background: linear-gradient(135deg, #007a4d, #20a978);
  border: none;

  &:hover {
    background: linear-gradient(135deg, #06643f, #159464);
  }
}

.about-visual {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;

  img {
    width: 100%;
    height: 240px;
    object-fit: cover;
    border-radius: 8px;
    box-shadow: 0 14px 30px rgba(8, 83, 61, 0.16);
  }

  img:first-child {
    margin-top: 34px;
  }
}

.about-stats {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.stat-item {
  background: white;
  padding: 28px;
  border-radius: 8px;
  border: 1px solid rgba(0, 122, 77, 0.10);
  text-align: center;
  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.05);
  cursor: pointer;

  &:hover {
    border-color: rgba(0, 122, 77, 0.35);
  }

  .stat-number {
    font-size: 34px;
    font-weight: 600;
    color: #007a4d;
    margin-bottom: 10px;
  }

  .stat-label {
    font-size: 14px;
    color: #60726b;
  }
}

.departments-section,
.news-section {
  padding: 80px 0;
  background: white;
}

.department-browser {
  display: grid;
  grid-template-columns: 0.95fr 1.35fr;
  gap: 28px;
  align-items: stretch;
  margin-bottom: 32px;
}

.department-hero {
  min-height: 360px;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 18px 38px rgba(8, 83, 61, 0.16);
}

.department-hero-mask {
  height: 100%;
  padding: 34px;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  color: white;
  background: linear-gradient(180deg, rgba(0, 0, 0, 0.05), rgba(0, 52, 38, 0.76));

  span {
    font-size: 14px;
    opacity: 0.9;
  }

  h3 {
    font-size: 30px;
    margin: 10px 0 12px;
    letter-spacing: 0;
  }

  p {
    margin: 0 0 18px;
    line-height: 1.7;
  }
}

.hero-detail-btn {
  width: 138px;
  color: #075f42;
  border: 0;
}

.department-panel {
  padding: 8px 0 0;
}

.department-tabs {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
  margin-bottom: 16px;
}

.department-tab {
  height: 48px;
  border: 0;
  border-radius: 6px;
  color: white;
  background: #54a5a4;
  font-size: 16px;
  cursor: pointer;
  position: relative;

  &:nth-child(1) {
    background: #4f96bf;
  }

  &:nth-child(3) {
    background: #d9b86b;
  }

  &:nth-child(4) {
    background: #008342;
  }

  &.active::after {
    content: '';
    position: absolute;
    left: 50%;
    transform: translateX(-50%);
    bottom: -8px;
    border-left: 9px solid transparent;
    border-right: 9px solid transparent;
    border-top: 9px solid currentColor;
    color: inherit;
  }
}

.department-list {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 12px 14px;
  margin-bottom: 24px;
}

.department-pill {
  height: 40px;
  display: flex;
  align-items: center;
  gap: 8px;
  border: 1px solid #d9e0dd;
  background: #fff;
  border-radius: 5px;
  color: #26342f;
  padding: 0 12px;
  cursor: pointer;
  min-width: 0;

  span {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  i {
    color: #8d9a95;
  }

  &:hover,
  &.active {
    border-color: #007a4d;
    color: #007a4d;
    background: #f0faf5;
  }
}

.department-actions {
  border-top: 1px solid #dce6e2;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  padding-top: 24px;
  gap: 18px;

  button {
    border: 0;
    background: transparent;
    cursor: pointer;
    color: #26342f;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;

    i {
      font-size: 42px;
      color: #4b5652;
    }

    &:hover {
      color: #007a4d;

      i {
        color: #007a4d;
      }
    }
  }
}

.departments-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.department-card {
  background: #f8fbfa;
  padding: 34px 26px;
  border-radius: 8px;
  border: 1px solid rgba(0, 122, 77, 0.10);
  text-align: center;
  transition: all 0.2s;
  cursor: pointer;

  &:hover {
    background: linear-gradient(135deg, #007a4d, #20a978);
    transform: translateY(-5px);

    .dept-icon i,
    h3,
    p,
    .detail-btn {
      color: white;
    }
  }

  .dept-icon {
    margin-bottom: 18px;

    i {
      font-size: 44px;
      color: #007a4d;
      transition: color 0.2s;
    }
  }

  h3 {
    font-size: 20px;
    color: #26342f;
    margin: 0 0 10px;
    transition: color 0.2s;
  }

  p {
    min-height: 44px;
    font-size: 14px;
    color: #60726b;
    margin: 0 0 18px;
    line-height: 1.6;
    transition: color 0.2s;
  }

  .detail-btn {
    color: #007a4d;
    font-size: 14px;
    transition: color 0.2s;
  }
}

.guide-tabs {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 26px;
}

.guide-tab {
  height: 44px;
  border-radius: 6px;
  border: 1px solid #d8e1dd;
  background: white;
  color: #26342f;
  font-size: 15px;
  cursor: pointer;

  &:hover,
  &.active {
    background: #007a4d;
    color: white;
    border-color: #007a4d;
  }
}

.guide-layout {
  display: grid;
  grid-template-columns: 340px 1fr;
  gap: 24px;
}

.guide-sidebar,
.guide-detail {
  background: white;
  border-radius: 8px;
  box-shadow: 0 12px 28px rgba(8, 83, 61, 0.11);
}

.guide-sidebar {
  padding: 20px;
}

.guide-menu {
  max-height: 260px;
  overflow: auto;
  padding-right: 6px;

  button {
    width: 100%;
    min-height: 42px;
    border: 0;
    border-bottom: 1px solid #edf2ef;
    background: white;
    color: #26342f;
    display: flex;
    align-items: center;
    justify-content: space-between;
    text-align: left;
    cursor: pointer;

    &:hover {
      color: #007a4d;
    }
  }
}

.guide-query {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #edf2ef;

  h3 {
    font-size: 18px;
    margin: 0 0 16px;
    color: #26342f;
  }

  .el-input {
    margin-bottom: 10px;
  }

  .el-button {
    width: 100%;
    background: #007a4d;
    border-color: #007a4d;
  }
}

.guide-detail {
  padding: 30px;
  min-height: 420px;
}

.guide-ruler {
  height: 18px;
  margin-bottom: 22px;
  background-image: repeating-linear-gradient(90deg, rgba(0, 122, 77, 0.35) 0 1px, transparent 1px 9px);
}

.guide-kicker {
  display: inline-flex;
  align-items: center;
  padding: 9px 18px;
  color: white;
  background: #075f42;
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 22px;
}

.guide-detail h3 {
  font-size: 22px;
  color: #26342f;
  margin: 0 0 16px;
}

.guide-detail > p {
  color: #34433e;
  line-height: 1.9;
  font-size: 16px;
  margin: 0 0 24px;
}

.guide-sections {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 14px;
}

.guide-section-card {
  display: flex;
  gap: 14px;
  align-items: flex-start;
  border: 1px solid #e0e9e5;
  border-radius: 8px;
  background: #f8fbfa;
  padding: 18px;
  cursor: pointer;
  text-align: left;

  i {
    font-size: 28px;
    color: #007a4d;
  }

  h4 {
    margin: 0 0 8px;
    color: #26342f;
    font-size: 16px;
  }

  p {
    margin: 0;
    color: #60726b;
    line-height: 1.5;
  }

  &:hover {
    border-color: #007a4d;
    background: #f0faf5;
  }
}

.news-cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 24px;
}

.news-card {
  background: white;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 12px 28px rgba(8, 83, 61, 0.12);
  border: 1px solid rgba(0, 122, 77, 0.08);
}

.news-cover {
  border: 0;
  padding: 0;
  width: 100%;
  height: 210px;
  display: block;
  overflow: hidden;
  cursor: pointer;

  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.25s;
  }

  &:hover img {
    transform: scale(1.04);
  }
}

.news-card-body {
  padding: 22px;
}

.news-card-title {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 14px;

  h3 {
    font-size: 22px;
    margin: 0;
    color: #26342f;
  }
}

.news-line {
  width: 100%;
  min-height: 44px;
  border: 0;
  border-top: 1px solid #edf2ef;
  background: white;
  text-align: left;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  cursor: pointer;

  span {
    color: #26342f;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  small {
    color: #8d9a95;
    white-space: nowrap;
  }

  &:hover span {
    color: #007a4d;
  }
}

.floating-tools {
  position: fixed;
  right: 20px;
  top: 210px;
  z-index: 999;
  display: flex;
  flex-direction: column;
  gap: 10px;

  button {
    width: 74px;
    min-height: 58px;
    border: 0;
    border-radius: 6px;
    background: white;
    box-shadow: 0 8px 18px rgba(0, 0, 0, 0.12);
    color: #4b5652;
    cursor: pointer;

    i {
      display: block;
      font-size: 24px;
      margin-bottom: 4px;
      color: #007a4d;
    }

    span {
      font-size: 12px;
    }

    &:hover {
      background: #007a4d;
      color: white;

      i {
        color: white;
      }
    }
  }
}

.footer {
  background: #075f42;
  padding: 56px 0 0;
}

.footer-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 30px;
}

.footer-main {
  display: flex;
  justify-content: space-between;
  gap: 40px;
  padding-bottom: 36px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.14);
}

.footer-logo {
  display: block;
  color: white;

  .logo-icon {
    width: 56px;
    height: 56px;
    background: rgba(255, 255, 255, 0.12);
    margin-bottom: 14px;
  }

  h3 {
    font-size: 20px;
    color: white;
    margin: 0 0 5px;
  }

  p {
    font-size: 10px;
    color: rgba(255, 255, 255, 0.68);
    margin: 0;
  }
}

.footer-links {
  display: flex;
  gap: 70px;
}

.link-group {
  h4 {
    font-size: 16px;
    color: white;
    margin: 0 0 18px;
  }

  button {
    display: block;
    border: 0;
    background: transparent;
    color: rgba(255, 255, 255, 0.74);
    text-decoration: none;
    font-size: 14px;
    margin-bottom: 12px;
    transition: color 0.2s;
    cursor: pointer;
    text-align: left;

    &:hover {
      color: white;
    }

    i {
      margin-right: 8px;
    }
  }
}

.footer-bottom {
  text-align: center;
  padding: 20px 0;

  p {
    color: rgba(255, 255, 255, 0.64);
    font-size: 13px;
    margin: 0;
  }
}

.public-dialog {
  .dialog-section {
    color: #34433e;

    .dialog-lead {
      font-size: 16px;
      line-height: 1.8;
      margin: 0 0 18px;
    }

    h4 {
      margin: 20px 0 12px;
      color: #075f42;
    }

    ul {
      margin: 0;
      padding-left: 20px;
      line-height: 1.9;
    }
  }
}

.dialog-meta {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;

  span {
    background: #f4f8f6;
    border-radius: 6px;
    padding: 12px;
    line-height: 1.5;

    i {
      color: #007a4d;
      margin-right: 6px;
    }
  }
}

.tag-row {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.doctor-row {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;

  div {
    background: #f4f8f6;
    border-radius: 6px;
    padding: 12px;
  }

  strong,
  span {
    display: block;
  }

  span {
    color: #60726b;
    margin-top: 4px;
  }
}

@media (max-width: 1200px) {
  .nav-menu {
    gap: 16px;
  }

  .entry-container {
    grid-template-columns: repeat(3, 1fr);
  }

  .about-content,
  .department-browser,
  .guide-layout {
    grid-template-columns: 1fr;
  }

  .about-visual img:first-child {
    margin-top: 0;
  }

  .departments-grid,
  .news-cards {
    grid-template-columns: repeat(2, 1fr);
  }

  .floating-tools {
    display: none;
  }
}

@media (max-width: 768px) {
  .header-container {
    padding: 0 16px;
  }

  .nav-menu {
    display: none;
  }

  .logo-text h1 {
    font-size: 18px;
  }

  .header-actions {
    .el-button {
      padding: 9px 12px;
    }
  }

  .banner-content {
    width: calc(100% - 36px);

    h2 {
      font-size: 34px;
    }

    p {
      font-size: 16px;
    }
  }

  .entry-container,
  .departments-grid,
  .about-stats,
  .news-cards,
  .guide-tabs,
  .guide-sections,
  .dialog-meta,
  .doctor-row {
    grid-template-columns: 1fr;
  }

  .department-tabs,
  .department-list {
    grid-template-columns: repeat(2, 1fr);
  }

  .department-actions,
  .footer-main,
  .footer-links {
    grid-template-columns: 1fr;
    flex-direction: column;
  }
}
</style>
