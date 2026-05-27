package cn.yujian95.hospital.service.impl;

import cn.yujian95.hospital.entity.ImagingAnnotation;
import cn.yujian95.hospital.mapper.ImagingAnnotationMapper;
import cn.yujian95.hospital.service.IImagingAnnotationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ImagingAnnotationServiceImpl implements IImagingAnnotationService {

    @Autowired
    private ImagingAnnotationMapper annotationMapper;

    @Override
    public ImagingAnnotation create(ImagingAnnotation annotation) {
        annotationMapper.insert(annotation);
        return annotation;
    }

    @Override
    @Transactional
    public int batchCreate(List<ImagingAnnotation> annotations) {
        int count = 0;
        for (ImagingAnnotation annotation : annotations) {
            annotationMapper.insert(annotation);
            count++;
        }
        return count;
    }

    @Override
    public List<ImagingAnnotation> getByImagingId(Long imagingId) {
        return annotationMapper.selectByImagingId(imagingId);
    }

    @Override
    public int delete(Long id) {
        return annotationMapper.deleteByPrimaryKey(id);
    }

    @Override
    @Transactional
    public int deleteByImagingId(Long imagingId) {
        return annotationMapper.deleteByImagingId(imagingId);
    }

    @Override
    public int update(ImagingAnnotation annotation) {
        return annotationMapper.updateByPrimaryKeySelective(annotation);
    }
}
