import request from '@/utils/request'

/**
 * 诊断报告相关API
 * 1、创建诊断报告
 * 2、更新诊断报告
 * 3、删除诊断报告
 * 4、获取诊断报告
 * 5、分页搜索诊断报告
 * 6、提交诊断报告
 * 7、审核诊断报告
 * 8、关联影像到报告
 * 9、获取报告关联的影像列表
 */

// 1、创建诊断报告
export function addReport(data) {
  return request({
    url: '/diagnosis/report',
    method: 'post',
    data
  })
}

// 2、更新诊断报告
export function updateReport(id, data) {
  return request({
    url: '/diagnosis/report/' + id,
    method: 'put',
    data
  })
}

// 3、删除诊断报告
export function deleteReport(id) {
  return request({
    url: '/diagnosis/report/' + id,
    method: 'delete'
  })
}

// 4、获取诊断报告
export function getReportInfo(id) {
  return request({
    url: '/diagnosis/report/' + id,
    method: 'get'
  })
}

// 5、分页搜索诊断报告
export function getReportList(params) {
  return request({
    url: '/diagnosis/report/list',
    method: 'get',
    params
  })
}

// 6、提交诊断报告
export function submitReport(id) {
  return request({
    url: '/diagnosis/report/' + id + '/submit',
    method: 'put'
  })
}

// 7、审核诊断报告
export function reviewReport(id, reviewerId, reviewOpinion) {
  return request({
    url: '/diagnosis/report/' + id + '/review',
    method: 'put',
    params: { reviewerId, reviewOpinion }
  })
}

// 8、关联影像到报告
export function relateImaging(reportId, imagingIds) {
  return request({
    url: '/diagnosis/report/' + reportId + '/imaging',
    method: 'post',
    data: imagingIds
  })
}

// 9、获取报告关联的影像列表
export function getReportImagings(reportId) {
  return request({
    url: '/diagnosis/report/' + reportId + '/imaging',
    method: 'get'
  })
}
