import request from '@/utils/request'

/**
 * 添加标注
 */
export function addAnnotation(data) {
  return request({
    url: '/imaging/annotation/create',
    method: 'post',
    data: data
  })
}

/**
 * 批量添加标注
 */
export function batchAddAnnotation(data) {
  return request({
    url: '/imaging/annotation/batchCreate',
    method: 'post',
    data: data
  })
}

/**
 * 获取影像的所有标注
 */
export function getAnnotationList(imagingId) {
  return request({
    url: '/imaging/annotation/list/' + imagingId,
    method: 'get'
  })
}

/**
 * 删除标注
 */
export function deleteAnnotation(id) {
  return request({
    url: '/imaging/annotation/delete/' + id,
    method: 'post'
  })
}

/**
 * 删除影像的所有标注
 */
export function deleteAnnotationByImaging(imagingId) {
  return request({
    url: '/imaging/annotation/deleteByImaging/' + imagingId,
    method: 'post'
  })
}

/**
 * 更新标注
 */
export function updateAnnotation(data) {
  return request({
    url: '/imaging/annotation/update',
    method: 'post',
    data: data
  })
}
