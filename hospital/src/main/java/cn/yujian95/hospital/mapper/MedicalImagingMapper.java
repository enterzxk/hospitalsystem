package cn.yujian95.hospital.mapper;

import cn.yujian95.hospital.entity.MedicalImaging;
import cn.yujian95.hospital.entity.MedicalImagingExample;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface MedicalImagingMapper {
    long countByExample(MedicalImagingExample example);

    int deleteByExample(MedicalImagingExample example);

    int deleteByPrimaryKey(Long id);

    int insert(MedicalImaging record);

    int insertSelective(MedicalImaging record);

    List<MedicalImaging> selectByExample(MedicalImagingExample example);

    MedicalImaging selectByPrimaryKey(Long id);

    int updateByExampleSelective(@Param("record") MedicalImaging record, @Param("example") MedicalImagingExample example);

    int updateByExample(@Param("record") MedicalImaging record, @Param("example") MedicalImagingExample example);

    int updateByPrimaryKeySelective(MedicalImaging record);

    int updateByPrimaryKey(MedicalImaging record);
}
