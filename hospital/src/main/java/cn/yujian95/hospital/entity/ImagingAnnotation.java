package cn.yujian95.hospital.entity;

import io.swagger.annotations.ApiModelProperty;
import java.io.Serializable;
import java.util.Date;

public class ImagingAnnotation implements Serializable {
    @ApiModelProperty(value = "标注编号")
    private Long id;

    @ApiModelProperty(value = "影像编号")
    private Long imagingId;

    @ApiModelProperty(value = "标注医生编号")
    private Long doctorId;

    @ApiModelProperty(value = "标注类型：point/rect/freehand/brush")
    private String annotationType;

    @ApiModelProperty(value = "标注数据(JSON)")
    private String annotationData;

    @ApiModelProperty(value = "标注标签")
    private String label;

    @ApiModelProperty(value = "标注颜色")
    private String color;

    @ApiModelProperty(value = "创建时间")
    private Date gmtCreate;

    private static final long serialVersionUID = 1L;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getImagingId() { return imagingId; }
    public void setImagingId(Long imagingId) { this.imagingId = imagingId; }
    public Long getDoctorId() { return doctorId; }
    public void setDoctorId(Long doctorId) { this.doctorId = doctorId; }
    public String getAnnotationType() { return annotationType; }
    public void setAnnotationType(String annotationType) { this.annotationType = annotationType == null ? null : annotationType.trim(); }
    public String getAnnotationData() { return annotationData; }
    public void setAnnotationData(String annotationData) { this.annotationData = annotationData == null ? null : annotationData.trim(); }
    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label == null ? null : label.trim(); }
    public String getColor() { return color; }
    public void setColor(String color) { this.color = color == null ? null : color.trim(); }
    public Date getGmtCreate() { return gmtCreate; }
    public void setGmtCreate(Date gmtCreate) { this.gmtCreate = gmtCreate; }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(getClass().getSimpleName());
        sb.append(" [");
        sb.append("Hash = ").append(hashCode());
        sb.append(", id=").append(id);
        sb.append(", imagingId=").append(imagingId);
        sb.append(", doctorId=").append(doctorId);
        sb.append(", annotationType=").append(annotationType);
        sb.append(", label=").append(label);
        sb.append(", color=").append(color);
        sb.append("]");
        return sb.toString();
    }
}
