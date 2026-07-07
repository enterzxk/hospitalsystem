package cn.yujian95.hospital.mapper;

import cn.yujian95.hospital.entity.InferenceJob;
import org.apache.ibatis.annotations.*;

public interface InferenceJobMapper {
    @Insert("insert into inference_jobs (job_id, task_type, model_id, imaging_id, study_id, series_id, instance_id, input_ref, prompt_json, preprocess_json, status, progress, error_msg, created_by, gmt_create, gmt_modified) " +
            "values (#{jobId}, #{taskType}, #{modelId}, #{imagingId}, #{studyId}, #{seriesId}, #{instanceId}, #{inputRef}, #{promptJson}, #{preprocessJson}, #{status}, #{progress}, #{errorMsg}, #{createdBy}, #{gmtCreate}, #{gmtModified})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertSelective(InferenceJob record);

    @Update("update inference_jobs set status=#{status}, progress=#{progress}, error_msg=#{errorMsg}, gmt_modified=#{gmtModified} where job_id=#{jobId}")
    int updateStatus(InferenceJob record);

    @Select("select * from inference_jobs where job_id = #{jobId}")
    @Results(id = "InferenceJobResultMap", value = {
            @Result(column = "job_id", property = "jobId"),
            @Result(column = "task_type", property = "taskType"),
            @Result(column = "model_id", property = "modelId"),
            @Result(column = "imaging_id", property = "imagingId"),
            @Result(column = "study_id", property = "studyId"),
            @Result(column = "series_id", property = "seriesId"),
            @Result(column = "instance_id", property = "instanceId"),
            @Result(column = "input_ref", property = "inputRef"),
            @Result(column = "prompt_json", property = "promptJson"),
            @Result(column = "preprocess_json", property = "preprocessJson"),
            @Result(column = "error_msg", property = "errorMsg"),
            @Result(column = "created_by", property = "createdBy"),
            @Result(column = "gmt_create", property = "gmtCreate"),
            @Result(column = "gmt_modified", property = "gmtModified")
    })
    InferenceJob selectByJobId(String jobId);
}
