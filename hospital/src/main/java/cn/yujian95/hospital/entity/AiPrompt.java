package cn.yujian95.hospital.entity;

import java.io.Serializable;
import java.util.Date;

public class AiPrompt implements Serializable {
    private Long id;
    private Long imagingId;
    private Long studyId;
    private Long seriesId;
    private Long instanceId;
    private String promptType;
    private String coordinatesJson;
    private String coordSpace;
    private Integer sliceIndex;
    private Long createdBy;
    private Integer version;
    private Date gmtCreate;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getImagingId() { return imagingId; }
    public void setImagingId(Long imagingId) { this.imagingId = imagingId; }
    public Long getStudyId() { return studyId; }
    public void setStudyId(Long studyId) { this.studyId = studyId; }
    public Long getSeriesId() { return seriesId; }
    public void setSeriesId(Long seriesId) { this.seriesId = seriesId; }
    public Long getInstanceId() { return instanceId; }
    public void setInstanceId(Long instanceId) { this.instanceId = instanceId; }
    public String getPromptType() { return promptType; }
    public void setPromptType(String promptType) { this.promptType = promptType; }
    public String getCoordinatesJson() { return coordinatesJson; }
    public void setCoordinatesJson(String coordinatesJson) { this.coordinatesJson = coordinatesJson; }
    public String getCoordSpace() { return coordSpace; }
    public void setCoordSpace(String coordSpace) { this.coordSpace = coordSpace; }
    public Integer getSliceIndex() { return sliceIndex; }
    public void setSliceIndex(Integer sliceIndex) { this.sliceIndex = sliceIndex; }
    public Long getCreatedBy() { return createdBy; }
    public void setCreatedBy(Long createdBy) { this.createdBy = createdBy; }
    public Integer getVersion() { return version; }
    public void setVersion(Integer version) { this.version = version; }
    public Date getGmtCreate() { return gmtCreate; }
    public void setGmtCreate(Date gmtCreate) { this.gmtCreate = gmtCreate; }
}
