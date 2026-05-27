package cn.yujian95.hospital.entity;

import io.swagger.annotations.ApiModelProperty;
import java.io.Serializable;
import java.util.Date;

public class ReportImagingRelation implements Serializable {
    /**
     * 关系编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "关系编号")
    private Long id;

    /**
     * 报告编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "报告编号")
    private Long reportId;

    /**
     * 影像编号
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "影像编号")
    private Long imagingId;

    /**
     * 创建时间
     *
     * @mbg.generated
     */
    @ApiModelProperty(value = "创建时间")
    private Date gmtCreate;

    private static final long serialVersionUID = 1L;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getReportId() {
        return reportId;
    }

    public void setReportId(Long reportId) {
        this.reportId = reportId;
    }

    public Long getImagingId() {
        return imagingId;
    }

    public void setImagingId(Long imagingId) {
        this.imagingId = imagingId;
    }

    public Date getGmtCreate() {
        return gmtCreate;
    }

    public void setGmtCreate(Date gmtCreate) {
        this.gmtCreate = gmtCreate;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(hashCode());
        sb.append(", id=").append(id);
        sb.append(", reportId=").append(reportId);
        sb.append(", imagingId=").append(imagingId);
        sb.append(", gmtCreate=").append(gmtCreate);
        sb.append(", serialVersionUID=").append(serialVersionUID);
        sb.append("]");
        return sb.toString();
    }
}
