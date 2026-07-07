package cn.yujian95.hospital.service.ai;

import cn.yujian95.hospital.entity.LogOperation;
import cn.yujian95.hospital.mapper.LogOperationMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;

@Service
public class AuditTrailService {
    @Autowired(required = false)
    private LogOperationMapper logOperationMapper;

    public void record(String accountName, String action, String uri, String parameter, String result) {
        if (logOperationMapper == null) {
            return;
        }
        LogOperation log = new LogOperation();
        log.setAccountName(accountName == null ? "system" : accountName);
        log.setStartTime(System.currentTimeMillis());
        log.setSpendTime(0);
        log.setDescription(action);
        log.setBasePath("/hospital");
        log.setUri(uri);
        log.setUrl(uri);
        log.setMethod("API");
        log.setIpAddress("127.0.0.1");
        log.setParameter(trim(parameter, 900));
        log.setResult(trim(result, 1800));
        log.setGmtCreate(new Date());
        log.setGmtModified(new Date());
        logOperationMapper.insertSelective(log);
    }

    private String trim(String value, int max) {
        if (value == null) {
            return "";
        }
        return value.length() > max ? value.substring(0, max) : value;
    }
}
