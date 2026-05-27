package cn.yujian95.hospital.mapper;

import cn.yujian95.hospital.entity.VisitRecord;
import cn.yujian95.hospital.entity.VisitRecordExample;
import java.util.List;
import org.apache.ibatis.annotations.Param;

public interface VisitRecordMapper {
    long countByExample(VisitRecordExample example);

    int deleteByExample(VisitRecordExample example);

    int deleteByPrimaryKey(Long id);

    int insert(VisitRecord record);

    int insertSelective(VisitRecord record);

    List<VisitRecord> selectByExample(VisitRecordExample example);

    VisitRecord selectByPrimaryKey(Long id);

    int updateByExampleSelective(@Param("record") VisitRecord record, @Param("example") VisitRecordExample example);

    int updateByExample(@Param("record") VisitRecord record, @Param("example") VisitRecordExample example);

    int updateByPrimaryKeySelective(VisitRecord record);

    int updateByPrimaryKey(VisitRecord record);
}
