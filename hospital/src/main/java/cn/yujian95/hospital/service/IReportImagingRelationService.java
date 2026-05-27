package cn.yujian95.hospital.service;

import cn.yujian95.hospital.entity.ReportImagingRelation;

import java.util.List;

/**
 * 报告影像关联接口
 *
 * @author YuJian95  clj9509@163.com
 * @date 2020/3/19
 */
public interface IReportImagingRelationService {

    /**
     * 创建关联
     *
     * @param relation 关联信息
     * @return 是否成功
     */
    boolean create(ReportImagingRelation relation);

    /**
     * 删除关联
     *
     * @param reportId  报告编号
     * @param imagingId 影像编号
     * @return 是否成功
     */
    boolean delete(Long reportId, Long imagingId);

    /**
     * 获取报告关联的影像ID列表
     *
     * @param reportId 报告编号
     * @return 影像ID列表
     */
    List<Long> getImagingIdsByReportId(Long reportId);

    /**
     * 获取影像关联的报告ID列表
     *
     * @param imagingId 影像编号
     * @return 报告ID列表
     */
    List<Long> getReportIdsByImagingId(Long imagingId);
}
