package cn.yujian95.hospital.service.ai;

import cn.yujian95.hospital.dto.ai.StudyUploadParam;
import cn.yujian95.hospital.dto.ai.StudyUploadResult;
import cn.yujian95.hospital.entity.MedicalImaging;
import cn.yujian95.hospital.entity.Study;
import cn.yujian95.hospital.entity.StudyInstance;
import cn.yujian95.hospital.entity.StudySeries;
import cn.yujian95.hospital.mapper.MedicalImagingMapper;
import cn.yujian95.hospital.mapper.StudyInstanceMapper;
import cn.yujian95.hospital.mapper.StudyMapper;
import cn.yujian95.hospital.mapper.StudySeriesMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.Date;
import java.util.List;
import java.util.UUID;

@Service
public class StudyPlatformService {
    @Autowired
    private StudyMapper studyMapper;
    @Autowired
    private StudySeriesMapper seriesMapper;
    @Autowired
    private StudyInstanceMapper instanceMapper;
    @Autowired
    private MedicalImagingMapper medicalImagingMapper;
    @Autowired
    private AuditTrailService auditTrailService;
    @Autowired
    private ObjectStorageService objectStorageService;

    @Transactional
    public StudyUploadResult uploadStudy(StudyUploadParam param) {
        Date now = new Date();
        MedicalImaging imaging = new MedicalImaging();
        imaging.setPatientId(param.getPatientId());
        imaging.setDoctorId(defaultLong(param.getDoctorId(), 0L));
        imaging.setHospitalId(defaultLong(param.getHospitalId(), 1L));
        imaging.setImagingType(defaultString(param.getModality(), "CT"));
        imaging.setBodyPart(defaultString(param.getBodyPart(), "未注明部位"));
        imaging.setFilePath(objectStorageService.imageUri(param.getFileUri(), defaultString(param.getFileName(), "study.bin")));
        imaging.setFileName(defaultString(param.getFileName(), "study.bin"));
        imaging.setFileSize(param.getFileSize());
        imaging.setDescription(param.getDescription());
        imaging.setDiagnosisStatus(0);
        imaging.setGmtCreate(now);
        imaging.setGmtModified(now);
        medicalImagingMapper.insertSelective(imaging);

        Study study = new Study();
        study.setPatientId(param.getPatientId());
        study.setImagingId(imaging.getId());
        study.setStudyUid("ST-" + UUID.randomUUID().toString());
        study.setModality(imaging.getImagingType());
        study.setBodyPart(imaging.getBodyPart());
        study.setStudyTime(now);
        study.setMetadataJson(defaultString(param.getMetadataJson(), "{}"));
        study.setStorageRoot(objectStorageService.storageRoot(imaging.getFilePath()));
        study.setAnonymized(Boolean.TRUE.equals(param.getAnonymized()) ? 1 : 0);
        study.setGmtCreate(now);
        study.setGmtModified(now);
        studyMapper.insertSelective(study);

        StudySeries series = new StudySeries();
        series.setStudyId(study.getId());
        series.setSeriesUid("SE-" + UUID.randomUUID().toString());
        series.setModality(study.getModality());
        series.setDescription(defaultString(param.getSeriesDescription(), study.getBodyPart() + " " + study.getModality()));
        series.setSpacing("0.6934 x 0.6934 x 1.0 mm");
        series.setSliceCount(param.getSliceCount() == null ? 1 : param.getSliceCount());
        series.setMetadataJson(defaultString(param.getMetadataJson(), "{}"));
        series.setGmtCreate(now);
        series.setGmtModified(now);
        seriesMapper.insertSelective(series);

        StudyInstance instance = new StudyInstance();
        instance.setSeriesId(series.getId());
        instance.setSopUid("IM-" + UUID.randomUUID().toString());
        instance.setSliceIndex(1);
        instance.setFileUri(imaging.getFilePath());
        instance.setThumbnailUri(objectStorageService.thumbnailUri(imaging.getFileName()));
        instance.setRenderUri(objectStorageService.renderUri(imaging.getFileName()));
        instance.setMetadataJson(defaultString(param.getMetadataJson(), "{}"));
        instance.setGmtCreate(now);
        instance.setGmtModified(now);
        instanceMapper.insertSelective(instance);

        StudyUploadResult result = new StudyUploadResult();
        result.setStudy(study);
        result.setSeries(series);
        result.setInstance(instance);
        result.setCompatibleImaging(imaging);
        auditTrailService.record("system", "影像标准数据入库", "/api/studies/upload", imaging.getFileName(), study.getStudyUid());
        return result;
    }

    @Transactional
    public StudyUploadResult uploadStudy(StudyUploadParam param, MultipartFile file) throws Exception {
        if (file != null && !file.isEmpty()) {
            param.setFileName(defaultString(file.getOriginalFilename(), defaultString(param.getFileName(), "study.bin")));
            param.setFileSize(file.getSize());
            param.setFileUri(objectStorageService.uploadFile(file, "studies"));
        }
        return uploadStudy(param);
    }

    public Study getStudy(Long id) {
        return studyMapper.selectByPrimaryKey(id);
    }

    public List<Study> listStudies(Long patientId, String modality, String bodyPart) {
        return studyMapper.selectList(patientId, modality, bodyPart);
    }

    public List<StudySeries> getSeries(Long studyId) {
        return seriesMapper.selectByStudyId(studyId);
    }

    public List<StudyInstance> getInstances(Long seriesId) {
        return instanceMapper.selectBySeriesId(seriesId);
    }

    public StudyInstance getInstance(Long id) {
        return instanceMapper.selectByPrimaryKey(id);
    }

    private String defaultString(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value;
    }

    private Long defaultLong(Long value, Long fallback) {
        return value == null ? fallback : value;
    }
}
