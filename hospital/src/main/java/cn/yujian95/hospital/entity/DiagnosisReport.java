package cn.yujian95.hospital.entity;

import io.swagger.annotations.ApiModelProperty;
import java.io.Serializable;
import java.util.Date;

public class DiagnosisReport implements Serializable {
    /**
     * 报告编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "报告编号")
    private Long id;

    /**
     * 患者编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "患者编号")
    private Long patientId;

    /**
     * 诊断医生编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "诊断医生编号")
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
     * 报告编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "报告编号")
    private String reportNo;

    /**
     * 患者姓名
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "患者姓名")
    private String patientName;

    /**
     * 性别：1，男；2，女
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "性别：1，男；2，女")
    private Integer gender;

    /**
     * 年龄
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "年龄")
    private Integer age;

    /**
     * 身份证号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "身份证号")
    private String idCard;

    /**
     * 联系电话
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "联系电话")
    private String phone;

    /**
     * 检查类型
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "检查类型")
    private String examinationType;

    /**
     * 检查部位
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "检查部位")
    private String bodyPart;

    /**
     * 临床诊断
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "临床诊断")
    private String clinicalDiagnosis;

    /**
     * 检查所见
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "检查所见")
    private String examinationFindings;

    /**
     * 诊断意见
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "诊断意见")
    private String diagnosticOpinion;

    /**
     * 报告状态：0，草稿；1，已提交；2，已审核
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "报告状态：0，草稿；1，已提交；2，已审核")
    private Integer reportStatus;

    /**
     * 报告日期
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "报告日期")
    private Date reportDate;

    /**
     * 审核医生编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "审核医生编号")
    private Long reviewerId;

    /**
     * 审核时间
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "审核时间")
    private Date reviewTime;

    /**
     * 审核意见
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "审核意见")
    private String reviewOpinion;

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

    public String getReportNo() {
        return reportNo;
    }

    public void setReportNo(String reportNo) {
        this.reportNo = reportNo == null ? null : reportNo.trim();
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName == null ? null : patientName.trim();
    }

    public Integer getGender() {
        return gender;
    }

    public void setGender(Integer gender) {
        this.gender = gender;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public String getIdCard() {
        return idCard;
    }

    public void setIdCard(String idCard) {
        this.idCard = idCard == null ? null : idCard.trim();
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone == null ? null : phone.trim();
    }

    public String getExaminationType() {
        return examinationType;
    }

    public void setExaminationType(String examinationType) {
        this.examinationType = examinationType == null ? null : examinationType.trim();
    }

    public String getBodyPart() {
        return bodyPart;
    }

    public void setBodyPart(String bodyPart) {
        this.bodyPart = bodyPart == null ? null : bodyPart.trim();
    }

    public String getClinicalDiagnosis() {
        return clinicalDiagnosis;
    }

    public void setClinicalDiagnosis(String clinicalDiagnosis) {
        this.clinicalDiagnosis = clinicalDiagnosis == null ? null : clinicalDiagnosis.trim();
    }

    public String getExaminationFindings() {
        return examinationFindings;
    }

    public void setExaminationFindings(String examinationFindings) {
        this.examinationFindings = examinationFindings == null ? null : examinationFindings.trim();
    }

    public String getDiagnosticOpinion() {
        return diagnosticOpinion;
    }

    public void setDiagnosticOpinion(String diagnosticOpinion) {
        this.diagnosticOpinion = diagnosticOpinion == null ? null : diagnosticOpinion.trim();
    }

    public Integer getReportStatus() {
        return reportStatus;
    }

    public void setReportStatus(Integer reportStatus) {
        this.reportStatus = reportStatus;
    }

    public Date getReportDate() {
        return reportDate;
    }

    public void setReportDate(Date reportDate) {
        this.reportDate = reportDate;
    }

    public Long getReviewerId() {
        return reviewerId;
    }

    public void setReviewerId(Long reviewerId) {
        this.reviewerId = reviewerId;
    }

    public Date getReviewTime() {
        return reviewTime;
    }

    public void setReviewTime(Date reviewTime) {
        this.reviewTime = reviewTime;
    }

    public String getReviewOpinion() {
        return reviewOpinion;
    }

    public void setReviewOpinion(String reviewOpinion) {
        this.reviewOpinion = reviewOpinion == null ? null : reviewOpinion.trim();
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
        sb.append(", reportNo=").append(reportNo);
        sb.append(", patientName=").append(patientName);
        sb.append(", gender=").append(gender);
        sb.append(", age=").append(age);
        sb.append(", idCard=").append(idCard);
        sb.append(", phone=").append(phone);
        sb.append(", examinationType=").append(examinationType);
        sb.append(", bodyPart=").append(bodyPart);
        sb.append(", clinicalDiagnosis=").append(clinicalDiagnosis);
        sb.append(", examinationFindings=").append(examinationFindings);
        sb.append(", diagnosticOpinion=").append(diagnosticOpinion);
        sb.append(", reportStatus=").append(reportStatus);
        sb.append(", reportDate=").append(reportDate);
        sb.append(", reviewerId=").append(reviewerId);
        sb.append(", reviewTime=").append(reviewTime);
        sb.append(", reviewOpinion=").append(reviewOpinion);
        sb.append(", gmtCreate=").append(gmtCreate);
        sb.append(", gmtModified=").append(gmtModified);
        sb.append(", serialVersionUID=").append(serialVersionUID);
        sb.append("]");
        return sb.toString();
    }
}
