package cn.yujian95.hospital.mapper;

import cn.yujian95.hospital.entity.DiagnosisReport;
import cn.yujian95.hospital.entity.DiagnosisReportExample;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface DiagnosisReportMapper {
    long countByExample(DiagnosisReportExample example);

    int deleteByExample(DiagnosisReportExample example);

    int deleteByPrimaryKey(Long id);

    int insert(DiagnosisReport record);

    int insertSelective(DiagnosisReport record);

    List<DiagnosisReport> selectByExample(DiagnosisReportExample example);

    DiagnosisReport selectByPrimaryKey(Long id);

    int updateByExampleSelective(@Param("record") DiagnosisReport record, @Param("example") DiagnosisReportExample example);

    int updateByExample(@Param("record") DiagnosisReport record, @Param("example") DiagnosisReportExample example);

    int updateByPrimaryKeySelective(DiagnosisReport record);

    int updateByPrimaryKey(DiagnosisReport record);
}
