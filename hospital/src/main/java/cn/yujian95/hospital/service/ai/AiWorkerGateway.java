package cn.yujian95.hospital.service.ai;

import cn.yujian95.hospital.dto.ai.AiInferRequest;
import cn.yujian95.hospital.dto.ai.AiResultPayload;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.*;

@Component
public class AiWorkerGateway {
    private static final double DEFAULT_PIXEL_SPACING_MM = 0.6934D;

    private final RestTemplate restTemplate;
    private final ObjectStorageService objectStorageService;
    private String segmentationBaseUrl;

    @Autowired
    public AiWorkerGateway(ObjectStorageService objectStorageService) {
        this(new RestTemplate(), objectStorageService, null);
    }

    public AiWorkerGateway(RestTemplate restTemplate, ObjectStorageService objectStorageService, String segmentationBaseUrl) {
        this.restTemplate = restTemplate;
        this.objectStorageService = objectStorageService;
        this.segmentationBaseUrl = normalizeBaseUrl(segmentationBaseUrl);
    }

    @Value("${ai.worker.segmentation-url:http://127.0.0.1:5000}")
    public void setSegmentationBaseUrl(String segmentationBaseUrl) {
        if (this.segmentationBaseUrl == null || this.segmentationBaseUrl.trim().isEmpty()) {
            this.segmentationBaseUrl = normalizeBaseUrl(segmentationBaseUrl);
        }
    }

    public Optional<AiResultPayload> infer(String taskType, AiInferRequest request) {
        if (!"segmentation".equals(normalizeTaskType(taskType))) {
            return Optional.empty();
        }
        try {
            return callSegmentationWorker(request);
        } catch (Exception ex) {
            return Optional.empty();
        }
    }

    public String workerState(String taskType) {
        if (!"segmentation".equals(normalizeTaskType(taskType))) {
            return "DEMO_READY";
        }
        try {
            ResponseEntity<Map> response = restTemplate.getForEntity(baseUrl() + "/health", Map.class);
            return response.getStatusCode().is2xxSuccessful() ? "UP" : "DOWN";
        } catch (Exception ex) {
            return "DEMO_READY";
        }
    }

    private Optional<AiResultPayload> callSegmentationWorker(AiInferRequest request) throws Exception {
        JSONObject prompt = parseJson(request.getPromptJson());
        String promptType = prompt.getString("type");
        if (promptType == null || promptType.trim().isEmpty()) {
            promptType = "box";
        }

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("image", placeholderImage(prompt));
        body.put("imaging_id", request.getImagingId());

        String endpoint;
        if ("point".equalsIgnoreCase(promptType)) {
            endpoint = "/api/segment/point";
            body.put("points", prompt.getJSONArray("points"));
            body.put("labels", prompt.getJSONArray("labels"));
        } else if ("text".equalsIgnoreCase(promptType)) {
            endpoint = "/api/segment/text";
            body.put("text", prompt.getString("text"));
        } else {
            endpoint = "/api/segment/box";
            body.put("box", promptBox(prompt));
        }

        ResponseEntity<Map> response = restTemplate.postForEntity(baseUrl() + endpoint, body, Map.class);
        if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
            return Optional.empty();
        }
        Map result = response.getBody();
        if (!Boolean.TRUE.equals(result.get("success"))) {
            return Optional.empty();
        }

        return Optional.of(toPayload(request, prompt, result));
    }

    private AiResultPayload toPayload(AiInferRequest request, JSONObject prompt, Map workerResult) throws Exception {
        String modelId = request.getModelId() == null ? "medsam_v1.0" : request.getModelId();
        Integer sliceIndex = sliceIndex(prompt);
        JSONArray box = promptBox(prompt);
        String maskUri = objectStorageService.uploadBytes(decodeDataUrl(String.valueOf(workerResult.get("mask"))),
                "masks/" + request.getImagingId(), modelId + "-mask.png", "image/png");
        String overlayUri = objectStorageService.uploadBytes(decodeDataUrl(String.valueOf(workerResult.get("result_image"))),
                "overlays/" + request.getImagingId(), modelId + "-overlay.png", "image/png");

        JSONObject measurements = measurements(workerResult, box);
        JSONObject result = new JSONObject(true);
        result.put("mask_uri", maskUri);
        result.put("overlay_uri", overlayUri);
        result.put("prompt_box", box);
        result.put("coord_space", prompt.getString("coord_space") == null ? "viewer" : prompt.getString("coord_space"));
        result.put("slice_index", sliceIndex);
        result.put("mask_area_px", numeric(workerResult.get("area"), 0D));
        result.put("measurements", measurements);
        result.put("worker", "medsam-service");
        result.put("worker_endpoint", baseUrl());
        result.put("postprocess", "worker_mask+measurement");

        AiResultPayload payload = new AiResultPayload();
        payload.setTaskType("segmentation");
        payload.setModelId(modelId);
        payload.setModelName("MedSAM");
        payload.setModelVersion("v1.0");
        payload.setConfidence(numeric(workerResult.get("confidence"), 0.0D));
        payload.setResultJson(result.toJSONString());
        return payload;
    }

    private JSONObject measurements(Map workerResult, JSONArray box) {
        int width = Math.max(1, box.getInteger(2) - box.getInteger(0));
        int height = Math.max(1, box.getInteger(3) - box.getInteger(1));
        double areaPx = numeric(workerResult.get("area"), (double) width * height);
        double area = round(areaPx * DEFAULT_PIXEL_SPACING_MM * DEFAULT_PIXEL_SPACING_MM, 1);
        double longDiameter = round(Math.max(width, height) * DEFAULT_PIXEL_SPACING_MM, 1);
        double shortDiameter = round(Math.min(width, height) * DEFAULT_PIXEL_SPACING_MM, 1);

        JSONObject measurements = new JSONObject(true);
        measurements.put("area_mm2", area);
        measurements.put("volume_cm3", round(area * 3D / 1000D, 2));
        measurements.put("long_diameter_mm", longDiameter);
        measurements.put("short_diameter_mm", shortDiameter);
        return measurements;
    }

    private String placeholderImage(JSONObject prompt) throws Exception {
        BufferedImage image = new BufferedImage(512, 512, BufferedImage.TYPE_INT_RGB);
        Graphics2D graphics = image.createGraphics();
        try {
            graphics.setColor(Color.BLACK);
            graphics.fillRect(0, 0, 512, 512);
            graphics.setColor(new Color(80, 80, 80));
            JSONArray box = promptBox(prompt);
            graphics.fillRect(box.getInteger(0), box.getInteger(1),
                    Math.max(1, box.getInteger(2) - box.getInteger(0)),
                    Math.max(1, box.getInteger(3) - box.getInteger(1)));
        } finally {
            graphics.dispose();
        }
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        ImageIO.write(image, "png", output);
        return "data:image/png;base64," + Base64.getEncoder().encodeToString(output.toByteArray());
    }

    private byte[] decodeDataUrl(String value) {
        String raw = value == null ? "" : value.trim();
        int comma = raw.indexOf(',');
        if (comma >= 0) {
            raw = raw.substring(comma + 1);
        }
        return Base64.getDecoder().decode(raw);
    }

    private JSONObject parseJson(String value) {
        try {
            return JSON.parseObject(value);
        } catch (Exception ignored) {
            return new JSONObject(true);
        }
    }

    private JSONArray promptBox(JSONObject prompt) {
        JSONArray coords = prompt.getJSONArray("coords");
        if (coords != null && coords.size() == 4) {
            return coords;
        }
        return JSONArray.parseArray("[120,96,286,260]");
    }

    private Integer sliceIndex(JSONObject prompt) {
        Integer value = prompt.getInteger("slice_index");
        return value == null ? 0 : value;
    }

    private double numeric(Object value, double fallback) {
        if (value instanceof Number) {
            return ((Number) value).doubleValue();
        }
        try {
            return Double.parseDouble(String.valueOf(value));
        } catch (Exception ignored) {
            return fallback;
        }
    }

    private double round(double value, int scale) {
        double factor = Math.pow(10, scale);
        return Math.round(value * factor) / factor;
    }

    private String baseUrl() {
        return segmentationBaseUrl == null || segmentationBaseUrl.trim().isEmpty()
                ? "http://127.0.0.1:5000" : segmentationBaseUrl;
    }

    private String normalizeBaseUrl(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        while (trimmed.endsWith("/")) {
            trimmed = trimmed.substring(0, trimmed.length() - 1);
        }
        return trimmed;
    }

    private String normalizeTaskType(String taskType) {
        return taskType == null ? "" : taskType.trim().toLowerCase();
    }
}
