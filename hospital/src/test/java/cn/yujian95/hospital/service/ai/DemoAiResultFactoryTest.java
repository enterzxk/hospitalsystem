package cn.yujian95.hospital.service.ai;

import cn.yujian95.hospital.dto.ai.AiInferRequest;
import cn.yujian95.hospital.dto.ai.AiResultPayload;
import cn.yujian95.hospital.dto.ai.ReportDraftParam;
import cn.yujian95.hospital.dto.ai.StructuredReportDraft;
import cn.yujian95.hospital.entity.AiAnalysisResult;
import cn.yujian95.hospital.entity.InferenceJob;
import cn.yujian95.hospital.entity.MedicalImaging;
import cn.yujian95.hospital.entity.ModelRegistry;
import cn.yujian95.hospital.entity.Study;
import cn.yujian95.hospital.mapper.AiAnalysisResultMapper;
import cn.yujian95.hospital.mapper.InferenceJobMapper;
import cn.yujian95.hospital.mapper.MedicalImagingMapper;
import cn.yujian95.hospital.mapper.ModelRegistryMapper;
import cn.yujian95.hospital.mapper.StudyMapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.sun.net.httpserver.HttpServer;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.util.Arrays;
import java.util.Optional;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

public class DemoAiResultFactoryTest {

    @Test
    public void createsStableDetectionBoxesForSamePrompt() {
        DemoAiResultFactory factory = new DemoAiResultFactory();
        AiInferRequest request = new AiInferRequest();
        request.setStudyId("ST001");
        request.setSeriesId("SE001");
        request.setInstanceId("IM120");
        request.setModelId("lesion_det_demo_v1");
        request.setTaskType("detection");
        request.setImagingId(10001L);
        request.setPromptJson("{\"type\":\"box\",\"coords\":[120,96,286,260],\"slice_index\":239}");

        AiResultPayload first = factory.createResult("detection", request);
        AiResultPayload second = factory.createResult("detection", request);

        assertEquals(first.getResultJson(), second.getResultJson());
        JSONObject result = JSON.parseObject(first.getResultJson());
        JSONArray boxes = result.getJSONArray("boxes");
        assertEquals(3, boxes.size());
        assertEquals("nodule_candidate", boxes.getJSONObject(0).getString("label"));
        assertTrue(boxes.getJSONObject(0).getDoubleValue("confidence") >= 0.80D);
    }

    @Test
    public void createsSegmentationMeasurementsFromSelectedBox() {
        DemoAiResultFactory factory = new DemoAiResultFactory();
        AiInferRequest request = new AiInferRequest();
        request.setModelId("medsam_v1.0");
        request.setTaskType("segmentation");
        request.setImagingId(10001L);
        request.setInstanceId("IM120");
        request.setPromptJson("{\"type\":\"box\",\"coords\":[120,96,286,260],\"slice_index\":239}");

        AiResultPayload payload = factory.createResult("segmentation", request);
        JSONObject result = JSON.parseObject(payload.getResultJson());
        JSONObject measurements = result.getJSONObject("measurements");

        assertEquals("minio://medical-imaging/masks/10001/IM120/239/medsam_v1.0.png", result.getString("mask_uri"));
        assertEquals(Arrays.asList(120, 96, 286, 260), result.getJSONArray("prompt_box").toJavaList(Integer.class));
        assertTrue(measurements.getDoubleValue("area_mm2") > 0D);
        assertTrue(measurements.getDoubleValue("volume_cm3") > 0D);
        assertTrue(measurements.getDoubleValue("long_diameter_mm") >= measurements.getDoubleValue("short_diameter_mm"));
    }

    @Test
    public void medsamGatewayConvertsWorkerBoxSegmentationToUnifiedPayload() throws Exception {
        HttpServer server = workerReturning("{\"success\":true,\"mask\":\"data:image/png;base64,bWFzaw==\",\"result_image\":\"data:image/png;base64,b3ZlcmxheQ==\",\"area\":2500,\"confidence\":0.93}");
        try {
            AiInferRequest request = new AiInferRequest();
            request.setTaskType("segmentation");
            request.setModelId("medsam_v1.0");
            request.setImagingId(10001L);
            request.setInstanceId("IM120");
            request.setPromptJson("{\"type\":\"box\",\"coords\":[120,96,286,260],\"slice_index\":239}");

            AiWorkerGateway gateway = new AiWorkerGateway(new RestTemplate(), new FakeObjectStorageService(),
                    "http://127.0.0.1:" + server.getAddress().getPort());

            Optional<AiResultPayload> payload = gateway.infer("segmentation", request);

            assertTrue(payload.isPresent());
            assertEquals("segmentation", payload.get().getTaskType());
            assertEquals("MedSAM", payload.get().getModelName());
            assertEquals(Double.valueOf(0.93D), payload.get().getConfidence());

            JSONObject result = JSON.parseObject(payload.get().getResultJson());
            assertEquals("medsam-service", result.getString("worker"));
            assertEquals("minio://medical-imaging/worker/mask.png", result.getString("mask_uri"));
            assertEquals("minio://medical-imaging/worker/overlay.png", result.getString("overlay_uri"));
            assertEquals(Arrays.asList(120, 96, 286, 260), result.getJSONArray("prompt_box").toJavaList(Integer.class));
            assertTrue(result.getJSONObject("measurements").getDoubleValue("area_mm2") > 0D);
        } finally {
            server.stop(0);
        }
    }

    @Test
    public void createInferenceJobResolvesStudySeriesInstanceUidsToRecordIds() {
        AiPlatformService service = new AiPlatformService();
        InferenceJobMapper jobMapper = mock(InferenceJobMapper.class);
        AiAnalysisResultMapper resultMapper = mock(AiAnalysisResultMapper.class);
        ModelRegistryMapper modelMapper = mock(ModelRegistryMapper.class);
        StudyMapper studyMapper = mock(StudyMapper.class);
        ArgumentCaptor<InferenceJob> jobCaptor = ArgumentCaptor.forClass(InferenceJob.class);
        ArgumentCaptor<AiAnalysisResult> resultCaptor = ArgumentCaptor.forClass(AiAnalysisResult.class);

        when(jobMapper.insertSelective(jobCaptor.capture())).thenReturn(1);
        when(resultMapper.insertSelective(resultCaptor.capture())).thenReturn(1);
        ModelRegistry model = new ModelRegistry();
        model.setName("MedSAM");
        model.setVersion("v1.0");
        when(modelMapper.selectByModelId("medsam_v1.0")).thenReturn(model);
        Study study = new Study();
        study.setId(11L);
        study.setImagingId(10001L);
        when(studyMapper.selectByPrimaryKey(11L)).thenReturn(study);

        ReflectionTestUtils.setField(service, "inferenceJobMapper", jobMapper);
        ReflectionTestUtils.setField(service, "resultMapper", resultMapper);
        ReflectionTestUtils.setField(service, "modelRegistryMapper", modelMapper);
        ReflectionTestUtils.setField(service, "studyMapper", studyMapper);
        ReflectionTestUtils.setField(service, "auditTrailService", new AuditTrailService());
        ReflectionTestUtils.setField(service, "jdbcTemplate", new UidLookupJdbcTemplate());
        ReflectionTestUtils.setField(service, "aiWorkerGateway", new PayloadGateway());

        AiInferRequest request = new AiInferRequest();
        request.setImagingId(10001L);
        request.setStudyId("ST001");
        request.setSeriesId("SE001");
        request.setInstanceId("IM120");
        request.setModelId("medsam_v1.0");
        request.setPromptJson("{\"type\":\"box\",\"coords\":[120,96,286,260]}");
        request.setUserId(1L);

        service.createInferenceJob("segmentation", request);

        assertEquals(Long.valueOf(11L), jobCaptor.getValue().getStudyId());
        assertEquals(Long.valueOf(22L), jobCaptor.getValue().getSeriesId());
        assertEquals(Long.valueOf(33L), jobCaptor.getValue().getInstanceId());
        assertEquals(Long.valueOf(11L), resultCaptor.getValue().getStudyId());
        assertEquals(Long.valueOf(22L), resultCaptor.getValue().getSeriesId());
        assertEquals(Long.valueOf(33L), resultCaptor.getValue().getInstanceId());
        assertEquals("instance://IM120", jobCaptor.getValue().getInputRef());
    }

    @Test
    public void createInferenceJobUsesCompatibleImagingIdWhenOnlyStudyRecordIsProvided() {
        AiPlatformService service = new AiPlatformService();
        InferenceJobMapper jobMapper = mock(InferenceJobMapper.class);
        AiAnalysisResultMapper resultMapper = mock(AiAnalysisResultMapper.class);
        ModelRegistryMapper modelMapper = mock(ModelRegistryMapper.class);
        StudyMapper studyMapper = mock(StudyMapper.class);
        ArgumentCaptor<InferenceJob> jobCaptor = ArgumentCaptor.forClass(InferenceJob.class);
        ArgumentCaptor<AiAnalysisResult> resultCaptor = ArgumentCaptor.forClass(AiAnalysisResult.class);

        Study study = new Study();
        study.setId(4L);
        study.setImagingId(44L);
        when(studyMapper.selectByPrimaryKey(4L)).thenReturn(study);
        when(jobMapper.insertSelective(jobCaptor.capture())).thenReturn(1);
        when(resultMapper.insertSelective(resultCaptor.capture())).thenReturn(1);
        when(modelMapper.selectByModelId("medsam_v1.0")).thenReturn(null);

        ReflectionTestUtils.setField(service, "inferenceJobMapper", jobMapper);
        ReflectionTestUtils.setField(service, "resultMapper", resultMapper);
        ReflectionTestUtils.setField(service, "modelRegistryMapper", modelMapper);
        ReflectionTestUtils.setField(service, "studyMapper", studyMapper);
        ReflectionTestUtils.setField(service, "auditTrailService", new AuditTrailService());
        ReflectionTestUtils.setField(service, "aiWorkerGateway", new PayloadGateway());

        AiInferRequest request = new AiInferRequest();
        request.setStudyRecordId(4L);
        request.setModelId("medsam_v1.0");
        request.setPromptJson("{\"type\":\"box\",\"coords\":[120,96,286,260]}");

        service.createInferenceJob("segmentation", request);

        assertEquals(Long.valueOf(44L), jobCaptor.getValue().getImagingId());
        assertEquals(Long.valueOf(44L), resultCaptor.getValue().getImagingId());
        assertEquals(Long.valueOf(4L), jobCaptor.getValue().getStudyId());
    }

    @Test
    public void reportDraftCanBeCreatedFromStudyRecordIdWithoutFrontendDemoImagingId() {
        AiPlatformService service = new AiPlatformService();
        StudyMapper studyMapper = mock(StudyMapper.class);
        MedicalImagingMapper imagingMapper = mock(MedicalImagingMapper.class);
        AiAnalysisResultMapper resultMapper = mock(AiAnalysisResultMapper.class);

        Study study = new Study();
        study.setId(4L);
        study.setImagingId(44L);
        when(studyMapper.selectByPrimaryKey(4L)).thenReturn(study);

        MedicalImaging imaging = new MedicalImaging();
        imaging.setId(44L);
        imaging.setPatientId(30003L);
        imaging.setImagingType("MRI");
        imaging.setBodyPart("腰椎");
        when(imagingMapper.selectByPrimaryKey(44L)).thenReturn(imaging);

        AiAnalysisResult segmentation = new AiAnalysisResult();
        segmentation.setTaskType("segmentation");
        segmentation.setModelName("MedSAM");
        segmentation.setModelVersion("v1.0");
        segmentation.setConfirmStatus(1);
        segmentation.setResultJson("{\"measurements\":{\"area_mm2\":120.5,\"volume_cm3\":1.2,\"long_diameter_mm\":14.1,\"short_diameter_mm\":9.8}}");
        when(resultMapper.selectByImagingId(44L)).thenReturn(Arrays.asList(segmentation));

        ReflectionTestUtils.setField(service, "studyMapper", studyMapper);
        ReflectionTestUtils.setField(service, "medicalImagingMapper", imagingMapper);
        ReflectionTestUtils.setField(service, "resultMapper", resultMapper);
        ReflectionTestUtils.setField(service, "reportDraftFactory", new StructuredReportDraftFactory());
        ReflectionTestUtils.setField(service, "auditTrailService", new AuditTrailService());

        ReportDraftParam param = new ReportDraftParam();
        param.setStudyRecordId(4L);

        StructuredReportDraft draft = service.createReportDraft(param);

        assertEquals(Long.valueOf(44L), draft.getImagingId());
        assertEquals(Long.valueOf(30003L), draft.getPatientId());
        assertTrue(draft.getExaminationFindings().contains("腰椎 MRI"));
        assertFalse(draft.getDiagnosticOpinion().contains("MRI"));
    }

    @Test
    public void aiInferRequestAcceptsDocumentSnakeCasePayload() throws Exception {
        String documentPayload = "{" +
                "\"study_id\":\"ST001\"," +
                "\"series_id\":\"SE001\"," +
                "\"instance_id\":\"IM120\"," +
                "\"model_id\":\"medsam_v1.0\"," +
                "\"task_type\":\"segmentation\"," +
                "\"prompt\":{\"type\":\"box\",\"coords\":[120,96,286,260],\"coord_space\":\"viewer\",\"slice_index\":239}," +
                "\"preprocess\":{\"window_width\":400,\"window_level\":40,\"resize\":1024}" +
                "}";

        AiInferRequest request = new ObjectMapper().readValue(documentPayload, AiInferRequest.class);

        assertEquals("ST001", request.getStudyId());
        assertEquals("SE001", request.getSeriesId());
        assertEquals("IM120", request.getInstanceId());
        assertEquals("medsam_v1.0", request.getModelId());
        assertEquals("segmentation", request.getTaskType());
        assertEquals("box", JSON.parseObject(request.getPromptJson()).getString("type"));
        assertEquals(Integer.valueOf(400), JSON.parseObject(request.getPreprocessJson()).getInteger("window_width"));
    }

    private HttpServer workerReturning(String responseBody) throws IOException {
        HttpServer server = HttpServer.create(new InetSocketAddress("127.0.0.1", 0), 0);
        server.createContext("/api/segment/box", exchange -> {
            byte[] body = responseBody.getBytes("UTF-8");
            exchange.getResponseHeaders().add("Content-Type", "application/json;charset=UTF-8");
            exchange.sendResponseHeaders(200, body.length);
            try (OutputStream os = exchange.getResponseBody()) {
                os.write(body);
            }
        });
        server.start();
        return server;
    }

    private static class PayloadGateway extends AiWorkerGateway {
        PayloadGateway() {
            super(new RestTemplate(), new FakeObjectStorageService(), "http://127.0.0.1:5000");
        }

        @Override
        public Optional<AiResultPayload> infer(String taskType, AiInferRequest request) {
            AiResultPayload payload = new AiResultPayload();
            payload.setTaskType(taskType);
            payload.setModelId(request.getModelId());
            payload.setModelName("MedSAM");
            payload.setModelVersion("v1.0");
            payload.setConfidence(0.91D);
            payload.setResultJson("{\"worker\":\"medsam-service\"}");
            return Optional.of(payload);
        }
    }

    private static class UidLookupJdbcTemplate extends JdbcTemplate {
        @Override
        public <T> T queryForObject(String sql, Class<T> requiredType, Object... args) {
            if (sql.contains("studies") && "ST001".equals(args[0])) {
                return requiredType.cast(11L);
            }
            if (sql.contains("series") && "SE001".equals(args[0])) {
                return requiredType.cast(22L);
            }
            if (sql.contains("instances") && "IM120".equals(args[0])) {
                return requiredType.cast(33L);
            }
            return null;
        }
    }

    private static class FakeObjectStorageService extends ObjectStorageService {
        @Override
        public String uploadBytes(byte[] bytes, String category, String fileName, String contentType) {
            if (fileName.contains("overlay")) {
                return "minio://medical-imaging/worker/overlay.png";
            }
            return "minio://medical-imaging/worker/mask.png";
        }
    }
}
