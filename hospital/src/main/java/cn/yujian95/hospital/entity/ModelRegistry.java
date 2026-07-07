package cn.yujian95.hospital.entity;

import java.io.Serializable;
import java.util.Date;

public class ModelRegistry implements Serializable {
    private Long id;
    private String modelId;
    private String name;
    private String taskType;
    private String modality;
    private String version;
    private String weightUri;
    private String configJson;
    private Integer status;
    private Date gmtCreate;
    private Date gmtModified;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getModelId() { return modelId; }
    public void setModelId(String modelId) { this.modelId = modelId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getTaskType() { return taskType; }
    public void setTaskType(String taskType) { this.taskType = taskType; }
    public String getModality() { return modality; }
    public void setModality(String modality) { this.modality = modality; }
    public String getVersion() { return version; }
    public void setVersion(String version) { this.version = version; }
    public String getWeightUri() { return weightUri; }
    public void setWeightUri(String weightUri) { this.weightUri = weightUri; }
    public String getConfigJson() { return configJson; }
    public void setConfigJson(String configJson) { this.configJson = configJson; }
    public Integer getStatus() { return status; }
    public void setStatus(Integer status) { this.status = status; }
    public Date getGmtCreate() { return gmtCreate; }
    public void setGmtCreate(Date gmtCreate) { this.gmtCreate = gmtCreate; }
    public Date getGmtModified() { return gmtModified; }
    public void setGmtModified(Date gmtModified) { this.gmtModified = gmtModified; }
}
