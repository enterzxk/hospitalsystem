package cn.yujian95.hospital.service.ai;

import cn.yujian95.hospital.dto.ai.StructuredReportDraft;
import cn.yujian95.hospital.entity.AiAnalysisResult;
import cn.yujian95.hospital.entity.MedicalImaging;
import org.junit.Test;

import java.util.Arrays;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

public class StructuredReportDraftFactoryTest {

    @Test
    public void buildsFindingsFromConfirmedAiResultsWithoutFinalDiagnosis() {
        MedicalImaging imaging = new MedicalImaging();
        imaging.setId(10001L);
        imaging.setPatientId(30001L);
        imaging.setImagingType("CT");
        imaging.setBodyPart("胸部");
        imaging.setDescription("胸部 CT 肺窗薄层扫描。");

        AiAnalysisResult segmentation = new AiAnalysisResult();
        segmentation.setTaskType("segmentation");
        segmentation.setModelName("MedSAM");
        segmentation.setModelVersion("v1.0");
        segmentation.setConfirmStatus(1);
        segmentation.setResultJson("{\"measurements\":{\"area_mm2\":862.4,\"volume_cm3\":2.8,\"long_diameter_mm\":23.4,\"short_diameter_mm\":18.1}}");

        AiAnalysisResult classification = new AiAnalysisResult();
        classification.setTaskType("classification");
        classification.setModelName("lesion_cls_demo");
        classification.setModelVersion("v1.0");
        classification.setConfirmStatus(1);
        classification.setResultJson("{\"label\":\"疑似肺结节\",\"confidence\":0.87}");

        StructuredReportDraft draft = new StructuredReportDraftFactory()
                .createDraft(imaging, Arrays.asList(segmentation, classification));

        assertTrue(draft.getExaminationFindings().contains("胸部 CT"));
        assertTrue(draft.getExaminationFindings().contains("长径约 23.4 mm"));
        assertTrue(draft.getAiSuggestion().contains("疑似肺结节"));
        assertFalse(draft.getDiagnosticOpinion().contains("肺结节"));
        assertTrue(draft.getDiagnosticOpinion().trim().isEmpty());
    }
}
