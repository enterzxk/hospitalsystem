package cn.yujian95.hospital.mapper;

import cn.yujian95.hospital.entity.ImagingAnnotation;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface ImagingAnnotationMapper {
    int insert(ImagingAnnotation record);

    int insertSelective(ImagingAnnotation record);

    List<ImagingAnnotation> selectByImagingId(@Param("imagingId") Long imagingId);

    ImagingAnnotation selectByPrimaryKey(Long id);

    int deleteByPrimaryKey(Long id);

    int updateByPrimaryKeySelective(ImagingAnnotation record);

    int updateByPrimaryKey(ImagingAnnotation record);

    int deleteByImagingId(@Param("imagingId") Long imagingId);
}
