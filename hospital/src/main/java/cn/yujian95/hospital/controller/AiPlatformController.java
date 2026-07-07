package cn.yujian95.hospital.controller;

import cn.yujian95.hospital.common.api.CommonPage;
import cn.yujian95.hospital.common.api.CommonResult;
import cn.yujian95.hospital.dto.ai.*;
import cn.yujian95.hospital.entity.*;
import cn.yujian95.hospital.service.IDiagnosisReportService;
import cn.yujian95.hospital.service.ILogOperationService;
import cn.yujian95.hospital.service.ai.AiPlatformService;
import cn.yujian95.hospital.service.ai.AuditTrailService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Api(tags = "AI 多任务平台接口")
@RestController
@CrossOrigin
@RequestMapping("/api")
public class AiPlatformController {
    @Resource
    private AiPlatformService aiPlatformService;
    @Resource
    private ILogOperationService operationService;
    @Resource
    private IDiagnosisReportService diagnosisReportService;
    @Resource
    private AuditTrailService auditTrailService;

    @ApiOperation("查询模型注册表")
    @GetMapping("/models")
    public CommonResult<List<ModelRegistry>> listModels(@RequestParam(required = false) String taskType,
                                                        @RequestParam(required = false) String modality) {
        return CommonResult.success(aiPlatformService.listModels(taskType, modality));
    }

    @ApiOperation("新增模型")
    @PostMapping("/models")
    public CommonResult saveModel(@RequestBody ModelRegistry model) {
        return aiPlatformService.saveModel(model) ? CommonResult.success() : CommonResult.failed("保存模型失败");
    }

    @ApiOperation("更新模型")
    @PutMapping("/models/{id}")
    public CommonResult updateModel(@PathVariable Long id, @RequestBody ModelRegistry model) {
        model.setId(id);
        return aiPlatformService.saveModel(model) ? CommonResult.success() : CommonResult.failed("更新模型失败");
    }

    @ApiOperation("保存 Prompt")
    @PostMapping("/prompts")
    public CommonResult<AiPrompt> savePrompt(@RequestBody AiPrompt prompt) {
        return CommonResult.success(aiPlatformService.savePrompt(prompt));
    }

    @ApiOperation("创建 AI 推理任务")
    @PostMapping("/ai/infer/{taskType}")
    public CommonResult<Map<String, Object>> infer(@PathVariable String taskType, @RequestBody AiInferRequest request) {
        if (request.getImagingId() == null && request.getStudyRecordId() == null && request.getStudyId() == null) {
            return CommonResult.validateFailed("imagingId、studyRecordId 或 study_id 不能为空");
        }
        try {
            return CommonResult.success(aiPlatformService.createInferenceJob(taskType, request));
        } catch (IllegalArgumentException ex) {
            return CommonResult.validateFailed(ex.getMessage());
        }
    }

    @ApiOperation("查询 AI 推理任务")
    @GetMapping("/ai/jobs/{jobId}")
    public CommonResult<Map<String, Object>> getJob(@PathVariable String jobId) {
        return CommonResult.success(aiPlatformService.getJob(jobId));
    }

    @ApiOperation("查询影像 AI 结果")
    @GetMapping("/ai/results/imaging/{imagingId}")
    public CommonResult<List<AiAnalysisResult>> getResults(@PathVariable Long imagingId) {
        return CommonResult.success(aiPlatformService.getResultsByImaging(imagingId));
    }

    @ApiOperation("医生确认或驳回 AI 结果")
    @PostMapping("/results/{id}/confirm")
    public CommonResult<AiAnalysisResult> confirm(@PathVariable Long id, @RequestBody ConfirmResultParam param) {
        return CommonResult.success(aiPlatformService.confirmResult(id, param));
    }

    @ApiOperation("生成结构化报告草稿")
    @PostMapping("/reports/draft")
    public CommonResult<StructuredReportDraft> createReportDraft(@RequestBody ReportDraftParam param) {
        if (param.getImagingId() == null && param.getStudyRecordId() == null) {
            return CommonResult.validateFailed("imagingId 或 studyRecordId 不能为空");
        }
        try {
            return CommonResult.success(aiPlatformService.createReportDraft(param));
        } catch (IllegalArgumentException ex) {
            return CommonResult.validateFailed(ex.getMessage());
        }
    }

    @ApiOperation("获取结构化诊断报告")
    @GetMapping("/reports/{id}")
    public CommonResult<DiagnosisReport> getReport(@PathVariable Long id) {
        Optional<DiagnosisReport> report = diagnosisReportService.getItem(id);
        return report.map(CommonResult::success)
                .orElseGet(() -> CommonResult.validateFailed("不存在，该报告编号！"));
    }

    @ApiOperation("更新结构化诊断报告")
    @PutMapping("/reports/{id}")
    public CommonResult updateReport(@PathVariable Long id, @RequestBody DiagnosisReport report) {
        if (!diagnosisReportService.count(id)) {
            return CommonResult.validateFailed("不存在，该报告编号！");
        }
        if (diagnosisReportService.update(id, report)) {
            auditTrailService.record("system", "更新结构化诊断报告", "/api/reports/" + id, String.valueOf(report), "success");
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation("提交结构化诊断报告")
    @PostMapping("/reports/{id}/submit")
    public CommonResult submitReport(@PathVariable Long id) {
        Optional<DiagnosisReport> reportOptional = diagnosisReportService.getItem(id);
        if (!reportOptional.isPresent()) {
            return CommonResult.validateFailed("不存在，该报告编号！");
        }
        DiagnosisReport report = reportOptional.get();
        if (StringUtils.isEmpty(report.getDiagnosticOpinion()) || StringUtils.isEmpty(report.getDiagnosticOpinion().trim())) {
            return CommonResult.validateFailed("诊断意见必须由主治医生填写后才能提交");
        }
        if (diagnosisReportService.submit(id)) {
            auditTrailService.record("system", "提交结构化诊断报告", "/api/reports/" + id + "/submit", "reportId=" + id, "success");
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation("审计日志")
    @GetMapping("/audit-logs")
    public CommonResult<CommonPage<LogOperation>> auditLogs(@RequestParam(required = false) String accountName,
                                                            @RequestParam(required = false) String method,
                                                            @RequestParam(defaultValue = "1") Integer pageNum,
                                                            @RequestParam(defaultValue = "20") Integer pageSize) {
        List<LogOperation> logs = operationService.search(accountName, method, pageNum, pageSize);
        long total = operationService.count(accountName, method);
        return CommonResult.success(CommonPage.restPage(logs, pageNum, pageSize, total));
    }

    @ApiOperation("运维状态")
    @GetMapping("/ops/status")
    public CommonResult<Map<String, Object>> opsStatus() {
        return CommonResult.success(aiPlatformService.opsStatus());
    }
}
