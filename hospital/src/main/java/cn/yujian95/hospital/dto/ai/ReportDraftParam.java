package cn.yujian95.hospital.dto.ai;

import com.fasterxml.jackson.annotation.JsonAlias;

import java.io.Serializable;
import java.util.List;

public class ReportDraftParam implements Serializable {
    @JsonAlias("imaging_id")
    private Long imagingId;
    @JsonAlias("study_record_id")
    private Long studyRecordId;
    @JsonAlias("selected_result_ids")
    private List<Long> selectedResultIds;

    public Long getImagingId() { return imagingId; }
    public void setImagingId(Long imagingId) { this.imagingId = imagingId; }
    public Long getStudyRecordId() { return studyRecordId; }
    public void setStudyRecordId(Long studyRecordId) { this.studyRecordId = studyRecordId; }
    public List<Long> getSelectedResultIds() { return selectedResultIds; }
    public void setSelectedResultIds(List<Long> selectedResultIds) { this.selectedResultIds = selectedResultIds; }
}
