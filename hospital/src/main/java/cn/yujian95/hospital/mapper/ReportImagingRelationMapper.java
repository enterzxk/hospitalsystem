package cn.yujian95.hospital.mapper;

import cn.yujian95.hospital.entity.ReportImagingRelation;
import cn.yujian95.hospital.entity.ReportImagingRelationExample;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface ReportImagingRelationMapper {
    long countByExample(ReportImagingRelationExample example);

    int deleteByExample(ReportImagingRelationExample example);

    int deleteByPrimaryKey(Long id);

    int insert(ReportImagingRelation record);

    int insertSelective(ReportImagingRelation record);

    List<ReportImagingRelation> selectByExample(ReportImagingRelationExample example);

    ReportImagingRelation selectByPrimaryKey(Long id);

    int updateByExampleSelective(@Param("record") ReportImagingRelation record, @Param("example") ReportImagingRelationExample example);

    int updateByExample(@Param("record") ReportImagingRelation record, @Param("example") ReportImagingRelationExample example);

    int updateByPrimaryKeySelective(ReportImagingRelation record);

    int updateByPrimaryKey(ReportImagingRelation record);
}
