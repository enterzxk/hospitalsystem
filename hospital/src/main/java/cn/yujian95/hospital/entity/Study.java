package cn.yujian95.hospital.entity;

import java.io.Serializable;
import java.util.Date;

public class Study implements Serializable {
    private Long id;
    private Long patientId;
    private Long imagingId;
    private String studyUid;
    private String modality;
    private String bodyPart;
    private Date studyTime;
    private String metadataJson;
    private String storageRoot;
    private Integer anonymized;
    private Date gmtCreate;
    private Date gmtModified;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getPatientId() { return patientId; }
    public void setPatientId(Long patientId) { this.patientId = patientId; }
    public Long getImagingId() { return imagingId; }
    public void setImagingId(Long imagingId) { this.imagingId = imagingId; }
    public String getStudyUid() { return studyUid; }
    public void setStudyUid(String studyUid) { this.studyUid = studyUid; }
    public String getModality() { return modality; }
    public void setModality(String modality) { this.modality = modality; }
    public String getBodyPart() { return bodyPart; }
    public void setBodyPart(String bodyPart) { this.bodyPart = bodyPart; }
    public Date getStudyTime() { return studyTime; }
    public void setStudyTime(Date studyTime) { this.studyTime = studyTime; }
    public String getMetadataJson() { return metadataJson; }
    public void setMetadataJson(String metadataJson) { this.metadataJson = metadataJson; }
    public String getStorageRoot() { return storageRoot; }
    public void setStorageRoot(String storageRoot) { this.storageRoot = storageRoot; }
    public Integer getAnonymized() { return anonymized; }
    public void setAnonymized(Integer anonymized) { this.anonymized = anonymized; }
    public Date getGmtCreate() { return gmtCreate; }
    public void setGmtCreate(Date gmtCreate) { this.gmtCreate = gmtCreate; }
    public Date getGmtModified() { return gmtModified; }
    public void setGmtModified(Date gmtModified) { this.gmtModified = gmtModified; }
}
