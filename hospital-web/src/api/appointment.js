import request from '@/utils/request'

// 1、获取出诊计划列表（患者选医生/时间用）
export function getVisitPlanList(doctorId, startDate, endDate) {
  return request({
    url: '/visit/plan/doctor',
    method: 'get',
    params: {doctorId, startDate, endDate}
  })
}

// 2、根据专科和门诊查询出诊计划
export function getVisitPlanByDept(specialId, outpatientId, date, pageNum, pageSize) {
  return request({
    url: '/visit/plan/list',
    method: 'get',
    params: {specialId, outpatientId, date, pageNum, pageSize}
  })
}

// 3、创建预约挂号
export function createAppointment(data) {
  return request({
    url: '/visit/appointment',
    method: 'post',
    data
  })
}

// 4、获取我的预约列表
export function getMyAppointments(cardId, pageNum, pageSize) {
  return request({
    url: '/visit/appointment/list',
    method: 'get',
    params: {cardId, pageNum, pageSize}
  })
}

// 5、取消预约
export function cancelAppointment(id) {
  return request({
    url: '/visit/appointment/cancel/' + id,
    method: 'put'
  })
}

// 6、获取患者就诊记录
export function getVisitRecords(cardId, pageNum, pageSize) {
  return request({
    url: '/visit/appointment/list',
    method: 'get',
    params: {cardId, pageNum, pageSize}
  })
}

// 7、获取患者个人信息
export function getPatientInfo(cardId) {
  return request({
    url: '/user/basic/' + cardId,
    method: 'get'
  })
}

// 8、获取就诊卡信息
export function getMedicalCard(cardId) {
  return request({
    url: '/user/card/' + cardId,
    method: 'get'
  })
}

// 9、获取专科列表
export function getSpecialList() {
  return request({
    url: '/hospital/special/list',
    method: 'get'
  })
}

// 10、获取门诊列表
export function getOutpatientList(specialId) {
  return request({
    url: '/hospital/outpatient/list',
    method: 'get',
    params: {specialId}
  })
}

// 11、获取医生列表（复用 doctor.js 的也可以，这里简化调用）
export function getDoctorList(specialId, outpatientId, pageNum, pageSize, name) {
  return request({
    url: '/hospital/doctor/list/name',
    method: 'get',
    params: {specialId, outpatientId, pageNum, pageSize, name}
  })
}
