import request from '@/utils/request'

export function getModels(params) {
  return request({
    url: '/api/models',
    method: 'get',
    params
  })
}

export function saveModel(data, id) {
  return request({
    url: id ? '/api/models/' + id : '/api/models',
    method: id ? 'put' : 'post',
    data
  })
}

export function savePrompt(data) {
  return request({
    url: '/api/prompts',
    method: 'post',
    data
  })
}

export function createInference(taskType, data) {
  return request({
    url: '/api/ai/infer/' + taskType,
    method: 'post',
    data
  })
}

export function getAiJob(jobId) {
  return request({
    url: '/api/ai/jobs/' + jobId,
    method: 'get'
  })
}

export function getAiResultsByImaging(imagingId) {
  return request({
    url: '/api/ai/results/imaging/' + imagingId,
    method: 'get'
  })
}

export function confirmAiResult(id, data) {
  return request({
    url: '/api/results/' + id + '/confirm',
    method: 'post',
    data
  })
}

export function createReportDraft(data) {
  return request({
    url: '/api/reports/draft',
    method: 'post',
    data
  })
}

export function getAuditLogs(params) {
  return request({
    url: '/api/audit-logs',
    method: 'get',
    params
  })
}

export function getOpsStatus() {
  return request({
    url: '/api/ops/status',
    method: 'get'
  })
}
