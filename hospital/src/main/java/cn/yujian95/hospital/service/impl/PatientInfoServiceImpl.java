package cn.yujian95.hospital.service.impl;

import cn.yujian95.hospital.entity.PatientInfo;
import cn.yujian95.hospital.entity.PatientInfoExample;
import cn.yujian95.hospital.mapper.PatientInfoMapper;
import cn.yujian95.hospital.service.IPatientInfoService;
import com.github.pagehelper.PageHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.Date;
import java.util.List;
import java.util.Optional;

/**
 * 患者信息Service实现
 *
 * @author YuJian95  clj9509@163.com
 * @date 2020/3/19
 */
@Service
public class PatientInfoServiceImpl implements IPatientInfoService {

    @Autowired
    private PatientInfoMapper patientInfoMapper;

    @Override
    public boolean create(PatientInfo patientInfo) {
        patientInfo.setGmtCreate(new Date());
        patientInfo.setGmtModified(new Date());
        return patientInfoMapper.insertSelective(patientInfo) > 0;
    }

    @Override
    public boolean update(Long id, PatientInfo patientInfo) {
        patientInfo.setId(id);
        patientInfo.setGmtModified(new Date());
        return patientInfoMapper.updateByPrimaryKeySelective(patientInfo) > 0;
    }

    @Override
    public boolean delete(Long id) {
        return patientInfoMapper.deleteByPrimaryKey(id) > 0;
    }

    @Override
    public Optional<PatientInfo> getItem(Long id) {
        return Optional.ofNullable(patientInfoMapper.selectByPrimaryKey(id));
    }

    @Override
    public List<PatientInfo> list(String keyword, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        PatientInfoExample example = new PatientInfoExample();
        PatientInfoExample.Criteria criteria = example.createCriteria();

        if (!StringUtils.isEmpty(keyword)) {
            criteria.andNameLike("%" + keyword + "%");
        }

        example.setOrderByClause("gmt_create desc");
        return patientInfoMapper.selectByExample(example);
    }

    @Override
    public Optional<PatientInfo> getByAccountId(Long accountId) {
        PatientInfoExample example = new PatientInfoExample();
        example.createCriteria().andAccountIdEqualTo(accountId);
        List<PatientInfo> list = patientInfoMapper.selectByExample(example);
        return list.isEmpty() ? Optional.empty() : Optional.of(list.get(0));
    }

    @Override
    public boolean count(Long id) {
        return patientInfoMapper.selectByPrimaryKey(id) != null;
    }
}
