package cn.yujian95.hospital.service.ai;

import cn.yujian95.hospital.dto.ai.AiInferRequest;
import cn.yujian95.hospital.dto.ai.AiResultPayload;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Component
public class DemoAiResultFactory {

    public AiResultPayload createResult(String taskType, AiInferRequest request) {
        String normalizedTask = normalizeTaskType(taskType, request);
        if ("detection".equals(normalizedTask)) {
            return detectionResult(request);
        }
        if ("classification".equals(normalizedTask)) {
            return classificationResult(request);
        }
        return segmentationResult(request);
    }

    private AiResultPayload detectionResult(AiInferRequest request) {
        JSONArray boxes = new JSONArray();
        boxes.add(box("DET-1", "nodule_candidate", 0.91D, 118, 96, 286, 260, sliceIndex(request)));
        boxes.add(box("DET-2", "vascular_overlap", 0.84D, 310, 178, 382, 244, sliceIndex(request)));
        boxes.add(box("DET-3", "low_density_shadow", 0.80D, 214, 292, 284, 344, sliceIndex(request)));

        JSONObject result = new JSONObject(true);
        result.put("boxes", boxes);
        result.put("coord_space", "viewer");
        result.put("candidate_count", boxes.size());
        result.put("model_note", "demo worker: deterministic candidate boxes");
        return payload(request, "detection", "lesion_det_demo", "v1.0", 0.91D, result);
    }

    private AiResultPayload segmentationResult(AiInferRequest request) {
        JSONArray box = promptBox(request);
        int width = Math.max(1, box.getInteger(2) - box.getInteger(0));
        int height = Math.max(1, box.getInteger(3) - box.getInteger(1));
        double pixelArea = width * height * 0.36D;
        double area = round(pixelArea * 0.6934D * 0.6934D, 1);
        double longDiameter = round(Math.max(width, height) * 0.6934D, 1);
        double shortDiameter = round(Math.min(width, height) * 0.6934D, 1);
        double volume = round(area * 3D / 1000D, 2);

        JSONObject measurements = new JSONObject(true);
        measurements.put("area_mm2", area);
        measurements.put("volume_cm3", volume);
        measurements.put("long_diameter_mm", longDiameter);
        measurements.put("short_diameter_mm", shortDiameter);
        measurements.put("slice_range", Arrays.asList(sliceIndex(request) - 1, sliceIndex(request) + 1));

        JSONObject result = new JSONObject(true);
        result.put("mask_uri", objectUri("masks", request, ".png"));
        result.put("overlay_uri", objectUri("overlays", request, ".png"));
        result.put("prompt_box", box);
        result.put("coord_space", "viewer");
        result.put("measurements", measurements);
        result.put("postprocess", "connected_components+hole_fill+edge_smooth");
        return payload(request, "segmentation", "MedSAM", "v1.0", 0.92D, result);
    }

    private AiResultPayload classificationResult(AiInferRequest request) {
        JSONObject probability = new JSONObject(true);
        probability.put("疑似肺结节", 0.87D);
        probability.put("炎性改变", 0.09D);
        probability.put("血管重叠", 0.04D);

        JSONObject result = new JSONObject(true);
        result.put("label", "疑似肺结节");
        result.put("confidence", 0.87D);
        result.put("probability", probability);
        result.put("roi_ref", objectUri("rois", request, ".json"));
        result.put("model_note", "demo worker: ROI classification");
        return payload(request, "classification", "lesion_cls_demo", "v1.0", 0.87D, result);
    }

    private AiResultPayload payload(AiInferRequest request, String taskType, String modelName, String modelVersion,
                                    Double confidence, JSONObject result) {
        AiResultPayload payload = new AiResultPayload();
        payload.setTaskType(taskType);
        payload.setModelId(modelId(request));
        payload.setModelName(modelName);
        payload.setModelVersion(modelVersion);
        payload.setConfidence(confidence);
        payload.setResultJson(result.toJSONString());
        return payload;
    }

    private JSONObject box(String id, String label, Double confidence, int x1, int y1, int x2, int y2, int sliceIndex) {
        JSONObject box = new JSONObject(true);
        box.put("id", id);
        box.put("label", label);
        box.put("confidence", confidence);
        box.put("coords", Arrays.asList(x1, y1, x2, y2));
        box.put("slice_index", sliceIndex);
        box.put("status", "candidate");
        return box;
    }

    private String normalizeTaskType(String taskType, AiInferRequest request) {
        String value = taskType != null ? taskType : request.getTaskType();
        return value == null ? "segmentation" : value.trim().toLowerCase();
    }

    private JSONArray promptBox(AiInferRequest request) {
        try {
            JSONObject prompt = JSON.parseObject(request.getPromptJson());
            JSONArray coords = prompt.getJSONArray("coords");
            if (coords != null && coords.size() == 4) {
                return coords;
            }
        } catch (Exception ignored) {
        }
        return JSONArray.parseArray("[120,96,286,260]");
    }

    private Integer sliceIndex(AiInferRequest request) {
        try {
            JSONObject prompt = JSON.parseObject(request.getPromptJson());
            Integer slice = prompt.getInteger("slice_index");
            return slice == null ? 239 : slice;
        } catch (Exception ignored) {
            return 239;
        }
    }

    private Long imagingId(AiInferRequest request) {
        return request.getImagingId() == null ? 0L : request.getImagingId();
    }

    private String instanceId(AiInferRequest request) {
        return request.getInstanceId() == null ? "IM-DEMO" : request.getInstanceId();
    }

    private String modelId(AiInferRequest request) {
        return request.getModelId() == null ? "demo_model_v1" : request.getModelId();
    }

    private String objectUri(String category, AiInferRequest request, String suffix) {
        return "minio://medical-imaging/" + category + "/" + imagingId(request) + "/"
                + safePath(instanceId(request)) + "/" + sliceIndex(request) + "/" + safePath(modelId(request)) + suffix;
    }

    private String safePath(String value) {
        return value == null ? "unknown" : value.replaceAll("[^A-Za-z0-9._-]", "_");
    }

    private double round(double value, int scale) {
        double factor = Math.pow(10, scale);
        return Math.round(value * factor) / factor;
    }
}
