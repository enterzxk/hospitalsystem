package cn.yujian95.hospital.service;

import cn.yujian95.hospital.entity.PatientInfo;

import java.util.List;
import java.util.Optional;

/**
 * 患者信息接口
 *
 * @author YuJian95  clj9509@163.com
 * @date 2020/3/19
 */
public interface IPatientInfoService {

    /**
     * 创建患者信息
     *
     * @param patientInfo 患者信息
     * @return 是否成功
     */
    boolean create(PatientInfo patientInfo);

    /**
     * 更新患者信息
     *
     * @param id          患者编号
     * @param patientInfo 患者信息
     * @return 是否成功
     */
    boolean update(Long id, PatientInfo patientInfo);

    /**
     * 删除患者信息
     *
     * @param id 患者编号
     * @return 是否成功
     */
    boolean delete(Long id);

    /**
     * 获取患者信息
     *
     * @param id 患者编号
     * @return 患者信息
     */
    Optional<PatientInfo> getItem(Long id);

    /**
     * 分页查询患者列表
     *
     * @param keyword  关键词（姓名、手机号）
     * @param pageNum  第几页
     * @param pageSize 页大小
     * @return 患者列表
     */
    List<PatientInfo> list(String keyword, Integer pageNum, Integer pageSize);

    /**
     * 根据账号ID获取患者信息
     *
     * @param accountId 账号ID
     * @return 患者信息
     */
    Optional<PatientInfo> getByAccountId(Long accountId);

    /**
     * 判断患者信息是否存在
     *
     * @param id 患者编号
     * @return 是否存在
     */
    boolean count(Long id);
}
