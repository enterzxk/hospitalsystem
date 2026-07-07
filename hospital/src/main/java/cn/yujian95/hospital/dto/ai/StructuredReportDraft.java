package cn.yujian95.hospital.dto.ai;

import java.io.Serializable;

public class StructuredReportDraft implements Serializable {
    private Long imagingId;
    private Long patientId;
    private String examinationType;
    private String bodyPart;
    private String clinicalDiagnosis;
    private String examinationFindings;
    private String aiSuggestion;
    private String diagnosticOpinion;
    private String contentJson;

    public Long getImagingId() { return imagingId; }
    public void setImagingId(Long imagingId) { this.imagingId = imagingId; }
    public Long getPatientId() { return patientId; }
    public void setPatientId(Long patientId) { this.patientId = patientId; }
    public String getExaminationType() { return examinationType; }
    public void setExaminationType(String examinationType) { this.examinationType = examinationType; }
    public String getBodyPart() { return bodyPart; }
    public void setBodyPart(String bodyPart) { this.bodyPart = bodyPart; }
    public String getClinicalDiagnosis() { return clinicalDiagnosis; }
    public void setClinicalDiagnosis(String clinicalDiagnosis) { this.clinicalDiagnosis = clinicalDiagnosis; }
    public String getExaminationFindings() { return examinationFindings; }
    public void setExaminationFindings(String examinationFindings) { this.examinationFindings = examinationFindings; }
    public String getAiSuggestion() { return aiSuggestion; }
    public void setAiSuggestion(String aiSuggestion) { this.aiSuggestion = aiSuggestion; }
    public String getDiagnosticOpinion() { return diagnosticOpinion; }
    public void setDiagnosticOpinion(String diagnosticOpinion) { this.diagnosticOpinion = diagnosticOpinion; }
    public String getContentJson() { return contentJson; }
    public void setContentJson(String contentJson) { this.contentJson = contentJson; }
}
