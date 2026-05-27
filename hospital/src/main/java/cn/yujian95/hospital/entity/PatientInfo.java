package cn.yujian95.hospital.entity;

import io.swagger.annotations.ApiModelProperty;
import java.io.Serializable;
import java.util.Date;

public class PatientInfo implements Serializable {
    /**
     * 患者编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "患者编号")
    private Long id;

    /**
     * 关联账号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "关联账号")
    private Long accountId;

    /**
     * 患者姓名
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "患者姓名")
    private String name;

    /**
     * 性别：1，男；2，女
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "性别：1，男；2，女")
    private Integer gender;

    /**
     * 手机号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "手机号")
    private String phone;

    /**
     * 身份证号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "身份证号")
    private String idCard;

    /**
     * 出生日期
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "出生日期")
    private Date birthDate;

    /**
     * 地址
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "地址")
    private String address;

    /**
     * 血型
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "血型")
    private String bloodType;

    /**
     * 过敏史
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "过敏史")
    private String allergyHistory;

    /**
     * 病史
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "病史")
    private String medicalHistory;

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

    public Long getAccountId() {
        return accountId;
    }

    public void setAccountId(Long accountId) {
        this.accountId = accountId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name == null ? null : name.trim();
    }

    public Integer getGender() {
        return gender;
    }

    public void setGender(Integer gender) {
        this.gender = gender;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone == null ? null : phone.trim();
    }

    public String getIdCard() {
        return idCard;
    }

    public void setIdCard(String idCard) {
        this.idCard = idCard == null ? null : idCard.trim();
    }

    public Date getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(Date birthDate) {
        this.birthDate = birthDate;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address == null ? null : address.trim();
    }

    public String getBloodType() {
        return bloodType;
    }

    public void setBloodType(String bloodType) {
        this.bloodType = bloodType == null ? null : bloodType.trim();
    }

    public String getAllergyHistory() {
        return allergyHistory;
    }

    public void setAllergyHistory(String allergyHistory) {
        this.allergyHistory = allergyHistory == null ? null : allergyHistory.trim();
    }

    public String getMedicalHistory() {
        return medicalHistory;
    }

    public void setMedicalHistory(String medicalHistory) {
        this.medicalHistory = medicalHistory == null ? null : medicalHistory.trim();
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
        sb.append(", accountId=").append(accountId);
        sb.append(", name=").append(name);
        sb.append(", gender=").append(gender);
        sb.append(", phone=").append(phone);
        sb.append(", idCard=").append(idCard);
        sb.append(", birthDate=").append(birthDate);
        sb.append(", address=").append(address);
        sb.append(", bloodType=").append(bloodType);
        sb.append(", allergyHistory=").append(allergyHistory);
        sb.append(", medicalHistory=").append(medicalHistory);
        sb.append(", gmtCreate=").append(gmtCreate);
        sb.append(", gmtModified=").append(gmtModified);
        sb.append(", serialVersionUID=").append(serialVersionUID);
        sb.append("]");
        return sb.toString();
    }
}
