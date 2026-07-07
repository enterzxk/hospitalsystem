package cn.yujian95.hospital.mapper;

import cn.yujian95.hospital.entity.Study;
import org.apache.ibatis.annotations.*;

import java.util.List;

public interface StudyMapper {
    @Insert("insert into studies (patient_id, imaging_id, study_uid, modality, body_part, study_time, metadata_json, storage_root, anonymized, gmt_create, gmt_modified) " +
            "values (#{patientId}, #{imagingId}, #{studyUid}, #{modality}, #{bodyPart}, #{studyTime}, #{metadataJson}, #{storageRoot}, #{anonymized}, #{gmtCreate}, #{gmtModified})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertSelective(Study record);

    @Select("select * from studies where id = #{id}")
    @Results(id = "StudyResultMap", value = {
            @Result(column = "patient_id", property = "patientId"),
            @Result(column = "imaging_id", property = "imagingId"),
            @Result(column = "study_uid", property = "studyUid"),
            @Result(column = "body_part", property = "bodyPart"),
            @Result(column = "study_time", property = "studyTime"),
            @Result(column = "metadata_json", property = "metadataJson"),
            @Result(column = "storage_root", property = "storageRoot"),
            @Result(column = "gmt_create", property = "gmtCreate"),
            @Result(column = "gmt_modified", property = "gmtModified")
    })
    Study selectByPrimaryKey(Long id);

    @Select("select * from studies where patient_id = #{patientId} order by study_time desc")
    @ResultMap("StudyResultMap")
    List<Study> selectByPatientId(Long patientId);

    @Select("<script>" +
            "select * from studies where 1=1 " +
            "<if test='patientId != null'>and patient_id = #{patientId} </if>" +
            "<if test='modality != null and modality != \"\"'>and modality = #{modality} </if>" +
            "<if test='bodyPart != null and bodyPart != \"\"'>and body_part = #{bodyPart} </if>" +
            "order by study_time desc" +
            "</script>")
    @ResultMap("StudyResultMap")
    List<Study> selectList(@Param("patientId") Long patientId,
                           @Param("modality") String modality,
                           @Param("bodyPart") String bodyPart);
}
