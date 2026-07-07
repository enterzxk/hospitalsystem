package cn.yujian95.hospital.dto.ai;

import com.alibaba.fastjson.JSON;
import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.io.Serializable;

public class AiInferRequest implements Serializable {
    @JsonAlias("imaging_id")
    private Long imagingId;
    @JsonAlias("study_id")
    private String studyId;
    @JsonAlias("series_id")
    private String seriesId;
    @JsonAlias("instance_id")
    private String instanceId;
    @JsonAlias("study_record_id")
    private Long studyRecordId;
    @JsonAlias("series_record_id")
    private Long seriesRecordId;
    @JsonAlias("instance_record_id")
    private Long instanceRecordId;
    @JsonAlias("model_id")
    private String modelId;
    @JsonAlias("task_type")
    private String taskType;
    private String modality;
    @JsonAlias("prompt_json")
    private String promptJson;
    @JsonAlias("preprocess_json")
    private String preprocessJson;
    @JsonAlias("user_id")
    private Long userId;

    public Long getImagingId() { return imagingId; }
    public void setImagingId(Long imagingId) { this.imagingId = imagingId; }
    public String getStudyId() { return studyId; }
    public void setStudyId(String studyId) { this.studyId = studyId; }
    public String getSeriesId() { return seriesId; }
    public void setSeriesId(String seriesId) { this.seriesId = seriesId; }
    public String getInstanceId() { return instanceId; }
    public void setInstanceId(String instanceId) { this.instanceId = instanceId; }
    public Long getStudyRecordId() { return studyRecordId; }
    public void setStudyRecordId(Long studyRecordId) { this.studyRecordId = studyRecordId; }
    public Long getSeriesRecordId() { return seriesRecordId; }
    public void setSeriesRecordId(Long seriesRecordId) { this.seriesRecordId = seriesRecordId; }
    public Long getInstanceRecordId() { return instanceRecordId; }
    public void setInstanceRecordId(Long instanceRecordId) { this.instanceRecordId = instanceRecordId; }
    public String getModelId() { return modelId; }
    public void setModelId(String modelId) { this.modelId = modelId; }
    public String getTaskType() { return taskType; }
    public void setTaskType(String taskType) { this.taskType = taskType; }
    public String getModality() { return modality; }
    public void setModality(String modality) { this.modality = modality; }
    public String getPromptJson() { return promptJson; }
    public void setPromptJson(String promptJson) { this.promptJson = promptJson; }
    public String getPreprocessJson() { return preprocessJson; }
    public void setPreprocessJson(String preprocessJson) { this.preprocessJson = preprocessJson; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    @JsonProperty("prompt")
    public void setPrompt(Object prompt) {
        this.promptJson = toJsonValue(prompt);
    }

    @JsonProperty("preprocess")
    public void setPreprocess(Object preprocess) {
        this.preprocessJson = toJsonValue(preprocess);
    }

    private String toJsonValue(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof String) {
            return (String) value;
        }
        return JSON.toJSONString(value);
    }
}
