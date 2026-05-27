package cn.yujian95.hospital.entity;

import io.swagger.annotations.ApiModelProperty;
import java.io.Serializable;
import java.util.Date;

public class MedicalImaging implements Serializable {
    /**
     * 影像编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "影像编号")
    private Long id;

    /**
     * 患者编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "患者编号")
    private Long patientId;

    /**
     * 上传医生编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "上传医生编号")
    private Long doctorId;

    /**
     * 医院编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "医院编号")
    private Long hospitalId;

    /**
     * 影像类型：X光、CT、MRI、B超、心电图等
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "影像类型：X光、CT、MRI、B超、心电图等")
    private String imagingType;

    /**
     * 检查部位
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "检查部位")
    private String bodyPart;

    /**
     * 文件路径
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "文件路径")
    private String filePath;

    /**
     * 文件名
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "文件名")
    private String fileName;

    /**
     * 文件大小(字节)
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "文件大小(字节)")
    private Long fileSize;

    /**
     * 影像描述
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "影像描述")
    private String description;

    /**
     * 诊断状态：0，待诊断；1，已诊断
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "诊断状态：0，待诊断；1，已诊断")
    private Integer diagnosisStatus;

    /**
     * 创建时间
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "创建时间")
    private Date gmtCreate;

    /**
     * 更新时间
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "更新时间")
    private Date gmtModified;

    private static final long serialVersionUID = 1L;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getPatientId() {
        return patientId;
    }

    public void setPatientId(Long patientId) {
        this.patientId = patientId;
    }

    public Long getDoctorId() {
        return doctorId;
    }

    public void setDoctorId(Long doctorId) {
        this.doctorId = doctorId;
    }

    public Long getHospitalId() {
        return hospitalId;
    }

    public void setHospitalId(Long hospitalId) {
        this.hospitalId = hospitalId;
    }

    public String getImagingType() {
        return imagingType;
    }

    public void setImagingType(String imagingType) {
        this.imagingType = imagingType == null ? null : imagingType.trim();
    }

    public String getBodyPart() {
        return bodyPart;
    }

    public void setBodyPart(String bodyPart) {
        this.bodyPart = bodyPart == null ? null : bodyPart.trim();
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath == null ? null : filePath.trim();
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName == null ? null : fileName.trim();
    }

    public Long getFileSize() {
        return fileSize;
    }

    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description == null ? null : description.trim();
    }

    public Integer getDiagnosisStatus() {
        return diagnosisStatus;
    }

    public void setDiagnosisStatus(Integer diagnosisStatus) {
        this.diagnosisStatus = diagnosisStatus;
    }

    public Date getGmtCreate() {
        return gmtCreate;
    }

    public void setGmtCreate(Date gmtCreate) {
        this.gmtCreate = gmtCreate;
    }

    public Date getGmtModified() {
        return gmtModified;
    }

    public void setGmtModified(Date gmtModified) {
        this.gmtModified = gmtModified;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(hashCode());
        sb.append(", id=").append(id);
        sb.append(", patientId=").append(patientId);
        sb.append(", doctorId=").append(doctorId);
        sb.append(", hospitalId=").append(hospitalId);
        sb.append(", imagingType=").append(imagingType);
        sb.append(", bodyPart=").append(bodyPart);
        sb.append(", filePath=").append(filePath);
        sb.append(", fileName=").append(fileName);
        sb.append(", fileSize=").append(fileSize);
        sb.append(", description=").append(description);
        sb.append(", diagnosisStatus=").append(diagnosisStatus);
        sb.append(", gmtCreate=").append(gmtCreate);
        sb.append(", gmtModified=").append(gmtModified);
        sb.append(", serialVersionUID=").append(serialVersionUID);
        sb.append("]");
        return sb.toString();
    }
}
