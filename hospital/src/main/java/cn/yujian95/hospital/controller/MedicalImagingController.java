package cn.yujian95.hospital.controller;

import cn.yujian95.hospital.common.api.CommonPage;
import cn.yujian95.hospital.common.api.CommonResult;
import cn.yujian95.hospital.entity.MedicalImaging;
import cn.yujian95.hospital.service.IMedicalImagingService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;
import java.util.Optional;

/**
 * 医学影像Controller
 *
 * @author YuJian95  clj9509@163.com
 * @date 2020/3/19
 */
@Api(value = "影像模块", tags = "医学影像接口")
@RestController
@CrossOrigin
@RequestMapping("/imaging")
public class MedicalImagingController {

    @Resource
    private IMedicalImagingService medicalImagingService;

    @ApiOperation(value = "添加医学影像", notes = "传入 影像信息参数")
    @RequestMapping(value = "/info", method = RequestMethod.POST)
    public CommonResult createImaging(@RequestBody MedicalImaging medicalImaging) {
        if (medicalImagingService.create(medicalImaging)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "更新医学影像", notes = "传入 影像编号、影像信息参数")
    @ApiImplicitParam(name = "id", value = "影像编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/info/{id}", method = RequestMethod.PUT)
    public CommonResult updateImaging(@PathVariable Long id, @RequestBody MedicalImaging medicalImaging) {
        if (!medicalImagingService.count(id)) {
            return CommonResult.validateFailed("不存在，该影像编号！");
        }
        if (medicalImagingService.update(id, medicalImaging)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "删除医学影像", notes = "传入 影像编号")
    @ApiImplicitParam(name = "id", value = "影像编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/info/{id}", method = RequestMethod.DELETE)
    public CommonResult deleteImaging(@PathVariable Long id) {
        if (!medicalImagingService.count(id)) {
            return CommonResult.validateFailed("不存在，该影像编号！");
        }
        if (medicalImagingService.delete(id)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "获取医学影像", notes = "传入 影像编号")
    @ApiImplicitParam(name = "id", value = "影像编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/info/{id}", method = RequestMethod.GET)
    public CommonResult<MedicalImaging> getImaging(@PathVariable Long id) {
        Optional<MedicalImaging> imagingOptional = medicalImagingService.getItem(id);
        return imagingOptional.map(CommonResult::success)
                .orElseGet(() -> CommonResult.validateFailed("不存在，该影像编号！"));
    }

    @ApiOperation(value = "分页：搜索医学影像", notes = "传入 患者编号、影像类型、诊断状态")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "patientId", value = "患者编号", paramType = "query", dataType = "Long"),
            @ApiImplicitParam(name = "imagingType", value = "影像类型", paramType = "query", dataType = "String"),
            @ApiImplicitParam(name = "diagnosisStatus", value = "诊断状态", paramType = "query", dataType = "Integer"),
            @ApiImplicitParam(name = "pageNum", value = "第几页", paramType = "query", dataType = "Integer",
                    required = true),
            @ApiImplicitParam(name = "pageSize", value = "页大小", paramType = "query", dataType = "Integer",
                    required = true),
    })
    @RequestMapping(value = "/info/list", method = RequestMethod.GET)
    public CommonResult<CommonPage<MedicalImaging>> listImagings(
            @RequestParam(required = false) Long patientId,
            @RequestParam(required = false) String imagingType,
            @RequestParam(required = false) Integer diagnosisStatus,
            @RequestParam Integer pageNum,
            @RequestParam Integer pageSize) {
        List<MedicalImaging> imagingList = medicalImagingService.list(patientId, imagingType, diagnosisStatus, pageNum, pageSize);
        return CommonResult.success(CommonPage.restPage(imagingList));
    }

    @ApiOperation(value = "更新影像诊断状态", notes = "传入 影像编号、诊断状态")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "id", value = "影像编号", paramType = "path", dataType = "Long", required = true),
            @ApiImplicitParam(name = "diagnosisStatus", value = "诊断状态", paramType = "query", dataType = "Integer",
                    required = true),
    })
    @RequestMapping(value = "/info/{id}/status", method = RequestMethod.PUT)
    public CommonResult updateDiagnosisStatus(@PathVariable Long id, @RequestParam Integer diagnosisStatus) {
        if (!medicalImagingService.count(id)) {
            return CommonResult.validateFailed("不存在，该影像编号！");
        }
        if (medicalImagingService.updateDiagnosisStatus(id, diagnosisStatus)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "获取患者的影像列表", notes = "传入 患者编号")
    @ApiImplicitParam(name = "patientId", value = "患者编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/info/patient/{patientId}", method = RequestMethod.GET)
    public CommonResult<List<MedicalImaging>> getImagingsByPatientId(@PathVariable Long patientId) {
        List<MedicalImaging> imagingList = medicalImagingService.getByPatientId(patientId);
        return CommonResult.success(imagingList);
    }
}
