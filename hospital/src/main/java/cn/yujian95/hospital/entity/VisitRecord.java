package cn.yujian95.hospital.entity;

import io.swagger.annotations.ApiModelProperty;
import java.io.Serializable;
import java.util.Date;

public class VisitRecord implements Serializable {
    /**
     * 就诊编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "就诊编号")
    private Long id;

    /**
     * 患者编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "患者编号")
    private Long patientId;

    /**
     * 医生编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "医生编号")
    private Long doctorId;

    /**
     * 医院编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "医院编号")
    private Long hospitalId;

    /**
     * 专科编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "专科编号")
    private Long specialId;

    /**
     * 门诊编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "门诊编号")
    private Long outpatientId;

    /**
     * 就诊日期
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "就诊日期")
    private Date visitDate;

    /**
     * 症状描述
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "症状描述")
    private String symptoms;

    /**
     * 初步诊断
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "初步诊断")
    private String diagnosis;

    /**
     * 治疗方案
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "治疗方案")
    private String treatmentPlan;

    /**
     * 处方
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "处方")
    private String prescription;

    /**
     * 就诊状态：0，候诊中；1，就诊中；2，已完成
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "就诊状态：0，候诊中；1，就诊中；2，已完成")
    private Integer visitStatus;

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

    public Long getSpecialId() {
        return specialId;
    }

    public void setSpecialId(Long specialId) {
        this.specialId = specialId;
    }

    public Long getOutpatientId() {
        return outpatientId;
    }

    public void setOutpatientId(Long outpatientId) {
        this.outpatientId = outpatientId;
    }

    public Date getVisitDate() {
        return visitDate;
    }

    public void setVisitDate(Date visitDate) {
        this.visitDate = visitDate;
    }

    public String getSymptoms() {
        return symptoms;
    }

    public void setSymptoms(String symptoms) {
        this.symptoms = symptoms == null ? null : symptoms.trim();
    }

    public String getDiagnosis() {
        return diagnosis;
    }

    public void setDiagnosis(String diagnosis) {
        this.diagnosis = diagnosis == null ? null : diagnosis.trim();
    }

    public String getTreatmentPlan() {
        return treatmentPlan;
    }

    public void setTreatmentPlan(String treatmentPlan) {
        this.treatmentPlan = treatmentPlan == null ? null : treatmentPlan.trim();
    }

    public String getPrescription() {
        return prescription;
    }

    public void setPrescription(String prescription) {
        this.prescription = prescription == null ? null : prescription.trim();
    }

    public Integer getVisitStatus() {
        return visitStatus;
    }

    public void setVisitStatus(Integer visitStatus) {
        this.visitStatus = visitStatus;
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
        sb.append(", specialId=").append(specialId);
        sb.append(", outpatientId=").append(outpatientId);
        sb.append(", visitDate=").append(visitDate);
        sb.append(", symptoms=").append(symptoms);
        sb.append(", diagnosis=").append(diagnosis);
        sb.append(", treatmentPlan=").append(treatmentPlan);
        sb.append(", prescription=").append(prescription);
        sb.append(", visitStatus=").append(visitStatus);
        sb.append(", gmtCreate=").append(gmtCreate);
        sb.append(", gmtModified=").append(gmtModified);
        sb.append(", serialVersionUID=").append(serialVersionUID);
        sb.append("]");
        return sb.toString();
    }
}
