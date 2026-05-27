package cn.yujian95.hospital.service;

import cn.yujian95.hospital.entity.DiagnosisReport;
import cn.yujian95.hospital.entity.MedicalImaging;

import java.util.List;
import java.util.Optional;

/**
 * 诊断报告接口
 *
 * @author YuJian95  clj9509@163.com
 * @date 2020/3/19
 */
public interface IDiagnosisReportService {

    /**
     * 创建诊断报告
     *
     * @param report 诊断报告
     * @return 是否成功
     */
    boolean create(DiagnosisReport report);

    /**
     * 更新诊断报告
     *
     * @param id     报告编号
     * @param report 诊断报告
     * @return 是否成功
     */
    boolean update(Long id, DiagnosisReport report);

    /**
     * 删除诊断报告
     *
     * @param id 报告编号
     * @return 是否成功
     */
    boolean delete(Long id);

    /**
     * 获取诊断报告详情
     *
     * @param id 报告编号
     * @return 诊断报告
     */
    Optional<DiagnosisReport> getItem(Long id);

    /**
     * 分页查询诊断报告列表
     *
     * @param patientId    患者编号
     * @param doctorId     医生编号
     * @param reportStatus 报告状态
     * @param pageNum      第几页
     * @param pageSize     页大小
     * @return 诊断报告列表
     */
    List<DiagnosisReport> list(Long patientId, Long doctorId, Integer reportStatus, Integer pageNum, Integer pageSize);

    /**
     * 提交报告
     *
     * @param id 报告编号
     * @return 是否成功
     */
    boolean submit(Long id);

    /**
     * 审核报告
     *
     * @param id           报告编号
     * @param reviewerId   审核医生编号
     * @param reviewOpinion 审核意见
     * @return 是否成功
     */
    boolean review(Long id, Long reviewerId, String reviewOpinion);

    /**
     * 关联影像
     *
     * @param reportId   报告编号
     * @param imagingIds 影像编号列表
     * @return 是否成功
     */
    boolean relateImaging(Long reportId, List<Long> imagingIds);

    /**
     * 获取报告关联的影像
     *
     * @param reportId 报告编号
     * @return 影像列表
     */
    List<MedicalImaging> getReportImagings(Long reportId);

    /**
     * 判断报告是否存在
     *
     * @param id 报告编号
     * @return 是否存在
     */
    boolean count(Long id);
}
