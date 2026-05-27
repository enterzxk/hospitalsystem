package cn.yujian95.hospital.controller;

import cn.yujian95.hospital.common.api.CommonPage;
import cn.yujian95.hospital.common.api.CommonResult;
import cn.yujian95.hospital.entity.PatientInfo;
import cn.yujian95.hospital.service.IPatientInfoService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;
import java.util.Optional;

/**
 * 患者信息Controller
 *
 * @author YuJian95  clj9509@163.com
 * @date 2020/3/19
 */
@Api(value = "患者模块", tags = "患者信息接口")
@RestController
@CrossOrigin
@RequestMapping("/patient")
public class PatientInfoController {

    @Resource
    private IPatientInfoService patientInfoService;

    @ApiOperation(value = "添加患者信息", notes = "传入 患者信息参数")
    @RequestMapping(value = "/info", method = RequestMethod.POST)
    public CommonResult createPatient(@RequestBody PatientInfo patientInfo) {
        if (patientInfoService.create(patientInfo)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "更新患者信息", notes = "传入 患者编号、患者信息参数")
    @ApiImplicitParam(name = "id", value = "患者编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/info/{id}", method = RequestMethod.PUT)
    public CommonResult updatePatient(@PathVariable Long id, @RequestBody PatientInfo patientInfo) {
        if (!patientInfoService.count(id)) {
            return CommonResult.validateFailed("不存在，该患者编号！");
        }
        if (patientInfoService.update(id, patientInfo)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "删除患者信息", notes = "传入 患者编号")
    @ApiImplicitParam(name = "id", value = "患者编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/info/{id}", method = RequestMethod.DELETE)
    public CommonResult deletePatient(@PathVariable Long id) {
        if (!patientInfoService.count(id)) {
            return CommonResult.validateFailed("不存在，该患者编号！");
        }
        if (patientInfoService.delete(id)) {
            return CommonResult.success();
        }
        return CommonResult.failed("服务器错误，请联系管理员！");
    }

    @ApiOperation(value = "获取患者信息", notes = "传入 患者编号")
    @ApiImplicitParam(name = "id", value = "患者编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/info/{id}", method = RequestMethod.GET)
    public CommonResult<PatientInfo> getPatient(@PathVariable Long id) {
        Optional<PatientInfo> patientOptional = patientInfoService.getItem(id);
        return patientOptional.map(CommonResult::success)
                .orElseGet(() -> CommonResult.validateFailed("不存在，该患者编号！"));
    }

    @ApiOperation(value = "分页：搜索患者信息", notes = "传入 关键词")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "keyword", value = "关键词", paramType = "query", dataType = "String"),
            @ApiImplicitParam(name = "pageNum", value = "第几页", paramType = "query", dataType = "Integer",
                    required = true),
            @ApiImplicitParam(name = "pageSize", value = "页大小", paramType = "query", dataType = "Integer",
                    required = true),
    })
    @RequestMapping(value = "/info/list", method = RequestMethod.GET)
    public CommonResult<CommonPage<PatientInfo>> listPatients(
            @RequestParam(required = false) String keyword,
            @RequestParam Integer pageNum,
            @RequestParam Integer pageSize) {
        List<PatientInfo> patientList = patientInfoService.list(keyword, pageNum, pageSize);
        return CommonResult.success(CommonPage.restPage(patientList));
    }

    @ApiOperation(value = "通过账号ID获取患者信息", notes = "传入 账号编号")
    @ApiImplicitParam(name = "accountId", value = "账号编号", paramType = "path", dataType = "Long", required = true)
    @RequestMapping(value = "/info/account/{accountId}", method = RequestMethod.GET)
    public CommonResult<PatientInfo> getPatientByAccountId(@PathVariable Long accountId) {
        Optional<PatientInfo> patientOptional = patientInfoService.getByAccountId(accountId);
        return patientOptional.map(CommonResult::success)
                .orElseGet(() -> CommonResult.validateFailed("不存在，该账号对应的患者！"));
    }
}
