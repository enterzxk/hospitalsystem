package cn.yujian95.hospital.mapper;

import cn.yujian95.hospital.entity.StudyInstance;
import org.apache.ibatis.annotations.*;

import java.util.List;

public interface StudyInstanceMapper {
    @Insert("insert into instances (series_id, sop_uid, slice_index, file_uri, thumbnail_uri, render_uri, metadata_json, gmt_create, gmt_modified) " +
            "values (#{seriesId}, #{sopUid}, #{sliceIndex}, #{fileUri}, #{thumbnailUri}, #{renderUri}, #{metadataJson}, #{gmtCreate}, #{gmtModified})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertSelective(StudyInstance record);

    @Select("select * from instances where id = #{id}")
    @Results(id = "InstanceResultMap", value = {
            @Result(column = "series_id", property = "seriesId"),
            @Result(column = "sop_uid", property = "sopUid"),
            @Result(column = "slice_index", property = "sliceIndex"),
            @Result(column = "file_uri", property = "fileUri"),
            @Result(column = "thumbnail_uri", property = "thumbnailUri"),
            @Result(column = "render_uri", property = "renderUri"),
            @Result(column = "metadata_json", property = "metadataJson"),
            @Result(column = "gmt_create", property = "gmtCreate"),
            @Result(column = "gmt_modified", property = "gmtModified")
    })
    StudyInstance selectByPrimaryKey(Long id);

    @Select("select * from instances where series_id = #{seriesId} order by slice_index asc")
    @ResultMap("InstanceResultMap")
    List<StudyInstance> selectBySeriesId(Long seriesId);
}
