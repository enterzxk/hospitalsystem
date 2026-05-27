package cn.yujian95.hospital.service.impl;

import cn.yujian95.hospital.entity.VisitRecord;
import cn.yujian95.hospital.entity.VisitRecordExample;
import cn.yujian95.hospital.mapper.VisitRecordMapper;
import cn.yujian95.hospital.service.IVisitRecordService;
import com.github.pagehelper.PageHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Optional;

/**
 * 就诊记录Service实现
 *
 * @author YuJian95  clj9509@163.com
 * @date 2020/3/19
 */
@Service
public class VisitRecordServiceImpl implements IVisitRecordService {

    @Autowired
    private VisitRecordMapper visitRecordMapper;

    @Override
    public boolean create(VisitRecord visitRecord) {
        visitRecord.setGmtCreate(new Date());
        visitRecord.setGmtModified(new Date());
        return visitRecordMapper.insertSelective(visitRecord) > 0;
    }

    @Override
    public boolean update(Long id, VisitRecord visitRecord) {
        visitRecord.setId(id);
        visitRecord.setGmtModified(new Date());
        return visitRecordMapper.updateByPrimaryKeySelective(visitRecord) > 0;
    }

    @Override
    public boolean delete(Long id) {
        return visitRecordMapper.deleteByPrimaryKey(id) > 0;
    }

    @Override
    public Optional<VisitRecord> getItem(Long id) {
        return Optional.ofNullable(visitRecordMapper.selectByPrimaryKey(id));
    }

    @Override
    public List<VisitRecord> list(Long patientId, Long doctorId, Integer visitStatus, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        VisitRecordExample example = new VisitRecordExample();
        VisitRecordExample.Criteria criteria = example.createCriteria();

        if (patientId != null) {
            criteria.andPatientIdEqualTo(patientId);
        }

        if (doctorId != null) {
            criteria.andDoctorIdEqualTo(doctorId);
        }

        if (visitStatus != null) {
            criteria.andVisitStatusEqualTo(visitStatus);
        }

        example.setOrderByClause("visit_date desc");
        return visitRecordMapper.selectByExample(example);
    }

    @Override
    public boolean updateStatus(Long id, Integer visitStatus) {
        VisitRecord visitRecord = new VisitRecord();
        visitRecord.setId(id);
        visitRecord.setVisitStatus(visitStatus);
        visitRecord.setGmtModified(new Date());
        return visitRecordMapper.updateByPrimaryKeySelective(visitRecord) > 0;
    }

    @Override
    public List<VisitRecord> getByPatientId(Long patientId) {
        VisitRecordExample example = new VisitRecordExample();
        example.createCriteria().andPatientIdEqualTo(patientId);
        example.setOrderByClause("visit_date desc");
        return visitRecordMapper.selectByExample(example);
    }

    @Override
    public boolean count(Long id) {
        return visitRecordMapper.selectByPrimaryKey(id) != null;
    }
}
