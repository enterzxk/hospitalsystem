package cn.yujian95.hospital.controller;

import cn.yujian95.hospital.common.api.CommonResult;
import cn.yujian95.hospital.entity.ImagingAnnotation;
import cn.yujian95.hospital.service.IImagingAnnotationService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Api(tags = "影像标注管理")
@RestController
@RequestMapping("/imaging/annotation")
public class ImagingAnnotationController {

    @Autowired
    private IImagingAnnotationService annotationService;

    @ApiOperation("添加标注")
    @PostMapping("/create")
    public CommonResult<ImagingAnnotation> create(@RequestBody ImagingAnnotation annotation) {
        ImagingAnnotation result = annotationService.create(annotation);
        return CommonResult.success(result);
    }

    @ApiOperation("批量添加标注")
    @PostMapping("/batchCreate")
    public CommonResult<Integer> batchCreate(@RequestBody List<ImagingAnnotation> annotations) {
        int count = annotationService.batchCreate(annotations);
        return CommonResult.success(count);
    }

    @ApiOperation("获取影像的所有标注")
    @GetMapping("/list/{imagingId}")
    public CommonResult<List<ImagingAnnotation>> getList(@PathVariable Long imagingId) {
        List<ImagingAnnotation> list = annotationService.getByImagingId(imagingId);
        return CommonResult.success(list);
    }

    @ApiOperation("删除标注")
    @PostMapping("/delete/{id}")
    public CommonResult<Integer> delete(@PathVariable Long id) {
        int count = annotationService.delete(id);
        if (count > 0) {
            return CommonResult.success(count);
        }
        return CommonResult.failed("删除失败");
    }

    @ApiOperation("删除影像的所有标注")
    @PostMapping("/deleteByImaging/{imagingId}")
    public CommonResult<Integer> deleteByImagingId(@PathVariable Long imagingId) {
        int count = annotationService.deleteByImagingId(imagingId);
        return CommonResult.success(count);
    }

    @ApiOperation("更新标注")
    @PostMapping("/update")
    public CommonResult<Integer> update(@RequestBody ImagingAnnotation annotation) {
        int count = annotationService.update(annotation);
        if (count > 0) {
            return CommonResult.success(count);
        }
        return CommonResult.failed("更新失败");
    }
}
