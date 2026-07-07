package cn.yujian95.hospital.entity;

import java.io.Serializable;
import java.util.Date;

public class StudyInstance implements Serializable {
    private Long id;
    private Long seriesId;
    private String sopUid;
    private Integer sliceIndex;
    private String fileUri;
    private String thumbnailUri;
    private String renderUri;
    private String metadataJson;
    private Date gmtCreate;
    private Date gmtModified;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getSeriesId() { return seriesId; }
    public void setSeriesId(Long seriesId) { this.seriesId = seriesId; }
    public String getSopUid() { return sopUid; }
    public void setSopUid(String sopUid) { this.sopUid = sopUid; }
    public Integer getSliceIndex() { return sliceIndex; }
    public void setSliceIndex(Integer sliceIndex) { this.sliceIndex = sliceIndex; }
    public String getFileUri() { return fileUri; }
    public void setFileUri(String fileUri) { this.fileUri = fileUri; }
    public String getThumbnailUri() { return thumbnailUri; }
    public void setThumbnailUri(String thumbnailUri) { this.thumbnailUri = thumbnailUri; }
    public String getRenderUri() { return renderUri; }
    public void setRenderUri(String renderUri) { this.renderUri = renderUri; }
    public String getMetadataJson() { return metadataJson; }
    public void setMetadataJson(String metadataJson) { this.metadataJson = metadataJson; }
    public Date getGmtCreate() { return gmtCreate; }
    public void setGmtCreate(Date gmtCreate) { this.gmtCreate = gmtCreate; }
    public Date getGmtModified() { return gmtModified; }
    public void setGmtModified(Date gmtModified) { this.gmtModified = gmtModified; }
}
