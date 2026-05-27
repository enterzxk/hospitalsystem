package cn.yujian95.hospital.controller;

import cn.yujian95.hospital.common.api.CommonPage;
import cn.yujian95.hospital.common.api.CommonResult;
import cn.yujian95.hospital.entity.DiagnosisReport;
import cn.yujian95.hospital.entity.MedicalImaging;
import cn.yujian95.hospital.service.IDiagnosisReportService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;
import java.util.Optional;

/**
 * 诊断报告Controller
 *
 * @author YuJian95  clj9509@163.com
 * @date 2020/3/19
 */
@Api(value = "诊断模块", tags = "诊断报告接口")
@RestController
@CrossOrigin
@RequestMapping("/diagnosis")
public class DiagnosisReportController {

    @Resource
    private IDiagnosisReportService diagnosisReportService;

    @ApiOperation(value = "创建诊断报告", notes = "传入 诊断报告参数")
    @RequestMapping(value = "/report", method = RequestMethod.POST)
    public CommonResult createReport(@RequestBody DiagnosisReport report) {
        if (diagnosisReportService.create(report)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "更新诊断报告", notes = "传入 报告编号、报告信息参数")
    @ApiImplicitParam(name = "id", value = "报告编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/report/{id}", method = RequestMethod.PUT)
    public CommonResult updateReport(@PathVariable Long id, @RequestBody DiagnosisReport report) {
        if (!diagnosisReportService.count(id)) {
            return CommonResult.validateFailed("不存在，该报告编号！");
        }
        if (diagnosisReportService.update(id, report)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "删除诊断报告", notes = "传入 报告编号")
    @ApiImplicitParam(name = "id", value = "报告编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/report/{id}", method = RequestMethod.DELETE)
    public CommonResult deleteReport(@PathVariable Long id) {
        if (!diagnosisReportService.count(id)) {
            return CommonResult.validateFailed("不存在，该报告编号！");
        }
        if (diagnosisReportService.delete(id)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "获取诊断报告", notes = "传入 报告编号")
    @ApiImplicitParam(name = "id", value = "报告编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/report/{id}", method = RequestMethod.GET)
    public CommonResult<DiagnosisReport> getReport(@PathVariable Long id) {
        Optional<DiagnosisReport> reportOptional = diagnosisReportService.getItem(id);
        return reportOptional.map(CommonResult::success)
                .orElseGet(() -> CommonResult.validateFailed("不存在，该报告编号！"));
    }

    @ApiOperation(value = "分页：搜索诊断报告", notes = "传入 患者编号、医生编号、报告状态")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "patientId", value = "患者编号", paramType = "query", dataType = "Long"),
            @ApiImplicitParam(name = "doctorId", value = "医生编号", paramType = "query", dataType = "Long"),
            @ApiImplicitParam(name = "reportStatus", value = "报告状态", paramType = "query", dataType = "Integer"),
            @ApiImplicitParam(name = "pageNum", value = "第几页", paramType = "query", dataType = "Integer",
                    required = true),
            @ApiImplicitParam(name = "pageSize", value = "页大小", paramType = "query", dataType = "Integer",
                    required = true),
    })
    @RequestMapping(value = "/report/list", method = RequestMethod.GET)
    public CommonResult<CommonPage<DiagnosisReport>> listReports(
            @RequestParam(required = false) Long patientId,
            @RequestParam(required = false) Long doctorId,
            @RequestParam(required = false) Integer reportStatus,
            @RequestParam Integer pageNum,
            @RequestParam Integer pageSize) {
        List<DiagnosisReport> reportList = diagnosisReportService.list(patientId, doctorId, reportStatus, pageNum, pageSize);
        return CommonResult.success(CommonPage.restPage(reportList));
    }

    @ApiOperation(value = "提交诊断报告", notes = "传入 报告编号")
    @ApiImplicitParam(name = "id", value = "报告编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/report/{id}/submit", method = RequestMethod.PUT)
    public CommonResult submitReport(@PathVariable Long id) {
        if (!diagnosisReportService.count(id)) {
            return CommonResult.validateFailed("不存在，该报告编号！");
        }
        if (diagnosisReportService.submit(id)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "审核诊断报告", notes = "传入 报告编号、审核人编号、审核意见")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "id", value = "报告编号", paramType = "path", dataType = "Long", required = true),
            @ApiImplicitParam(name = "reviewerId", value = "审核人编号", paramType = "query", dataType = "Long",
                    required = true),
            @ApiImplicitParam(name = "reviewOpinion", value = "审核意见", paramType = "query", dataType = "String"),
    })
    @RequestMapping(value = "/report/{id}/review", method = RequestMethod.PUT)
    public CommonResult reviewReport(@PathVariable Long id,
                                     @RequestParam Long reviewerId,
                                     @RequestParam(required = false) String reviewOpinion) {
        if (!diagnosisReportService.count(id)) {
            return CommonResult.validateFailed("不存在，该报告编号！");
        }
        if (diagnosisReportService.review(id, reviewerId, reviewOpinion)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "关联影像到报告", notes = "传入 报告编号、影像编号列表")
    @ApiImplicitParam(name = "reportId", value = "报告编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/report/{reportId}/imaging", method = RequestMethod.POST)
    public CommonResult relateImaging(@PathVariable Long reportId, @RequestBody List<Long> imagingIds) {
        if (!diagnosisReportService.count(reportId)) {
            return CommonResult.validateFailed("不存在，该报告编号！");
        }
        if (diagnosisReportService.relateImaging(reportId, imagingIds)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "获取报告关联的影像列表", notes = "传入 报告编号")
    @ApiImplicitParam(name = "reportId", value = "报告编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/report/{reportId}/imaging", method = RequestMethod.GET)
    public CommonResult<List<MedicalImaging>> getReportImagings(@PathVariable Long reportId) {
        if (!diagnosisReportService.count(reportId)) {
            return CommonResult.validateFailed("不存在，该报告编号！");
        }
        List<MedicalImaging> imagingList = diagnosisReportService.getReportImagings(reportId);
        return CommonResult.success(imagingList);
    }
}
