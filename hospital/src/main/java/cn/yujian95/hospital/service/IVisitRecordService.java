package cn.yujian95.hospital.service;

import cn.yujian95.hospital.entity.VisitRecord;

import java.util.List;
import java.util.Optional;

/**
 * 就诊记录接口
 *
 * @author YuJian95  clj9509@163.com
 * @date 2020/3/19
 */
public interface IVisitRecordService {

    /**
     * 创建就诊记录
     *
     * @param visitRecord 就诊记录
     * @return 是否成功
     */
    boolean create(VisitRecord visitRecord);

    /**
     * 更新就诊记录
     *
     * @param id          就诊编号
     * @param visitRecord 就诊记录
     * @return 是否成功
     */
    boolean update(Long id, VisitRecord visitRecord);

    /**
     * 删除就诊记录
     *
     * @param id 就诊编号
     * @return 是否成功
     */
    boolean delete(Long id);

    /**
     * 获取就诊记录详情
     *
     * @param id 就诊编号
     * @return 就诊记录
     */
    Optional<VisitRecord> getItem(Long id);

    /**
     * 分页查询就诊记录列表
     *
     * @param patientId   患者编号
     * @param doctorId    医生编号
     * @param visitStatus 就诊状态
     * @param pageNum     第几页
     * @param pageSize    页大小
     * @return 就诊记录列表
     */
    List<VisitRecord> list(Long patientId, Long doctorId, Integer visitStatus, Integer pageNum, Integer pageSize);

    /**
     * 更新就诊状态
     *
     * @param id          就诊编号
     * @param visitStatus 就诊状态
     * @return 是否成功
     */
    boolean updateStatus(Long id, Integer visitStatus);

    /**
     * 获取患者的就诊记录
     *
     * @param patientId 患者编号
     * @return 就诊记录列表
     */
    List<VisitRecord> getByPatientId(Long patientId);

    /**
     * 判断就诊记录是否存在
     *
     * @param id 就诊编号
     * @return 是否存在
     */
    boolean count(Long id);
}
