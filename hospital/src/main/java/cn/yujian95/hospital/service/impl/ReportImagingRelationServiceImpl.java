package cn.yujian95.hospital.service.impl;

import cn.yujian95.hospital.entity.ReportImagingRelation;
import cn.yujian95.hospital.entity.ReportImagingRelationExample;
import cn.yujian95.hospital.mapper.ReportImagingRelationMapper;
import cn.yujian95.hospital.service.IReportImagingRelationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 报告影像关联Service实现
 *
 * @author YuJian95  clj9509@163.com
 * @date 2020/3/19
 */
@Service
public class ReportImagingRelationServiceImpl implements IReportImagingRelationService {

    @Autowired
    private ReportImagingRelationMapper reportImagingRelationMapper;

    @Override
    public boolean create(ReportImagingRelation relation) {
        relation.setGmtCreate(new Date());
        return reportImagingRelationMapper.insertSelective(relation) > 0;
    }

    @Override
    public boolean delete(Long reportId, Long imagingId) {
        ReportImagingRelationExample example = new ReportImagingRelationExample();
        example.createCriteria()
                .andReportIdEqualTo(reportId)
                .andImagingIdEqualTo(imagingId);
        return reportImagingRelationMapper.deleteByExample(example) > 0;
    }

    @Override
    public List<Long> getImagingIdsByReportId(Long reportId) {
        ReportImagingRelationExample example = new ReportImagingRelationExample();
        example.createCriteria().andReportIdEqualTo(reportId);
        return reportImagingRelationMapper.selectByExample(example)
                .stream()
                .map(ReportImagingRelation::getImagingId)
                .collect(Collectors.toList());
    }

    @Override
    public List<Long> getReportIdsByImagingId(Long imagingId) {
        ReportImagingRelationExample example = new ReportImagingRelationExample();
        example.createCriteria().andImagingIdEqualTo(imagingId);
        return reportImagingRelationMapper.selectByExample(example)
                .stream()
                .map(ReportImagingRelation::getReportId)
                .collect(Collectors.toList());
    }
}
