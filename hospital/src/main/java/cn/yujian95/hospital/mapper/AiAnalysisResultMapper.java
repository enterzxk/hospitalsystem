package cn.yujian95.hospital.mapper;

import cn.yujian95.hospital.entity.AiAnalysisResult;
import org.apache.ibatis.annotations.*;

import java.util.List;

public interface AiAnalysisResultMapper {
    @Insert("insert into ai_analysis_result (result_id, job_id, task_type, imaging_id, study_id, series_id, instance_id, model_id, model_name, model_version, confidence, result_json, confirm_status, confirmed_by, confirmed_at, confirm_comment, gmt_create, gmt_modified) " +
            "values (#{resultId}, #{jobId}, #{taskType}, #{imagingId}, #{studyId}, #{seriesId}, #{instanceId}, #{modelId}, #{modelName}, #{modelVersion}, #{confidence}, #{resultJson}, #{confirmStatus}, #{confirmedBy}, #{confirmedAt}, #{confirmComment}, #{gmtCreate}, #{gmtModified})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertSelective(AiAnalysisResult record);

    @Select("select * from ai_analysis_result where id = #{id}")
    @Results(id = "AiAnalysisResultMap", value = {
            @Result(column = "result_id", property = "resultId"),
            @Result(column = "job_id", property = "jobId"),
            @Result(column = "task_type", property = "taskType"),
            @Result(column = "imaging_id", property = "imagingId"),
            @Result(column = "study_id", property = "studyId"),
            @Result(column = "series_id", property = "seriesId"),
            @Result(column = "instance_id", property = "instanceId"),
            @Result(column = "model_id", property = "modelId"),
            @Result(column = "model_name", property = "modelName"),
            @Result(column = "model_version", property = "modelVersion"),
            @Result(column = "result_json", property = "resultJson"),
            @Result(column = "confirm_status", property = "confirmStatus"),
            @Result(column = "confirmed_by", property = "confirmedBy"),
            @Result(column = "confirmed_at", property = "confirmedAt"),
            @Result(column = "confirm_comment", property = "confirmComment"),
            @Result(column = "gmt_create", property = "gmtCreate"),
            @Result(column = "gmt_modified", property = "gmtModified")
    })
    AiAnalysisResult selectByPrimaryKey(Long id);

    @Select("select * from ai_analysis_result where imaging_id = #{imagingId} order by gmt_create desc")
    @ResultMap("AiAnalysisResultMap")
    List<AiAnalysisResult> selectByImagingId(Long imagingId);

    @Select("<script>select * from ai_analysis_result where id in " +
            "<foreach collection='ids' item='id' open='(' separator=',' close=')'>#{id}</foreach></script>")
    @ResultMap("AiAnalysisResultMap")
    List<AiAnalysisResult> selectByIds(@Param("ids") List<Long> ids);

    @Update("update ai_analysis_result set confirm_status=#{confirmStatus}, confirmed_by=#{confirmedBy}, confirmed_at=#{confirmedAt}, confirm_comment=#{confirmComment}, gmt_modified=#{gmtModified} where id=#{id}")
    int updateConfirmStatus(AiAnalysisResult record);
}
