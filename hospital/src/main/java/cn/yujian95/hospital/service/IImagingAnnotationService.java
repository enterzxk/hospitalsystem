package cn.yujian95.hospital.service;

import cn.yujian95.hospital.entity.ImagingAnnotation;
import java.util.List;

public interface IImagingAnnotationService {

    /**
     * 添加标注
     */
    ImagingAnnotation create(ImagingAnnotation annotation);

    /**
     * 批量添加标注
     */
    int batchCreate(List<ImagingAnnotation> annotations);

    /**
     * 获取影像的所有标注
     */
    List<ImagingAnnotation> getByImagingId(Long imagingId);

    /**
     * 删除标注
     */
    int delete(Long id);

    /**
     * 删除影像的所有标注
     */
    int deleteByImagingId(Long imagingId);

    /**
     * 更新标注
     */
    int update(ImagingAnnotation annotation);
}
