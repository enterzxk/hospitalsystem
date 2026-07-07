package cn.yujian95.hospital.dto.ai;

import java.io.Serializable;

public class StudyUploadParam implements Serializable {
    private Long patientId;
    private Long doctorId;
    private Long hospitalId;
    private String patientName;
    private String gender;
    private Integer age;
    private String phone;
    private String modality;
    private String bodyPart;
    private String fileName;
    private Long fileSize;
    private String fileUri;
    private String seriesDescription;
    private Integer sliceCount;
    private String metadataJson;
    private Boolean anonymized;
    private String description;

    public Long getPatientId() { return patientId; }
    public void setPatientId(Long patientId) { this.patientId = patientId; }
    public Long getDoctorId() { return doctorId; }
    public void setDoctorId(Long doctorId) { this.doctorId = doctorId; }
    public Long getHospitalId() { return hospitalId; }
    public void setHospitalId(Long hospitalId) { this.hospitalId = hospitalId; }
    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getModality() { return modality; }
    public void setModality(String modality) { this.modality = modality; }
    public String getBodyPart() { return bodyPart; }
    public void setBodyPart(String bodyPart) { this.bodyPart = bodyPart; }
    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }
    public Long getFileSize() { return fileSize; }
    public void setFileSize(Long fileSize) { this.fileSize = fileSize; }
    public String getFileUri() { return fileUri; }
    public void setFileUri(String fileUri) { this.fileUri = fileUri; }
    public String getSeriesDescription() { return seriesDescription; }
    public void setSeriesDescription(String seriesDescription) { this.seriesDescription = seriesDescription; }
    public Integer getSliceCount() { return sliceCount; }
    public void setSliceCount(Integer sliceCount) { this.sliceCount = sliceCount; }
    public String getMetadataJson() { return metadataJson; }
    public void setMetadataJson(String metadataJson) { this.metadataJson = metadataJson; }
    public Boolean getAnonymized() { return anonymized; }
    public void setAnonymized(Boolean anonymized) { this.anonymized = anonymized; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
