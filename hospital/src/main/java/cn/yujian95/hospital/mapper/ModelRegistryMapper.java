package cn.yujian95.hospital.mapper;

import cn.yujian95.hospital.entity.ModelRegistry;
import org.apache.ibatis.annotations.*;

import java.util.List;

public interface ModelRegistryMapper {
    @Insert("insert into model_registry (model_id, name, task_type, modality, version, weight_uri, config_json, status, gmt_create, gmt_modified) " +
            "values (#{modelId}, #{name}, #{taskType}, #{modality}, #{version}, #{weightUri}, #{configJson}, #{status}, #{gmtCreate}, #{gmtModified})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertSelective(ModelRegistry record);

    @Update("update model_registry set name=#{name}, task_type=#{taskType}, modality=#{modality}, version=#{version}, weight_uri=#{weightUri}, config_json=#{configJson}, status=#{status}, gmt_modified=#{gmtModified} where id=#{id}")
    int updateByPrimaryKeySelective(ModelRegistry record);

    @Select("<script>select * from model_registry where 1=1 " +
            "<if test='taskType != null and taskType != \"\"'>and task_type = #{taskType} </if>" +
            "<if test='modality != null and modality != \"\"'>and (modality = #{modality} or modality = 'ALL') </if>" +
            "order by task_type asc, name asc</script>")
    @Results(id = "ModelRegistryResultMap", value = {
            @Result(column = "model_id", property = "modelId"),
            @Result(column = "task_type", property = "taskType"),
            @Result(column = "weight_uri", property = "weightUri"),
            @Result(column = "config_json", property = "configJson"),
            @Result(column = "gmt_create", property = "gmtCreate"),
            @Result(column = "gmt_modified", property = "gmtModified")
    })
    List<ModelRegistry> selectList(@Param("taskType") String taskType, @Param("modality") String modality);

    @Select("select * from model_registry where model_id = #{modelId} limit 1")
    @ResultMap("ModelRegistryResultMap")
    ModelRegistry selectByModelId(String modelId);
}
