import request from '@/utils/request'

/**
 * 医学影像相关API
 * 1、添加医学影像
 * 2、更新医学影像
 * 3、删除医学影像
 * 4、获取医学影像
 * 5、分页搜索医学影像
 * 6、更新影像诊断状态
 * 7、获取患者的影像列表
 */

// 1、添加医学影像
export function addImaging(data) {
  return request({
    url: '/imaging/info',
    method: 'post',
    data
  })
}

// 2、更新医学影像
export function updateImaging(id, data) {
  return request({
    url: '/imaging/info/' + id,
    method: 'put',
    data
  })
}

// 3、删除医学影像
export function deleteImaging(id) {
  return request({
    url: '/imaging/info/' + id,
    method: 'delete'
  })
}

// 4、获取医学影像
export function getImagingInfo(id) {
  return request({
    url: '/imaging/info/' + id,
    method: 'get'
  })
}

// 5、分页搜索医学影像
export function getImagingList(params) {
  return request({
    url: '/imaging/info/list',
    method: 'get',
    params
  })
}

// 6、更新影像诊断状态
export function updateDiagnosisStatus(id, diagnosisStatus) {
  return request({
    url: '/imaging/info/' + id + '/status',
    method: 'put',
    params: { diagnosisStatus }
  })
}

// 7、获取患者的影像列表
export function getImagingsByPatientId(patientId) {
  return request({
    url: '/imaging/info/patient/' + patientId,
    method: 'get'
  })
}
