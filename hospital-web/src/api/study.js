import request from '@/utils/request'

export function listStudies(params) {
  return request({
    url: '/api/studies',
    method: 'get',
    params
  })
}

export function uploadStudy(data) {
  return request({
    url: '/api/studies/upload',
    method: 'post',
    data
  })
}

export function uploadStudyForm(data, file) {
  const formData = new FormData()
  Object.keys(data).forEach(key => {
    const value = data[key]
    if (value !== undefined && value !== null) {
      formData.append(key, value)
    }
  })
  if (file) {
    formData.append('file', file)
  }
  return request({
    url: '/api/studies/upload',
    method: 'post',
    data: formData,
    timeout: 120000
  })
}

export function getStudy(id) {
  return request({
    url: '/api/studies/' + id,
    method: 'get'
  })
}

export function getStudySeries(id) {
  return request({
    url: '/api/studies/' + id + '/series',
    method: 'get'
  })
}

export function getSeriesInstances(id) {
  return request({
    url: '/api/series/' + id + '/instances',
    method: 'get'
  })
}

export function getInstanceRender(id) {
  return request({
    url: '/api/instances/' + id + '/render',
    method: 'get'
  })
}
