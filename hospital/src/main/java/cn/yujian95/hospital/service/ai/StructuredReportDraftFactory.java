package cn.yujian95.hospital.service.ai;

import cn.yujian95.hospital.dto.ai.StructuredReportDraft;
import cn.yujian95.hospital.entity.AiAnalysisResult;
import cn.yujian95.hospital.entity.MedicalImaging;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class StructuredReportDraftFactory {

    public StructuredReportDraft createDraft(MedicalImaging imaging, List<AiAnalysisResult> results) {
        StructuredReportDraft draft = new StructuredReportDraft();
        draft.setImagingId(imaging.getId());
        draft.setPatientId(imaging.getPatientId());
        draft.setExaminationType(nullToDefault(imaging.getImagingType(), "影像"));
        draft.setBodyPart(nullToDefault(imaging.getBodyPart(), "未注明部位"));
        draft.setClinicalDiagnosis(nullToDefault(imaging.getDescription(), ""));

        StringBuilder findings = new StringBuilder();
        findings.append(draft.getBodyPart()).append(" ").append(draft.getExaminationType()).append(" 检查。");
        StringBuilder aiSuggestion = new StringBuilder("AI 辅助提示仅供医生参考：");
        JSONArray resultRefs = new JSONArray();

        for (AiAnalysisResult result : results) {
            if (result.getConfirmStatus() == null || result.getConfirmStatus() != 1) {
                continue;
            }
            JSONObject json = parse(result.getResultJson());
            resultRefs.add(resultSummary(result, json));
            if ("segmentation".equals(result.getTaskType())) {
                appendMeasurements(findings, json, result);
            } else if ("detection".equals(result.getTaskType())) {
                appendDetection(aiSuggestion, json, result);
            } else if ("classification".equals(result.getTaskType())) {
                appendClassification(aiSuggestion, json, result);
            }
        }

        draft.setExaminationFindings(findings.toString());
        draft.setAiSuggestion(aiSuggestion.toString());
        draft.setDiagnosticOpinion("");
        JSONObject content = new JSONObject(true);
        content.put("imaging_id", imaging.getId());
        content.put("ai_results", resultRefs);
        content.put("doctor_confirmation_required", true);
        draft.setContentJson(content.toJSONString());
        return draft;
    }

    private void appendMeasurements(StringBuilder findings, JSONObject json, AiAnalysisResult result) {
        JSONObject measurements = json.getJSONObject("measurements");
        if (measurements == null) {
            return;
        }
        findings.append(" 经医生确认的 AI 分割结果提示病灶")
                .append("长径约 ").append(measurements.getString("long_diameter_mm")).append(" mm，")
                .append("短径约 ").append(measurements.getString("short_diameter_mm")).append(" mm，")
                .append("面积约 ").append(measurements.getString("area_mm2")).append(" mm²，")
                .append("体积约 ").append(measurements.getString("volume_cm3")).append(" cm³。")
                .append("分割模型：").append(result.getModelName()).append(" ").append(result.getModelVersion()).append("。");
    }

    private void appendDetection(StringBuilder aiSuggestion, JSONObject json, AiAnalysisResult result) {
        JSONArray boxes = json.getJSONArray("boxes");
        int count = boxes == null ? 0 : boxes.size();
        aiSuggestion.append(" 检测模型 ").append(result.getModelName()).append(" 提供 ")
                .append(count).append(" 个候选框；");
    }

    private void appendClassification(StringBuilder aiSuggestion, JSONObject json, AiAnalysisResult result) {
        aiSuggestion.append(" 分类模型 ").append(result.getModelName()).append(" 提示 ")
                .append(json.getString("label")).append("，置信度 ")
                .append(json.getString("confidence")).append("；");
    }

    private JSONObject resultSummary(AiAnalysisResult result, JSONObject json) {
        JSONObject summary = new JSONObject(true);
        summary.put("result_id", result.getResultId());
        summary.put("task_type", result.getTaskType());
        summary.put("model", result.getModelName() + " " + result.getModelVersion());
        summary.put("confidence", result.getConfidence());
        summary.put("confirmed", result.getConfirmStatus());
        summary.put("payload", json);
        return summary;
    }

    private JSONObject parse(String text) {
        try {
            return JSON.parseObject(text);
        } catch (Exception e) {
            return new JSONObject(true);
        }
    }

    private String nullToDefault(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value;
    }
}
