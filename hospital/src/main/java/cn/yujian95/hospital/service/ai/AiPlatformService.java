package cn.yujian95.hospital.service.ai;

import cn.yujian95.hospital.dto.ai.*;
import cn.yujian95.hospital.entity.*;
import cn.yujian95.hospital.mapper.*;
import com.alibaba.fastjson.JSON;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.concurrent.TimeUnit;

@Service
public class AiPlatformService {
    @Autowired
    private ModelRegistryMapper modelRegistryMapper;
    @Autowired
    private InferenceJobMapper inferenceJobMapper;
    @Autowired
    private AiAnalysisResultMapper resultMapper;
    @Autowired
    private AiPromptMapper promptMapper;
    @Autowired
    private StudyMapper studyMapper;
    @Autowired
    private MedicalImagingMapper medicalImagingMapper;
    @Autowired
    private DemoAiResultFactory demoAiResultFactory;
    @Autowired
    private StructuredReportDraftFactory reportDraftFactory;
    @Autowired
    private AuditTrailService auditTrailService;
    @Autowired
    private JdbcTemplate jdbcTemplate;
    @Autowired
    private StringRedisTemplate redisTemplate;
    @Autowired
    private ObjectStorageService objectStorageService;
    @Autowired
    private AiWorkerGateway aiWorkerGateway;

    public List<ModelRegistry> listModels(String taskType, String modality) {
        return modelRegistryMapper.selectList(taskType, modality);
    }

    public boolean saveModel(ModelRegistry model) {
        Date now = new Date();
        if (model.getStatus() == null) {
            model.setStatus(1);
        }
        if (model.getModelId() == null || model.getModelId().trim().isEmpty()) {
            model.setModelId(model.getName() + "_" + model.getVersion());
        }
        model.setGmtModified(now);
        if (model.getId() == null) {
            model.setGmtCreate(now);
            auditTrailService.record("system", "新增模型版本", "/api/models", JSON.toJSONString(model), model.getModelId());
            return modelRegistryMapper.insertSelective(model) > 0;
        }
        auditTrailService.record("system", "更新模型版本", "/api/models", JSON.toJSONString(model), model.getModelId());
        return modelRegistryMapper.updateByPrimaryKeySelective(model) > 0;
    }

    public AiPrompt savePrompt(AiPrompt prompt) {
        prompt.setVersion(prompt.getVersion() == null ? 1 : prompt.getVersion());
        prompt.setGmtCreate(new Date());
        promptMapper.insertSelective(prompt);
        auditTrailService.record("system", "保存影像 Prompt", "/api/prompts", JSON.toJSONString(prompt), String.valueOf(prompt.getId()));
        return prompt;
    }

    @Transactional
    public Map<String, Object> createInferenceJob(String taskType, AiInferRequest request) {
        Date now = new Date();
        String jobId = "JOB-" + now.getTime() + "-" + Math.abs(Objects.hash(taskType, request.getImagingId(), request.getPromptJson()));
        request.setTaskType(taskType);
        Long studyRecordId = resolveRecordId(request.getStudyRecordId(), request.getStudyId(),
                "select id from studies where study_uid = ? limit 1");
        Long seriesRecordId = resolveRecordId(request.getSeriesRecordId(), request.getSeriesId(),
                "select id from series where series_uid = ? limit 1");
        Long instanceRecordId = resolveRecordId(request.getInstanceRecordId(), request.getInstanceId(),
                "select id from instances where sop_uid = ? limit 1");
        Long compatibleImagingId = resolveCompatibleImagingId(request.getImagingId(), studyRecordId);
        if (compatibleImagingId == null) {
            throw new IllegalArgumentException("无法解析影像兼容记录，请先通过 /api/studies/upload 登记检查");
        }
        request.setImagingId(compatibleImagingId);
        InferenceJob job = new InferenceJob();
        job.setJobId(jobId);
        job.setTaskType(taskType);
        job.setModelId(request.getModelId());
        job.setImagingId(compatibleImagingId);
        job.setStudyId(studyRecordId);
        job.setSeriesId(seriesRecordId);
        job.setInstanceId(instanceRecordId);
        job.setInputRef(inputRef(request));
        job.setPromptJson(request.getPromptJson());
        job.setPreprocessJson(request.getPreprocessJson());
        job.setStatus(2);
        job.setProgress(100);
        job.setCreatedBy(request.getUserId());
        job.setGmtCreate(now);
        job.setGmtModified(now);
        inferenceJobMapper.insertSelective(job);
        publishJobState(job);

        AiResultPayload payload = aiWorkerGateway.infer(taskType, request)
                .orElseGet(() -> demoAiResultFactory.createResult(taskType, request));
        ModelRegistry model = modelRegistryMapper.selectByModelId(request.getModelId());
        AiAnalysisResult result = toResult(job, payload, model, now);
        resultMapper.insertSelective(result);

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("job", job);
        response.put("result", result);
        auditTrailService.record("system", "创建 AI 推理任务", "/api/ai/infer/" + taskType, JSON.toJSONString(request), result.getResultId());
        return response;
    }

    public Map<String, Object> getJob(String jobId) {
        InferenceJob job = inferenceJobMapper.selectByJobId(jobId);
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("job", job);
        if (job != null && job.getImagingId() != null) {
            response.put("results", resultMapper.selectByImagingId(job.getImagingId()));
        }
        return response;
    }

    public List<AiAnalysisResult> getResultsByImaging(Long imagingId) {
        return resultMapper.selectByImagingId(imagingId);
    }

    public AiAnalysisResult confirmResult(Long id, ConfirmResultParam param) {
        AiAnalysisResult result = new AiAnalysisResult();
        result.setId(id);
        result.setConfirmStatus(param.getDecision() == null ? 1 : param.getDecision());
        result.setConfirmedBy(param.getDoctorId());
        result.setConfirmedAt(new Date());
        result.setConfirmComment(param.getComment());
        result.setGmtModified(new Date());
        resultMapper.updateConfirmStatus(result);
        auditTrailService.record("system", "确认 AI 结果", "/api/results/" + id + "/confirm", JSON.toJSONString(param), String.valueOf(result.getConfirmStatus()));
        return resultMapper.selectByPrimaryKey(id);
    }

    public StructuredReportDraft createReportDraft(ReportDraftParam param) {
        Long imagingId = resolveCompatibleImagingId(param.getImagingId(), param.getStudyRecordId());
        if (imagingId == null) {
            throw new IllegalArgumentException("imagingId 或 studyRecordId 必须能解析到影像兼容记录");
        }
        MedicalImaging imaging = medicalImagingMapper.selectByPrimaryKey(imagingId);
        if (imaging == null) {
            throw new IllegalArgumentException("不存在该影像兼容记录：" + imagingId);
        }
        List<AiAnalysisResult> results;
        if (param.getSelectedResultIds() != null && !param.getSelectedResultIds().isEmpty()) {
            results = resultMapper.selectByIds(param.getSelectedResultIds());
        } else {
            results = resultMapper.selectByImagingId(imagingId);
        }
        StructuredReportDraft draft = reportDraftFactory.createDraft(imaging, results);
        auditTrailService.record("system", "生成结构化报告草稿", "/api/reports/draft", JSON.toJSONString(param), draft.getContentJson());
        return draft;
    }

    public Map<String, Object> opsStatus() {
        Map<String, Object> status = new LinkedHashMap<>();
        status.put("api", "UP");
        status.put("postgresql", postgresqlStatus());
        status.put("redis", redisStatus());
        status.put("objectStorage", objectStorageService.status());
        status.put("aiGateway", "UP");
        status.put("segmentationWorker", aiWorkerGateway.workerState("segmentation"));
        status.put("detectionWorker", aiWorkerGateway.workerState("detection"));
        status.put("classificationWorker", aiWorkerGateway.workerState("classification"));
        status.put("queueLength", queueLength());
        status.put("gpu", "OPTIONAL");
        status.put("checkedAt", new Date());
        return status;
    }

    private AiAnalysisResult toResult(InferenceJob job, AiResultPayload payload, ModelRegistry model, Date now) {
        AiAnalysisResult result = new AiAnalysisResult();
        result.setResultId("RES-" + now.getTime() + "-" + job.getTaskType());
        result.setJobId(job.getJobId());
        result.setTaskType(job.getTaskType());
        result.setImagingId(job.getImagingId());
        result.setStudyId(job.getStudyId());
        result.setSeriesId(job.getSeriesId());
        result.setInstanceId(job.getInstanceId());
        result.setModelId(payload.getModelId());
        result.setModelName(model == null ? payload.getModelName() : model.getName());
        result.setModelVersion(model == null ? payload.getModelVersion() : model.getVersion());
        result.setConfidence(payload.getConfidence());
        result.setResultJson(payload.getResultJson());
        result.setConfirmStatus(0);
        result.setGmtCreate(now);
        result.setGmtModified(now);
        return result;
    }

    private String inputRef(AiInferRequest request) {
        if (request.getInstanceId() != null) {
            return "instance://" + request.getInstanceId();
        }
        if (request.getInstanceRecordId() != null) {
            return "instance://" + request.getInstanceRecordId();
        }
        return "imaging://" + request.getImagingId();
    }

    private Long resolveRecordId(Long recordId, String uid, String sql) {
        if (recordId != null) {
            return recordId;
        }
        if (uid == null || uid.trim().isEmpty() || jdbcTemplate == null) {
            return null;
        }
        try {
            return jdbcTemplate.queryForObject(sql, Long.class, uid.trim());
        } catch (EmptyResultDataAccessException ex) {
            return parseLong(uid);
        } catch (Exception ignored) {
            return parseLong(uid);
        }
    }

    private Long resolveCompatibleImagingId(Long imagingId, Long studyRecordId) {
        if (imagingId != null && medicalImagingMapper != null && medicalImagingMapper.selectByPrimaryKey(imagingId) != null) {
            return imagingId;
        }
        if (studyRecordId != null && studyMapper != null) {
            Study study = studyMapper.selectByPrimaryKey(studyRecordId);
            if (study != null && study.getImagingId() != null) {
                return study.getImagingId();
            }
        }
        return imagingId;
    }

    private Long parseLong(String value) {
        try {
            return Long.parseLong(value);
        } catch (Exception ignored) {
            return null;
        }
    }

    private void publishJobState(InferenceJob job) {
        try {
            String payload = JSON.toJSONString(job);
            redisTemplate.opsForValue().set("ai:job:" + job.getJobId(), payload, 24, TimeUnit.HOURS);
            redisTemplate.opsForList().leftPush("ai:queue:completed", job.getJobId());
        } catch (Exception ignored) {
            // Redis 是任务进度/队列通道，数据库仍保留完整任务审计记录。
        }
    }

    private Map<String, Object> postgresqlStatus() {
        Map<String, Object> status = new LinkedHashMap<>();
        try {
            Integer one = jdbcTemplate.queryForObject("select 1", Integer.class);
            status.put("state", one != null && one == 1 ? "UP" : "UNKNOWN");
        } catch (Exception ex) {
            status.put("state", "DOWN");
            status.put("error", ex.getClass().getSimpleName() + ": " + ex.getMessage());
        }
        return status;
    }

    private Map<String, Object> redisStatus() {
        Map<String, Object> status = new LinkedHashMap<>();
        try {
            String pong = redisTemplate.getConnectionFactory().getConnection().ping();
            status.put("state", "PONG".equalsIgnoreCase(pong) ? "UP" : "UNKNOWN");
        } catch (Exception ex) {
            status.put("state", "DOWN");
            status.put("error", ex.getClass().getSimpleName() + ": " + ex.getMessage());
        }
        return status;
    }

    private long queueLength() {
        try {
            Long size = redisTemplate.opsForList().size("ai:queue:pending");
            return size == null ? 0L : size;
        } catch (Exception ignored) {
            return -1L;
        }
    }
}
