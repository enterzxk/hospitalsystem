package cn.yujian95.hospital.dto.ai;

import java.io.Serializable;

public class ConfirmResultParam implements Serializable {
    private Integer decision;
    private Long doctorId;
    private String comment;

    public Integer getDecision() { return decision; }
    public void setDecision(Integer decision) { this.decision = decision; }
    public Long getDoctorId() { return doctorId; }
    public void setDoctorId(Long doctorId) { this.doctorId = doctorId; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
}
