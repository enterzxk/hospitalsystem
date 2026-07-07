package cn.yujian95.hospital.entity;

import java.io.Serializable;
import java.util.Date;

public class AiAnalysisResult implements Serializable {
    private Long id;
    private String resultId;
    private String jobId;
    private String taskType;
    private Long imagingId;
    private Long studyId;
    private Long seriesId;
    private Long instanceId;
    private String modelId;
    private String modelName;
    private String modelVersion;
    private Double confidence;
    private String resultJson;
    private Integer confirmStatus;
    private Long confirmedBy;
    private Date confirmedAt;
    private String confirmComment;
    private Date gmtCreate;
    private Date gmtModified;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getResultId() { return resultId; }
    public void setResultId(String resultId) { this.resultId = resultId; }
    public String getJobId() { return jobId; }
    public void setJobId(String jobId) { this.jobId = jobId; }
    public String getTaskType() { return taskType; }
    public void setTaskType(String taskType) { this.taskType = taskType; }
    public Long getImagingId() { return imagingId; }
    public void setImagingId(Long imagingId) { this.imagingId = imagingId; }
    public Long getStudyId() { return studyId; }
    public void setStudyId(Long studyId) { this.studyId = studyId; }
    public Long getSeriesId() { return seriesId; }
    public void setSeriesId(Long seriesId) { this.seriesId = seriesId; }
    public Long getInstanceId() { return instanceId; }
    public void setInstanceId(Long instanceId) { this.instanceId = instanceId; }
    public String getModelId() { return modelId; }
    public void setModelId(String modelId) { this.modelId = modelId; }
    public String getModelName() { return modelName; }
    public void setModelName(String modelName) { this.modelName = modelName; }
    public String getModelVersion() { return modelVersion; }
    public void setModelVersion(String modelVersion) { this.modelVersion = modelVersion; }
    public Double getConfidence() { return confidence; }
    public void setConfidence(Double confidence) { this.confidence = confidence; }
    public String getResultJson() { return resultJson; }
    public void setResultJson(String resultJson) { this.resultJson = resultJson; }
    public Integer getConfirmStatus() { return confirmStatus; }
    public void setConfirmStatus(Integer confirmStatus) { this.confirmStatus = confirmStatus; }
    public Long getConfirmedBy() { return confirmedBy; }
    public void setConfirmedBy(Long confirmedBy) { this.confirmedBy = confirmedBy; }
    public Date getConfirmedAt() { return confirmedAt; }
    public void setConfirmedAt(Date confirmedAt) { this.confirmedAt = confirmedAt; }
    public String getConfirmComment() { return confirmComment; }
    public void setConfirmComment(String confirmComment) { this.confirmComment = confirmComment; }
    public Date getGmtCreate() { return gmtCreate; }
    public void setGmtCreate(Date gmtCreate) { this.gmtCreate = gmtCreate; }
    public Date getGmtModified() { return gmtModified; }
    public void setGmtModified(Date gmtModified) { this.gmtModified = gmtModified; }
}
