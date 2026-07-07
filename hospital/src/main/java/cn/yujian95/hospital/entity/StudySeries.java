package cn.yujian95.hospital.entity;

import java.io.Serializable;
import java.util.Date;

public class StudySeries implements Serializable {
    private Long id;
    private Long studyId;
    private String seriesUid;
    private String modality;
    private String description;
    private String spacing;
    private Integer sliceCount;
    private String metadataJson;
    private Date gmtCreate;
    private Date gmtModified;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getStudyId() { return studyId; }
    public void setStudyId(Long studyId) { this.studyId = studyId; }
    public String getSeriesUid() { return seriesUid; }
    public void setSeriesUid(String seriesUid) { this.seriesUid = seriesUid; }
    public String getModality() { return modality; }
    public void setModality(String modality) { this.modality = modality; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getSpacing() { return spacing; }
    public void setSpacing(String spacing) { this.spacing = spacing; }
    public Integer getSliceCount() { return sliceCount; }
    public void setSliceCount(Integer sliceCount) { this.sliceCount = sliceCount; }
    public String getMetadataJson() { return metadataJson; }
    public void setMetadataJson(String metadataJson) { this.metadataJson = metadataJson; }
    public Date getGmtCreate() { return gmtCreate; }
    public void setGmtCreate(Date gmtCreate) { this.gmtCreate = gmtCreate; }
    public Date getGmtModified() { return gmtModified; }
    public void setGmtModified(Date gmtModified) { this.gmtModified = gmtModified; }
}
