package cn.yujian95.hospital.mapper;

import cn.yujian95.hospital.entity.StudySeries;
import org.apache.ibatis.annotations.*;

import java.util.List;

public interface StudySeriesMapper {
    @Insert("insert into series (study_id, series_uid, modality, description, spacing, slice_count, metadata_json, gmt_create, gmt_modified) " +
            "values (#{studyId}, #{seriesUid}, #{modality}, #{description}, #{spacing}, #{sliceCount}, #{metadataJson}, #{gmtCreate}, #{gmtModified})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertSelective(StudySeries record);

    @Select("select * from series where id = #{id}")
    @Results(id = "SeriesResultMap", value = {
            @Result(column = "study_id", property = "studyId"),
            @Result(column = "series_uid", property = "seriesUid"),
            @Result(column = "slice_count", property = "sliceCount"),
            @Result(column = "metadata_json", property = "metadataJson"),
            @Result(column = "gmt_create", property = "gmtCreate"),
            @Result(column = "gmt_modified", property = "gmtModified")
    })
    StudySeries selectByPrimaryKey(Long id);

    @Select("select * from series where study_id = #{studyId} order by id asc")
    @ResultMap("SeriesResultMap")
    List<StudySeries> selectByStudyId(Long studyId);
}
