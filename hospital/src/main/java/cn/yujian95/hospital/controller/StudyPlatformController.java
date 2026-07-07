package cn.yujian95.hospital.controller;

import cn.yujian95.hospital.common.api.CommonResult;
import cn.yujian95.hospital.dto.ai.StudyUploadParam;
import cn.yujian95.hospital.dto.ai.StudyUploadResult;
import cn.yujian95.hospital.entity.Study;
import cn.yujian95.hospital.entity.StudyInstance;
import cn.yujian95.hospital.entity.StudySeries;
import cn.yujian95.hospital.service.ai.StudyPlatformService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import java.util.List;

@Api(tags = "标准影像数据接口")
@RestController
@CrossOrigin
@RequestMapping("/api")
public class StudyPlatformController {
    @Resource
    private StudyPlatformService studyPlatformService;

    @ApiOperation("上传并登记标准影像检查")
    @PostMapping(value = "/studies/upload", consumes = MediaType.APPLICATION_JSON_VALUE)
    public CommonResult<StudyUploadResult> upload(@RequestBody StudyUploadParam param) {
        if (param.getPatientId() == null) {
            return CommonResult.validateFailed("patientId 不能为空");
        }
        return CommonResult.success(studyPlatformService.uploadStudy(param));
    }

    @ApiOperation("上传影像文件并登记标准影像检查")
    @PostMapping(value = "/studies/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public CommonResult<StudyUploadResult> uploadMultipart(@ModelAttribute StudyUploadParam param,
                                                           @RequestPart(value = "file", required = false) MultipartFile file) {
        if (param.getPatientId() == null) {
            return CommonResult.validateFailed("patientId 不能为空");
        }
        try {
            return CommonResult.success(studyPlatformService.uploadStudy(param, file));
        } catch (Exception ex) {
            return CommonResult.failed("影像文件写入对象存储失败，请检查 MinIO/NAS 配置：" + ex.getMessage());
        }
    }

    @ApiOperation("查询标准影像检查列表")
    @GetMapping("/studies")
    public CommonResult<List<Study>> listStudies(@RequestParam(required = false) Long patientId,
                                                 @RequestParam(required = false) String modality,
                                                 @RequestParam(required = false) String bodyPart) {
        return CommonResult.success(studyPlatformService.listStudies(patientId, modality, bodyPart));
    }

    @ApiOperation("获取检查详情")
    @GetMapping("/studies/{id}")
    public CommonResult<Study> getStudy(@PathVariable Long id) {
        Study study = studyPlatformService.getStudy(id);
        return study == null ? CommonResult.validateFailed("不存在该检查") : CommonResult.success(study);
    }

    @ApiOperation("获取检查序列")
    @GetMapping("/studies/{id}/series")
    public CommonResult<List<StudySeries>> getSeries(@PathVariable Long id) {
        return CommonResult.success(studyPlatformService.getSeries(id));
    }

    @ApiOperation("获取序列切片实例")
    @GetMapping("/series/{id}/instances")
    public CommonResult<List<StudyInstance>> getInstances(@PathVariable Long id) {
        return CommonResult.success(studyPlatformService.getInstances(id));
    }

    @ApiOperation("获取实例渲染地址")
    @GetMapping("/instances/{id}/render")
    public CommonResult<StudyInstance> renderInstance(@PathVariable Long id) {
        StudyInstance instance = studyPlatformService.getInstance(id);
        return instance == null ? CommonResult.validateFailed("不存在该影像实例") : CommonResult.success(instance);
    }
}
