package cn.yujian95.hospital.dto.ai;

import cn.yujian95.hospital.entity.MedicalImaging;
import cn.yujian95.hospital.entity.Study;
import cn.yujian95.hospital.entity.StudyInstance;
import cn.yujian95.hospital.entity.StudySeries;

import java.io.Serializable;

public class StudyUploadResult implements Serializable {
    private Study study;
    private StudySeries series;
    private StudyInstance instance;
    private MedicalImaging compatibleImaging;

    public Study getStudy() { return study; }
    public void setStudy(Study study) { this.study = study; }
    public StudySeries getSeries() { return series; }
    public void setSeries(StudySeries series) { this.series = series; }
    public StudyInstance getInstance() { return instance; }
    public void setInstance(StudyInstance instance) { this.instance = instance; }
    public MedicalImaging getCompatibleImaging() { return compatibleImaging; }
    public void setCompatibleImaging(MedicalImaging compatibleImaging) { this.compatibleImaging = compatibleImaging; }
}
