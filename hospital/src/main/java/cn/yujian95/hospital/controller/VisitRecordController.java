package cn.yujian95.hospital.controller;

import cn.yujian95.hospital.common.api.CommonPage;
import cn.yujian95.hospital.common.api.CommonResult;
import cn.yujian95.hospital.entity.VisitRecord;
import cn.yujian95.hospital.service.IVisitRecordService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;
import java.util.Optional;

/**
 * 就诊记录Controller
 *
 * @author YuJian95  clj9509@163.com
 * @date 2020/3/19
 */
@Api(value = "就诊模块", tags = "就诊记录接口")
@RestController
@CrossOrigin
@RequestMapping("/visit")
public class VisitRecordController {

    @Resource
    private IVisitRecordService visitRecordService;

    @ApiOperation(value = "创建就诊记录", notes = "传入 就诊记录参数")
    @RequestMapping(value = "/record", method = RequestMethod.POST)
    public CommonResult createVisitRecord(@RequestBody VisitRecord visitRecord) {
        if (visitRecordService.create(visitRecord)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "更新就诊记录", notes = "传入 就诊编号、就诊记录参数")
    @ApiImplicitParam(name = "id", value = "就诊编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/record/{id}", method = RequestMethod.PUT)
    public CommonResult updateVisitRecord(@PathVariable Long id, @RequestBody VisitRecord visitRecord) {
        if (!visitRecordService.count(id)) {
            return CommonResult.validateFailed("不存在，该就诊编号！");
        }
        if (visitRecordService.update(id, visitRecord)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "删除就诊记录", notes = "传入 就诊编号")
    @ApiImplicitParam(name = "id", value = "就诊编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/record/{id}", method = RequestMethod.DELETE)
    public CommonResult deleteVisitRecord(@PathVariable Long id) {
        if (!visitRecordService.count(id)) {
            return CommonResult.validateFailed("不存在，该就诊编号！");
        }
        if (visitRecordService.delete(id)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "获取就诊记录", notes = "传入 就诊编号")
    @ApiImplicitParam(name = "id", value = "就诊编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/record/{id}", method = RequestMethod.GET)
    public CommonResult<VisitRecord> getVisitRecord(@PathVariable Long id) {
        Optional<VisitRecord> recordOptional = visitRecordService.getItem(id);
        return recordOptional.map(CommonResult::success)
                .orElseGet(() -> CommonResult.validateFailed("不存在，该就诊编号！"));
    }

    @ApiOperation(value = "分页：搜索就诊记录", notes = "传入 患者编号、医生编号、就诊状态")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "patientId", value = "患者编号", paramType = "query", dataType = "Long"),
            @ApiImplicitParam(name = "doctorId", value = "医生编号", paramType = "query", dataType = "Long"),
            @ApiImplicitParam(name = "visitStatus", value = "就诊状态", paramType = "query", dataType = "Integer"),
            @ApiImplicitParam(name = "pageNum", value = "第几页", paramType = "query", dataType = "Integer",
                    required = true),
            @ApiImplicitParam(name = "pageSize", value = "页大小", paramType = "query", dataType = "Integer",
                    required = true),
    })
    @RequestMapping(value = "/record/list", method = RequestMethod.GET)
    public CommonResult<CommonPage<VisitRecord>> listVisitRecords(
            @RequestParam(required = false) Long patientId,
            @RequestParam(required = false) Long doctorId,
            @RequestParam(required = false) Integer visitStatus,
            @RequestParam Integer pageNum,
            @RequestParam Integer pageSize) {
        List<VisitRecord> recordList = visitRecordService.list(patientId, doctorId, visitStatus, pageNum, pageSize);
        return CommonResult.success(CommonPage.restPage(recordList));
    }

    @ApiOperation(value = "更新就诊状态", notes = "传入 就诊编号、就诊状态")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "id", value = "就诊编号", paramType = "path", dataType = "Long", required = true),
            @ApiImplicitParam(name = "visitStatus", value = "就诊状态", paramType = "query", dataType = "Integer",
                    required = true),
    })
    @RequestMapping(value = "/record/{id}/status", method = RequestMethod.PUT)
    public CommonResult updateVisitStatus(@PathVariable Long id, @RequestParam Integer visitStatus) {
        if (!visitRecordService.count(id)) {
            return CommonResult.validateFailed("不存在，该就诊编号！");
        }
        if (visitRecordService.updateStatus(id, visitStatus)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "获取患者的就诊记录", notes = "传入 患者编号")
    @ApiImplicitParam(name = "patientId", value = "患者编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/record/patient/{patientId}", method = RequestMethod.GET)
    public CommonResult<List<VisitRecord>> getVisitRecordsByPatientId(@PathVariable Long patientId) {
        List<VisitRecord> recordList = visitRecordService.getByPatientId(patientId);
        return CommonResult.success(recordList);
    }
}
