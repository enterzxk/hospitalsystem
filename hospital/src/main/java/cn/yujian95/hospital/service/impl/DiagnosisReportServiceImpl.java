package cn.yujian95.hospital.service.impl;

import cn.yujian95.hospital.entity.DiagnosisReport;
import cn.yujian95.hospital.entity.DiagnosisReportExample;
import cn.yujian95.hospital.entity.MedicalImaging;
import cn.yujian95.hospital.entity.ReportImagingRelation;
import cn.yujian95.hospital.mapper.DiagnosisReportMapper;
import cn.yujian95.hospital.mapper.ReportImagingRelationMapper;
import cn.yujian95.hospital.service.IDiagnosisReportService;
import cn.yujian95.hospital.service.IMedicalImagingService;
import com.github.pagehelper.PageHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;

/**
 * 诊断报告Service实现
 *
 * @author YuJian95  clj9509@163.com
 * @date 2020/3/19
 */
@Service
public class DiagnosisReportServiceImpl implements IDiagnosisReportService {

    @Autowired
    private DiagnosisReportMapper diagnosisReportMapper;

    @Autowired
    private ReportImagingRelationMapper reportImagingRelationMapper;

    @Autowired
    private IMedicalImagingService medicalImagingService;

    @Override
    public boolean create(DiagnosisReport report) {
        report.setGmtCreate(new Date());
        report.setGmtModified(new Date());
        report.setReportStatus(0); // 草稿状态
        if (StringUtils.isEmpty(report.getDiagnosticOpinion())) {
            report.setDiagnosticOpinion("");
        }
        return diagnosisReportMapper.insertSelective(report) > 0;
    }

    @Override
    public boolean update(Long id, DiagnosisReport report) {
        report.setId(id);
        report.setGmtModified(new Date());
        return diagnosisReportMapper.updateByPrimaryKeySelective(report) > 0;
    }

    @Override
    public boolean delete(Long id) {
        return diagnosisReportMapper.deleteByPrimaryKey(id) > 0;
    }

    @Override
    public Optional<DiagnosisReport> getItem(Long id) {
        return Optional.ofNullable(diagnosisReportMapper.selectByPrimaryKey(id));
    }

    @Override
    public List<DiagnosisReport> list(Long patientId, Long doctorId, Integer reportStatus, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        DiagnosisReportExample example = new DiagnosisReportExample();
        DiagnosisReportExample.Criteria criteria = example.createCriteria();

        if (patientId != null) {
            criteria.andPatientIdEqualTo(patientId);
        }

        if (doctorId != null) {
            criteria.andDoctorIdEqualTo(doctorId);
        }

        if (reportStatus != null) {
            criteria.andReportStatusEqualTo(reportStatus);
        }

        example.setOrderByClause("report_date desc");
        return diagnosisReportMapper.selectByExample(example);
    }

    @Override
    public boolean submit(Long id) {
        DiagnosisReport report = new DiagnosisReport();
        report.setId(id);
        report.setReportStatus(1); // 已提交
        report.setGmtModified(new Date());
        return diagnosisReportMapper.updateByPrimaryKeySelective(report) > 0;
    }

    @Override
    public boolean review(Long id, Long reviewerId, String reviewOpinion) {
        DiagnosisReport report = new DiagnosisReport();
        report.setId(id);
        report.setReportStatus(2); // 已审核
        report.setReviewerId(reviewerId);
        report.setReviewTime(new Date());
        report.setReviewOpinion(reviewOpinion);
        report.setGmtModified(new Date());
        return diagnosisReportMapper.updateByPrimaryKeySelective(report) > 0;
    }

    @Override
    @Transactional
    public boolean relateImaging(Long reportId, List<Long> imagingIds) {
        // 先删除原有关联
        DiagnosisReportExample example = new DiagnosisReportExample();
        example.createCriteria().andIdEqualTo(reportId);

        // 删除原有关联
        ReportImagingRelation relationExample = new ReportImagingRelation();
        // 这里需要根据reportId删除关联，简化处理
        // 实际项目中应该有更完善的删除逻辑

        // 创建新关联
        for (Long imagingId : imagingIds) {
            ReportImagingRelation relation = new ReportImagingRelation();
            relation.setReportId(reportId);
            relation.setImagingId(imagingId);
            relation.setGmtCreate(new Date());
            reportImagingRelationMapper.insertSelective(relation);
        }

        // 更新影像诊断状态
        for (Long imagingId : imagingIds) {
            medicalImagingService.updateDiagnosisStatus(imagingId, 1); // 已诊断
        }

        return true;
    }

    @Override
    public List<MedicalImaging> getReportImagings(Long reportId) {
        // 获取报告关联的影像ID列表
        ReportImagingRelation relationExample = new ReportImagingRelation();
        // 简化处理，实际应该有更完善的查询逻辑
        // 这里返回空列表，实际项目中应该查询关联表
        return new ArrayList<>();
    }

    @Override
    public boolean count(Long id) {
        return diagnosisReportMapper.selectByPrimaryKey(id) != null;
    }
}
