package cn.yujian95.hospital.service;

import cn.yujian95.hospital.entity.MedicalImaging;

import java.util.List;
import java.util.Optional;

/**
 * 医学影像接口
 *
 * @author YuJian95  clj9509@163.com
 * @date 2020/3/19
 */
public interface IMedicalImagingService {

    /**
     * 上传影像
     *
     * @param medicalImaging 影像信息
     * @return 是否成功
     */
    boolean create(MedicalImaging medicalImaging);

    /**
     * 更新影像信息
     *
     * @param id             影像编号
     * @param medicalImaging 影像信息
     * @return 是否成功
     */
    boolean update(Long id, MedicalImaging medicalImaging);

    /**
     * 删除影像
     *
     * @param id 影像编号
     * @return 是否成功
     */
    boolean delete(Long id);

    /**
     * 获取影像详情
     *
     * @param id 影像编号
     * @return 影像信息
     */
    Optional<MedicalImaging> getItem(Long id);

    /**
     * 分页查询影像列表
     *
     * @param patientId      患者编号
     * @param imagingType    影像类型
     * @param diagnosisStatus 诊断状态
     * @param pageNum        第几页
     * @param pageSize       页大小
     * @return 影像列表
     */
    List<MedicalImaging> list(Long patientId, String imagingType, Integer diagnosisStatus, Integer pageNum, Integer pageSize);

    /**
     * 更新诊断状态
     *
     * @param id              影像编号
     * @param diagnosisStatus 诊断状态
     * @return 是否成功
     */
    boolean updateDiagnosisStatus(Long id, Integer diagnosisStatus);

    /**
     * 获取患者的所有影像
     *
     * @param patientId 患者编号
     * @return 影像列表
     */
    List<MedicalImaging> getByPatientId(Long patientId);

    /**
     * 判断影像是否存在
     *
     * @param id 影像编号
     * @return 是否存在
     */
    boolean count(Long id);
}
