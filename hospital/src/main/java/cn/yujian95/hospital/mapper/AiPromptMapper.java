package cn.yujian95.hospital.mapper;

import cn.yujian95.hospital.entity.AiPrompt;
import org.apache.ibatis.annotations.*;

public interface AiPromptMapper {
    @Insert("insert into prompts (imaging_id, study_id, series_id, instance_id, prompt_type, coordinates_json, coord_space, slice_index, created_by, version, gmt_create) " +
            "values (#{imagingId}, #{studyId}, #{seriesId}, #{instanceId}, #{promptType}, #{coordinatesJson}, #{coordSpace}, #{sliceIndex}, #{createdBy}, #{version}, #{gmtCreate})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertSelective(AiPrompt record);

    @Select("select * from prompts where id = #{id}")
    @Results(id = "PromptResultMap", value = {
            @Result(column = "imaging_id", property = "imagingId"),
            @Result(column = "study_id", property = "studyId"),
            @Result(column = "series_id", property = "seriesId"),
            @Result(column = "instance_id", property = "instanceId"),
            @Result(column = "prompt_type", property = "promptType"),
            @Result(column = "coordinates_json", property = "coordinatesJson"),
            @Result(column = "coord_space", property = "coordSpace"),
            @Result(column = "slice_index", property = "sliceIndex"),
            @Result(column = "created_by", property = "createdBy"),
            @Result(column = "gmt_create", property = "gmtCreate")
    })
    AiPrompt selectByPrimaryKey(Long id);
}
