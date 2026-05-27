package cn.yujian95.hospital.entity;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class MedicalImagingExample {
    protected String orderByClause;

    protected boolean distinct;

    protected List<Criteria> oredCriteria;

    public MedicalImagingExample() {
        oredCriteria = new ArrayList<Criteria>();
    }

    public void setOrderByClause(String orderByClause) {
        this.orderByClause = orderByClause;
    }

    public String getOrderByClause() {
        return orderByClause;
    }

    public void setDistinct(boolean distinct) {
        this.distinct = distinct;
    }

    public boolean isDistinct() {
        return distinct;
    }

    public List<Criteria> getOredCriteria() {
        return oredCriteria;
    }

    public void or(Criteria criteria) {
        oredCriteria.add(criteria);
    }

    public Criteria or() {
        Criteria criteria = createCriteriaInternal();
        oredCriteria.add(criteria);
        return criteria;
    }

    public Criteria createCriteria() {
        Criteria criteria = createCriteriaInternal();
        if (oredCriteria.size() == 0) {
            oredCriteria.add(criteria);
        }
        return criteria;
    }

    protected Criteria createCriteriaInternal() {
        Criteria criteria = new Criteria();
        return criteria;
    }

    public void clear() {
        oredCriteria.clear();
        orderByClause = null;
        distinct = false;
    }

    protected abstract static class GeneratedCriteria {
        protected List<Criterion> criteria;

        protected GeneratedCriteria() {
            super();
            criteria = new ArrayList<Criterion>();
        }

        public boolean isValid() {
            return criteria.size() > 0;
        }

        public List<Criterion> getAllCriteria() {
            return criteria;
        }

        public List<Criterion> getCriteria() {
            return criteria;
        }

        protected void addCriterion(String condition) {
            if (condition == null) {
                throw new RuntimeException("Value for condition cannot be null");
            }
            criteria.add(new Criterion(condition));
        }

        protected void addCriterion(String condition, Object value, String property) {
            if (value == null) {
                throw new RuntimeException("Value for " + property + " cannot be null");
            }
            criteria.add(new Criterion(condition, value));
        }

        protected void addCriterion(String condition, Object value1, Object value2, String property) {
            if (value1 == null || value2 == null) {
                throw new RuntimeException("Between values for " + property + " cannot be null");
            }
            criteria.add(new Criterion(condition, value1, value2));
        }

        public Criteria andIdIsNull() {
            addCriterion("id is null");
            return (Criteria) this;
        }

        public Criteria andIdIsNotNull() {
            addCriterion("id is not null");
            return (Criteria) this;
        }

        public Criteria andIdEqualTo(Long value) {
            addCriterion("id =", value, "id");
            return (Criteria) this;
        }

        public Criteria andIdNotEqualTo(Long value) {
            addCriterion("id <>", value, "id");
            return (Criteria) this;
        }

        public Criteria andIdGreaterThan(Long value) {
            addCriterion("id >", value, "id");
            return (Criteria) this;
        }

        public Criteria andIdGreaterThanOrEqualTo(Long value) {
            addCriterion("id >=", value, "id");
            return (Criteria) this;
        }

        public Criteria andIdLessThan(Long value) {
            addCriterion("id <", value, "id");
            return (Criteria) this;
        }

        public Criteria andIdLessThanOrEqualTo(Long value) {
            addCriterion("id <=", value, "id");
            return (Criteria) this;
        }

        public Criteria andIdIn(List<Long> values) {
            addCriterion("id in", values, "id");
            return (Criteria) this;
        }

        public Criteria andIdNotIn(List<Long> values) {
            addCriterion("id not in", values, "id");
            return (Criteria) this;
        }

        public Criteria andIdBetween(Long value1, Long value2) {
            addCriterion("id between", value1, value2, "id");
            return (Criteria) this;
        }

        public Criteria andIdNotBetween(Long value1, Long value2) {
            addCriterion("id not between", value1, value2, "id");
            return (Criteria) this;
        }

        public Criteria andPatientIdIsNull() {
            addCriterion("patient_id is null");
            return (Criteria) this;
        }

        public Criteria andPatientIdIsNotNull() {
            addCriterion("patient_id is not null");
            return (Criteria) this;
        }

        public Criteria andPatientIdEqualTo(Long value) {
            addCriterion("patient_id =", value, "patientId");
            return (Criteria) this;
        }

        public Criteria andPatientIdNotEqualTo(Long value) {
            addCriterion("patient_id <>", value, "patientId");
            return (Criteria) this;
        }

        public Criteria andPatientIdGreaterThan(Long value) {
            addCriterion("patient_id >", value, "patientId");
            return (Criteria) this;
        }

        public Criteria andPatientIdGreaterThanOrEqualTo(Long value) {
            addCriterion("patient_id >=", value, "patientId");
            return (Criteria) this;
        }

        public Criteria andPatientIdLessThan(Long value) {
            addCriterion("patient_id <", value, "patientId");
            return (Criteria) this;
        }

        public Criteria andPatientIdLessThanOrEqualTo(Long value) {
            addCriterion("patient_id <=", value, "patientId");
            return (Criteria) this;
        }

        public Criteria andPatientIdIn(List<Long> values) {
            addCriterion("patient_id in", values, "patientId");
            return (Criteria) this;
        }

        public Criteria andPatientIdNotIn(List<Long> values) {
            addCriterion("patient_id not in", values, "patientId");
            return (Criteria) this;
        }

        public Criteria andPatientIdBetween(Long value1, Long value2) {
            addCriterion("patient_id between", value1, value2, "patientId");
            return (Criteria) this;
        }

        public Criteria andPatientIdNotBetween(Long value1, Long value2) {
            addCriterion("patient_id not between", value1, value2, "patientId");
            return (Criteria) this;
        }

        public Criteria andDoctorIdIsNull() {
            addCriterion("doctor_id is null");
            return (Criteria) this;
        }

        public Criteria andDoctorIdIsNotNull() {
            addCriterion("doctor_id is not null");
            return (Criteria) this;
        }

        public Criteria andDoctorIdEqualTo(Long value) {
            addCriterion("doctor_id =", value, "doctorId");
            return (Criteria) this;
        }

        public Criteria andDoctorIdNotEqualTo(Long value) {
            addCriterion("doctor_id <>", value, "doctorId");
            return (Criteria) this;
        }

        public Criteria andDoctorIdGreaterThan(Long value) {
            addCriterion("doctor_id >", value, "doctorId");
            return (Criteria) this;
        }

        public Criteria andDoctorIdGreaterThanOrEqualTo(Long value) {
            addCriterion("doctor_id >=", value, "doctorId");
            return (Criteria) this;
        }

        public Criteria andDoctorIdLessThan(Long value) {
            addCriterion("doctor_id <", value, "doctorId");
            return (Criteria) this;
        }

        public Criteria andDoctorIdLessThanOrEqualTo(Long value) {
            addCriterion("doctor_id <=", value, "doctorId");
            return (Criteria) this;
        }

        public Criteria andDoctorIdIn(List<Long> values) {
            addCriterion("doctor_id in", values, "doctorId");
            return (Criteria) this;
        }

        public Criteria andDoctorIdNotIn(List<Long> values) {
            addCriterion("doctor_id not in", values, "doctorId");
            return (Criteria) this;
        }

        public Criteria andDoctorIdBetween(Long value1, Long value2) {
            addCriterion("doctor_id between", value1, value2, "doctorId");
            return (Criteria) this;
        }

        public Criteria andDoctorIdNotBetween(Long value1, Long value2) {
            addCriterion("doctor_id not between", value1, value2, "doctorId");
            return (Criteria) this;
        }

        public Criteria andHospitalIdIsNull() {
            addCriterion("hospital_id is null");
            return (Criteria) this;
        }

        public Criteria andHospitalIdIsNotNull() {
            addCriterion("hospital_id is not null");
            return (Criteria) this;
        }

        public Criteria andHospitalIdEqualTo(Long value) {
            addCriterion("hospital_id =", value, "hospitalId");
            return (Criteria) this;
        }

        public Criteria andHospitalIdNotEqualTo(Long value) {
            addCriterion("hospital_id <>", value, "hospitalId");
            return (Criteria) this;
        }

        public Criteria andHospitalIdGreaterThan(Long value) {
            addCriterion("hospital_id >", value, "hospitalId");
            return (Criteria) this;
        }

        public Criteria andHospitalIdGreaterThanOrEqualTo(Long value) {
            addCriterion("hospital_id >=", value, "hospitalId");
            return (Criteria) this;
        }

        public Criteria andHospitalIdLessThan(Long value) {
            addCriterion("hospital_id <", value, "hospitalId");
            return (Criteria) this;
        }

        public Criteria andHospitalIdLessThanOrEqualTo(Long value) {
            addCriterion("hospital_id <=", value, "hospitalId");
            return (Criteria) this;
        }

        public Criteria andHospitalIdIn(List<Long> values) {
            addCriterion("hospital_id in", values, "hospitalId");
            return (Criteria) this;
        }

        public Criteria andHospitalIdNotIn(List<Long> values) {
            addCriterion("hospital_id not in", values, "hospitalId");
            return (Criteria) this;
        }

        public Criteria andHospitalIdBetween(Long value1, Long value2) {
            addCriterion("hospital_id between", value1, value2, "hospitalId");
            return (Criteria) this;
        }

        public Criteria andHospitalIdNotBetween(Long value1, Long value2) {
            addCriterion("hospital_id not between", value1, value2, "hospitalId");
            return (Criteria) this;
        }

        public Criteria andImagingTypeIsNull() {
            addCriterion("imaging_type is null");
            return (Criteria) this;
        }

        public Criteria andImagingTypeIsNotNull() {
            addCriterion("imaging_type is not null");
            return (Criteria) this;
        }

        public Criteria andImagingTypeEqualTo(String value) {
            addCriterion("imaging_type =", value, "imagingType");
            return (Criteria) this;
        }

        public Criteria andImagingTypeNotEqualTo(String value) {
            addCriterion("imaging_type <>", value, "imagingType");
            return (Criteria) this;
        }

        public Criteria andImagingTypeGreaterThan(String value) {
            addCriterion("imaging_type >", value, "imagingType");
            return (Criteria) this;
        }

        public Criteria andImagingTypeGreaterThanOrEqualTo(String value) {
            addCriterion("imaging_type >=", value, "imagingType");
            return (Criteria) this;
        }

        public Criteria andImagingTypeLessThan(String value) {
            addCriterion("imaging_type <", value, "imagingType");
            return (Criteria) this;
        }

        public Criteria andImagingTypeLessThanOrEqualTo(String value) {
            addCriterion("imaging_type <=", value, "imagingType");
            return (Criteria) this;
        }

        public Criteria andImagingTypeLike(String value) {
            addCriterion("imaging_type like", value, "imagingType");
            return (Criteria) this;
        }

        public Criteria andImagingTypeNotLike(String value) {
            addCriterion("imaging_type not like", value, "imagingType");
            return (Criteria) this;
        }

        public Criteria andImagingTypeIn(List<String> values) {
            addCriterion("imaging_type in", values, "imagingType");
            return (Criteria) this;
        }

        public Criteria andImagingTypeNotIn(List<String> values) {
            addCriterion("imaging_type not in", values, "imagingType");
            return (Criteria) this;
        }

        public Criteria andImagingTypeBetween(String value1, String value2) {
            addCriterion("imaging_type between", value1, value2, "imagingType");
            return (Criteria) this;
        }

        public Criteria andImagingTypeNotBetween(String value1, String value2) {
            addCriterion("imaging_type not between", value1, value2, "imagingType");
            return (Criteria) this;
        }

        public Criteria andBodyPartIsNull() {
            addCriterion("body_part is null");
            return (Criteria) this;
        }

        public Criteria andBodyPartIsNotNull() {
            addCriterion("body_part is not null");
            return (Criteria) this;
        }

        public Criteria andBodyPartEqualTo(String value) {
            addCriterion("body_part =", value, "bodyPart");
            return (Criteria) this;
        }

        public Criteria andBodyPartNotEqualTo(String value) {
            addCriterion("body_part <>", value, "bodyPart");
            return (Criteria) this;
        }

        public Criteria andBodyPartGreaterThan(String value) {
            addCriterion("body_part >", value, "bodyPart");
            return (Criteria) this;
        }

        public Criteria andBodyPartGreaterThanOrEqualTo(String value) {
            addCriterion("body_part >=", value, "bodyPart");
            return (Criteria) this;
        }

        public Criteria andBodyPartLessThan(String value) {
            addCriterion("body_part <", value, "bodyPart");
            return (Criteria) this;
        }

        public Criteria andBodyPartLessThanOrEqualTo(String value) {
            addCriterion("body_part <=", value, "bodyPart");
            return (Criteria) this;
        }

        public Criteria andBodyPartLike(String value) {
            addCriterion("body_part like", value, "bodyPart");
            return (Criteria) this;
        }

        public Criteria andBodyPartNotLike(String value) {
            addCriterion("body_part not like", value, "bodyPart");
            return (Criteria) this;
        }

        public Criteria andBodyPartIn(List<String> values) {
            addCriterion("body_part in", values, "bodyPart");
            return (Criteria) this;
        }

        public Criteria andBodyPartNotIn(List<String> values) {
            addCriterion("body_part not in", values, "bodyPart");
            return (Criteria) this;
        }

        public Criteria andBodyPartBetween(String value1, String value2) {
            addCriterion("body_part between", value1, value2, "bodyPart");
            return (Criteria) this;
        }

        public Criteria andBodyPartNotBetween(String value1, String value2) {
            addCriterion("body_part not between", value1, value2, "bodyPart");
            return (Criteria) this;
        }

        public Criteria andDiagnosisStatusIsNull() {
            addCriterion("diagnosis_status is null");
            return (Criteria) this;
        }

        public Criteria andDiagnosisStatusIsNotNull() {
            addCriterion("diagnosis_status is not null");
            return (Criteria) this;
        }

        public Criteria andDiagnosisStatusEqualTo(Integer value) {
            addCriterion("diagnosis_status =", value, "diagnosisStatus");
            return (Criteria) this;
        }

        public Criteria andDiagnosisStatusNotEqualTo(Integer value) {
            addCriterion("diagnosis_status <>", value, "diagnosisStatus");
            return (Criteria) this;
        }

        public Criteria andDiagnosisStatusGreaterThan(Integer value) {
            addCriterion("diagnosis_status >", value, "diagnosisStatus");
            return (Criteria) this;
        }

        public Criteria andDiagnosisStatusGreaterThanOrEqualTo(Integer value) {
            addCriterion("diagnosis_status >=", value, "diagnosisStatus");
            return (Criteria) this;
        }

        public Criteria andDiagnosisStatusLessThan(Integer value) {
            addCriterion("diagnosis_status <", value, "diagnosisStatus");
            return (Criteria) this;
        }

        public Criteria andDiagnosisStatusLessThanOrEqualTo(Integer value) {
            addCriterion("diagnosis_status <=", value, "diagnosisStatus");
            return (Criteria) this;
        }

        public Criteria andDiagnosisStatusIn(List<Integer> values) {
            addCriterion("diagnosis_status in", values, "diagnosisStatus");
            return (Criteria) this;
        }

        public Criteria andDiagnosisStatusNotIn(List<Integer> values) {
            addCriterion("diagnosis_status not in", values, "diagnosisStatus");
            return (Criteria) this;
        }

        public Criteria andDiagnosisStatusBetween(Integer value1, Integer value2) {
            addCriterion("diagnosis_status between", value1, value2, "diagnosisStatus");
            return (Criteria) this;
        }

        public Criteria andDiagnosisStatusNotBetween(Integer value1, Integer value2) {
            addCriterion("diagnosis_status not between", value1, value2, "diagnosisStatus");
            return (Criteria) this;
        }
    }

    public static class Criteria extends GeneratedCriteria {

        protected Criteria() {
            super();
        }
    }

    public static class Criterion {
        private String condition;

        private Object value;

        private Object secondValue;

        private boolean noValue;

        private boolean singleValue;

        private boolean betweenValue;

        private boolean listValue;

        private String typeHandler;

        public String getCondition() {
            return condition;
        }

        public Object getValue() {
            return value;
        }

        public Object getSecondValue() {
            return secondValue;
        }

        public boolean isNoValue() {
            return noValue;
        }

        public boolean isSingleValue() {
            return singleValue;
        }

        public boolean isBetweenValue() {
            return betweenValue;
        }

        public boolean isListValue() {
            return listValue;
        }

        public String getTypeHandler() {
            return typeHandler;
        }

        protected Criterion(String condition) {
            super();
            this.condition = condition;
            this.typeHandler = null;
            this.noValue = true;
        }

        protected Criterion(String condition, Object value, String typeHandler) {
            super();
            this.condition = condition;
            this.value = value;
            this.typeHandler = typeHandler;
            if (value instanceof List<?>) {
                this.listValue = true;
            } else {
                this.singleValue = true;
            }
        }

        protected Criterion(String condition, Object value) {
            this(condition, value, null);
        }

        protected Criterion(String condition, Object value, Object secondValue, String typeHandler) {
            super();
            this.condition = condition;
            this.value = value;
            this.secondValue = secondValue;
            this.typeHandler = typeHandler;
            this.betweenValue = true;
        }

        protected Criterion(String condition, Object value, Object secondValue) {
            this(condition, value, secondValue, null);
        }
    }
}
