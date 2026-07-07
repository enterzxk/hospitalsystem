import Vue from 'vue'
import VueRouter from 'vue-router'

import layout from '@/layout/layout'
import imagingViewer from '@/view/imagingManagement/imagingViewer'
Vue.use(VueRouter)

// 公共页面 - 不需要登录即可访问
export const publicRouterMap = [{
  path: '/',
  name: 'publicIndex',
  component: () => import('@/view/public/publicIndex'),
  hidden: true
}, {
  path: '/login',
  name: 'login',
  component: () => import('@/view/login/login'),
  hidden: true
}, {
  path: '/404',
  component: () => import('@/view/404/404'),
  hidden: true
}];

// 登录后的基础路由
export let constantRouterMap = [{
  path: '/home',
  component: layout,
  redirect: '/home/dashboard',
  meta: {title: '首页', icon: 'el-icon-s-home'},
  children: [{
    path: '/home/dashboard',
    component: () => import('@/view/home/home'),
    meta: {title: '首页', icon: 'el-icon-s-home'}
  }]
}];

// 医生路由
export const doctorRouterMap = [
  {
    path: '/doctor',
    component: layout,
    redirect: '/doctorDashboard',
    meta: {title: '医生工作台', icon: 'el-icon-s-custom'},
    children: [{
      path: '/doctorDashboard',
      component: () => import('@/view/doctorManagement/doctorDashboard'),
      meta: {title: '工作台', icon: 'el-icon-s-custom'}
    }]
  }, {
    path: '/radiologyResults',
    component: layout,
    redirect: '/radiologyResultList',
    meta: {title: '放射科结果', icon: 'el-icon-picture-outline'},
    children: [{
      path: '/radiologyResultList',
      component: () => import('@/view/diagnosisManagement/radiologyResultList'),
      meta: {title: '影像诊断结果', icon: 'el-icon-picture-outline'}
    }]
  }, {
    path: '/diagnosisManagement',
    component: layout,
    redirect: '/diagnosisList',
    meta: {title: '诊断管理', icon: 'el-icon-document-checked'},
    children: [{
      path: '/diagnosisList',
      component: () => import('@/view/diagnosisManagement/diagnosisList'),
      meta: {title: '诊断列表', icon: 'el-icon-document-checked'}
    }, {
      path: '/diagnosisWrite',
      component: () => import('@/view/diagnosisManagement/diagnosisWrite'),
      meta: {title: '填写诊断', icon: 'el-icon-edit'},
      hidden: true
    }, {
      path: '/diagnosisDetail',
      component: () => import('@/view/diagnosisManagement/diagnosisDetail'),
      meta: {title: '诊断详情', icon: 'el-icon-view'},
      hidden: true
    }]
  },
  {path: '*', redirect: '/404', hidden: true}
];

// 患者路由
export const patientRouterMap = [
  {
    path: '/patient/appointmentCreate',
    component: layout,
    redirect: '/patient/appointmentCreate',
    meta: {title: '预约挂号', icon: 'el-icon-date'},
    children: [{
      path: '/patient/appointmentCreate',
      component: () => import('@/view/patient/appointmentCreate'),
      meta: {title: '预约挂号', icon: 'el-icon-date'}
    }]
  }, {
    path: '/patient/appointmentList',
    component: layout,
    redirect: '/patient/appointmentList',
    meta: {title: '我的预约', icon: 'el-icon-tickets'},
    children: [{
      path: '/patient/appointmentList',
      component: () => import('@/view/patient/appointmentList'),
      meta: {title: '我的预约', icon: 'el-icon-tickets'}
    }]
  }, {
    path: '/patient/visitRecords',
    component: layout,
    redirect: '/patient/visitRecords',
    meta: {title: '就诊记录', icon: 'el-icon-document'},
    children: [{
      path: '/patient/visitRecords',
      component: () => import('@/view/patient/visitRecords'),
      meta: {title: '就诊记录', icon: 'el-icon-document'}
    }]
  }, {
    path: '/patient/reportQuery',
    component: layout,
    redirect: '/patient/reportQuery',
    meta: {title: '报告查询', icon: 'el-icon-s-check'},
    children: [{
      path: '/patient/reportQuery',
      component: () => import('@/view/patient/reportQuery'),
      meta: {title: '报告查询', icon: 'el-icon-s-check'}
    }]
  }, {
    path: '/patient/paymentRecords',
    component: layout,
    redirect: '/patient/paymentRecords',
    meta: {title: '缴费记录', icon: 'el-icon-wallet'},
    children: [{
      path: '/patient/paymentRecords',
      component: () => import('@/view/patient/paymentRecords'),
      meta: {title: '缴费记录', icon: 'el-icon-wallet'}
    }]
  }, {
    path: '/patient/profile',
    component: layout,
    redirect: '/patient/profile',
    meta: {title: '个人信息', icon: 'el-icon-user'},
    children: [{
      path: '/patient/profile',
      component: () => import('@/view/patient/patientProfile'),
      meta: {title: '个人信息', icon: 'el-icon-user'}
    }]
  }, {
    path: '/patient/departmentIntroduction',
    component: layout,
    redirect: '/patient/departmentIntroduction',
    meta: {title: '科室介绍', icon: 'el-icon-office-building'},
    children: [{
      path: '/patient/departmentIntroduction',
      component: () => import('@/view/patient/departmentIntroduction'),
      meta: {title: '科室介绍', icon: 'el-icon-office-building'}
    }]
  },
  {path: '*', redirect: '/404', hidden: true}
];

// 放射科医生路由
export const radiologistRouterMap = [
  {
    path: '/radiologist',
    component: layout,
    redirect: '/radiologistDashboard',
    meta: {title: '放射科工作台', icon: 'el-icon-monitor'},
    children: [{
      path: '/radiologistDashboard',
      component: () => import('@/view/imagingManagement/radiologistDashboard'),
      meta: {title: '工作台', icon: 'el-icon-monitor'}
    }]
  }, {
    path: '/imagingManagement',
    component: layout,
    redirect: '/imagingList',
    meta: {title: '影像管理', icon: 'el-icon-picture'},
    children: [{
      path: '/imagingList',
      component: () => import('@/view/imagingManagement/imagingList'),
      meta: {title: '影像列表', icon: 'el-icon-picture'}
    }, {
      path: '/imagingUpload',
      component: () => import('@/view/imagingManagement/imagingUpload'),
      meta: {title: '上传影像', icon: 'el-icon-upload'},
      hidden: true
    }, {
      path: '/imagingDetail',
      component: () => import('@/view/imagingManagement/imagingDetail'),
      meta: {title: '影像详情', icon: 'el-icon-view'},
      hidden: true
    }, {
      path: '/imagingViewer',
      component: imagingViewer,
      meta: {title: '影像查看器', icon: 'el-icon-view'},
      hidden: true
    }]
  }, {
    path: '/diagnosisManagement',
    component: layout,
    redirect: '/diagnosisReports',
    meta: {title: '诊断管理', icon: 'el-icon-document-checked'},
    children: [{
      path: '/diagnosisReports',
      component: () => import('@/view/diagnosisManagement/diagnosisReports'),
      meta: {title: '诊断报告', icon: 'el-icon-document'}
    }, {
      path: '/diagnosisList',
      component: () => import('@/view/diagnosisManagement/diagnosisList'),
      meta: {title: '诊断列表', icon: 'el-icon-document-checked'},
      hidden: true
    }, {
      path: '/diagnosisWrite',
      component: () => import('@/view/diagnosisManagement/diagnosisWrite'),
      meta: {title: '填写诊断', icon: 'el-icon-edit'},
      hidden: true
    }, {
      path: '/diagnosisDetail',
      component: () => import('@/view/diagnosisManagement/diagnosisDetail'),
      meta: {title: '诊断详情', icon: 'el-icon-view'},
      hidden: true
    }]
  },
  {path: '*', redirect: '/404', hidden: true}
];

// 管理员路由
export const systemRouterMap = [
  {
    path: '/hospitalManagement',
    component: layout,
    redirect: '/hospitalDetail',
    meta: {title: '医院管理', icon: 'el-icon-office-building'},
    children: [{
      path: '/hospitalDetail',
      component: () => import('@/view/hospitalManagement/hospitalDetail'),
      meta: {title: '医院详情', icon: 'el-icon-office-building'}
    }, {
      path: '/checkHospital',
      component: () => import('@/view/hospitalManagement/checkHospital'),
      meta: {title: '查看医院详情', icon: 'el-icon-view'},
      hidden: true
    }, {
      path: '/addHospital',
      component: () => import('@/view/hospitalManagement/addHospital'),
      meta: {title: '添加医院', icon: 'el-icon-plus'},
      hidden: true
    }, {
      path: '/editHospital',
      component: () => import('@/view/hospitalManagement/editHospital'),
      meta: {title: '修改医院', icon: 'el-icon-edit'},
      hidden: true
    }]
  }, {
    path: '/departmentManagement',
    component: layout,
    redirect: '/departmentDetail',
    meta: {title: '专科管理', icon: 'el-icon-guide'},
    children: [{
      path: '/departmentDetail',
      component: () => import('@/view/departmentManagement/departmentDetail/departmentDetail'),
      meta: {title: '专科详情', icon: 'el-icon-guide'}
    }, {
      path: '/departmentSetUp',
      component: () => import('@/view/departmentManagement/departmentSetUp/departmentSetUp'),
      meta: {title: '专科排版', icon: 'el-icon-s-grid'}
    }, {
      path: '/outpatientDetail',
      component: () => import('@/view/departmentManagement/departmentDetail/outpatientDetail'),
      meta: {title: '门诊详情', icon: 'el-icon-view'},
      hidden: true
    }, {
      path: '/treatRoomDetail',
      component: () => import('@/view/departmentManagement/departmentDetail/treatRoomDetail'),
      meta: {title: '诊室详情', icon: 'el-icon-view'},
      hidden: true
    }, {
      path: '/outpatientSetUp',
      component: () => import('@/view/departmentManagement/departmentSetUp/outpatientSetUp'),
      meta: {title: '门诊排版', icon: 'el-icon-s-grid'},
      hidden: true
    }]
  }, {
    path: '/doctorManagement',
    component: layout,
    redirect: '/doctorDetail',
    meta: {title: '医生管理', icon: 'el-icon-s-custom'},
    children: [{
      path: '/doctorDetail',
      component: () => import('@/view/doctorManagement/doctorDetail'),
      meta: {title: '医生详情', icon: 'el-icon-s-custom'}
    }, {
      path: '/checkDoctor',
      component: () => import('@/view/doctorManagement/checkDoctor'),
      meta: {title: '查看医生', icon: 'el-icon-view'},
      hidden: true
    }, {
      path: '/addDoctor',
      component: () => import('@/view/doctorManagement/addDoctor'),
      meta: {title: '添加医生', icon: 'el-icon-plus'},
      hidden: true
    }, {
      path: '/editDoctor',
      component: () => import('@/view/doctorManagement/editDoctor'),
      meta: {title: '修改医生', icon: 'el-icon-edit'},
      hidden: true
    }]
  }, {
    path: '/patientManagement',
    component: layout,
    redirect: '/patientList',
    meta: {title: '患者管理', icon: 'el-icon-user'},
    children: [{
      path: '/patientList',
      component: () => import('@/view/patientManagement/patientList'),
      meta: {title: '患者列表', icon: 'el-icon-user'}
    }, {
      path: '/patientDetail',
      component: () => import('@/view/patientManagement/patientDetail'),
      meta: {title: '患者详情', icon: 'el-icon-view'},
      hidden: true
    }]
  }, {
    path: '/imagingManagement',
    component: layout,
    redirect: '/imagingList',
    meta: {title: '影像管理', icon: 'el-icon-picture'},
    children: [{
      path: '/imagingList',
      component: () => import('@/view/imagingManagement/imagingList'),
      meta: {title: '影像列表', icon: 'el-icon-picture'}
    }, {
      path: '/imagingUpload',
      component: () => import('@/view/imagingManagement/imagingUpload'),
      meta: {title: '上传影像', icon: 'el-icon-upload'},
      hidden: true
    }, {
      path: '/imagingDetail',
      component: () => import('@/view/imagingManagement/imagingDetail'),
      meta: {title: '影像详情', icon: 'el-icon-view'},
      hidden: true
    }, {
      path: '/imagingViewer',
      component: imagingViewer,
      meta: {title: '影像查看器', icon: 'el-icon-view'},
      hidden: true
    }]
  }, {
    path: '/diagnosisManagement',
    component: layout,
    redirect: '/diagnosisList',
    meta: {title: '诊断管理', icon: 'el-icon-document-checked'},
    children: [{
      path: '/diagnosisList',
      component: () => import('@/view/diagnosisManagement/diagnosisList'),
      meta: {title: '诊断列表', icon: 'el-icon-document-checked'}
    }, {
      path: '/diagnosisWrite',
      component: () => import('@/view/diagnosisManagement/diagnosisWrite'),
      meta: {title: '填写诊断', icon: 'el-icon-edit'},
      hidden: true
    }, {
      path: '/diagnosisDetail',
      component: () => import('@/view/diagnosisManagement/diagnosisDetail'),
      meta: {title: '诊断详情', icon: 'el-icon-view'},
      hidden: true
    }, {
      path: '/diagnosisReports',
      component: () => import('@/view/diagnosisManagement/diagnosisReports'),
      meta: {title: '诊断报告', icon: 'el-icon-document'},
      hidden: true
    }]
  }, {
    path: '/aiManagement',
    component: layout,
    redirect: '/modelManagement',
    meta: {title: 'AI 平台管理', icon: 'el-icon-cpu'},
    children: [{
      path: '/modelManagement',
      component: () => import('@/view/aiManagement/modelManagement'),
      meta: {title: '模型管理', icon: 'el-icon-cpu'}
    }, {
      path: '/opsMonitor',
      component: () => import('@/view/aiManagement/opsMonitor'),
      meta: {title: '运维监控', icon: 'el-icon-data-analysis'}
    }, {
      path: '/auditLogs',
      component: () => import('@/view/aiManagement/opsMonitor'),
      meta: {title: '审计日志', icon: 'el-icon-document-checked'}
    }]
  }, {
    path: '/setUpManagement',
    component: layout,
    redirect: '/setUpDetail',
    meta: {title: '排版管理', icon: 'el-icon-document'},
    children: [{
      path: '/setUpDetail',
      component: () => import('@/view/setUpManagement/setUpDetail'),
      meta: {title: '排版详情', icon: 'el-icon-document'}
    }]
  },
  {path: '*', redirect: '/404', hidden: true}
];

const createRouter = () => new VueRouter({
  scrollBehavior: () => ({ y: 0 }),
  routes: publicRouterMap
});

const router = createRouter();

export function resetRouter() {
  const newRouter = createRouter();
  router.matcher = newRouter.matcher;
}

export default router;
