package cn.yujian95.hospital.service.impl;

import cn.yujian95.hospital.entity.MedicalImaging;
import cn.yujian95.hospital.entity.MedicalImagingExample;
import cn.yujian95.hospital.mapper.MedicalImagingMapper;
import cn.yujian95.hospital.service.IMedicalImagingService;
import com.github.pagehelper.PageHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.Date;
import java.util.List;
import java.util.Optional;

/**
 * 医学影像Service实现
 *
 * @author YuJian95  clj9509@163.com
 * @date 2020/3/19
 */
@Service
public class MedicalImagingServiceImpl implements IMedicalImagingService {

    @Autowired
    private MedicalImagingMapper medicalImagingMapper;

    @Override
    public boolean create(MedicalImaging medicalImaging) {
        medicalImaging.setGmtCreate(new Date());
        medicalImaging.setGmtModified(new Date());
        return medicalImagingMapper.insertSelective(medicalImaging) > 0;
    }

    @Override
    public boolean update(Long id, MedicalImaging medicalImaging) {
        medicalImaging.setId(id);
        medicalImaging.setGmtModified(new Date());
        return medicalImagingMapper.updateByPrimaryKeySelective(medicalImaging) > 0;
    }

    @Override
    public boolean delete(Long id) {
        return medicalImagingMapper.deleteByPrimaryKey(id) > 0;
    }

    @Override
    public Optional<MedicalImaging> getItem(Long id) {
        return Optional.ofNullable(medicalImagingMapper.selectByPrimaryKey(id));
    }

    @Override
    public List<MedicalImaging> list(Long patientId, String imagingType, Integer diagnosisStatus, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        MedicalImagingExample example = new MedicalImagingExample();
        MedicalImagingExample.Criteria criteria = example.createCriteria();

        if (patientId != null) {
            criteria.andPatientIdEqualTo(patientId);
        }

        if (!StringUtils.isEmpty(imagingType)) {
            criteria.andImagingTypeEqualTo(imagingType);
        }

        if (diagnosisStatus != null) {
            criteria.andDiagnosisStatusEqualTo(diagnosisStatus);
        }

        example.setOrderByClause("gmt_create desc");
        return medicalImagingMapper.selectByExample(example);
    }

    @Override
    public boolean updateDiagnosisStatus(Long id, Integer diagnosisStatus) {
        MedicalImaging medicalImaging = new MedicalImaging();
        medicalImaging.setId(id);
        medicalImaging.setDiagnosisStatus(diagnosisStatus);
        medicalImaging.setGmtModified(new Date());
        return medicalImagingMapper.updateByPrimaryKeySelective(medicalImaging) > 0;
    }

    @Override
    public List<MedicalImaging> getByPatientId(Long patientId) {
        MedicalImagingExample example = new MedicalImagingExample();
        example.createCriteria().andPatientIdEqualTo(patientId);
        example.setOrderByClause("gmt_create desc");
        return medicalImagingMapper.selectByExample(example);
    }

    @Override
    public boolean count(Long id) {
        return medicalImagingMapper.selectByPrimaryKey(id) != null;
    }
}
