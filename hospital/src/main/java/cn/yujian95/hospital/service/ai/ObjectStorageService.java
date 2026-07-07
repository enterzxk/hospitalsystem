package cn.yujian95.hospital.service.ai;

import cn.yujian95.hospital.config.ObjectStorageProperties;
import io.minio.BucketExistsArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import java.io.IOException;
import java.io.InputStream;
import java.io.ByteArrayInputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class ObjectStorageService {
    @Resource
    private ObjectStorageProperties properties;

    public String imageUri(String existingUri, String fileName) {
        return resolveUri(existingUri, "studies", fileName);
    }

    public String thumbnailUri(String fileName) {
        return buildUri("thumbnails", safeFileName(fileName, "thumbnail.png"));
    }

    public String renderUri(String fileName) {
        return buildUri("renders", safeFileName(fileName, "render.png"));
    }

    public String maskUri(Long imagingId, String instanceId, Integer sliceIndex, String modelId) {
        String objectName = String.format("masks/%s/%s/%s/%s.png",
                imagingId == null ? "unknown-imaging" : imagingId,
                safePath(instanceId, "unknown-instance"),
                sliceIndex == null ? 0 : sliceIndex,
                safePath(modelId, "unknown-model"));
        return rootUri() + "/" + objectName;
    }

    public String modelWeightUri(String modelId, String fileName) {
        return buildUri("models/" + safePath(modelId, "unregistered"), safeFileName(fileName, "weights.bin"));
    }

    public String uploadFile(MultipartFile file, String category) throws Exception {
        String objectName = objectName(category, safeFileName(file.getOriginalFilename(), "upload.bin"));
        if ("nas".equals(provider())) {
            Path target = Paths.get(properties.getNasRoot()).resolve(objectName).normalize();
            Files.createDirectories(target.getParent());
            file.transferTo(target.toFile());
            return rootUri() + "/" + objectName;
        }
        MinioClient client = minioClient();
        ensureBucket(client);
        try (InputStream inputStream = file.getInputStream()) {
            client.putObject(PutObjectArgs.builder()
                    .bucket(properties.getBucket())
                    .object(objectName)
                    .stream(inputStream, file.getSize(), -1)
                    .contentType(file.getContentType() == null ? "application/octet-stream" : file.getContentType())
                    .build());
        } catch (IOException ex) {
            throw new IOException("读取上传文件失败", ex);
        }
        return rootUri() + "/" + objectName;
    }

    public String uploadBytes(byte[] bytes, String category, String fileName, String contentType) throws Exception {
        String objectName = objectName(category, safeFileName(fileName, "object.bin"));
        if ("nas".equals(provider())) {
            Path target = Paths.get(properties.getNasRoot()).resolve(objectName).normalize();
            Files.createDirectories(target.getParent());
            Files.write(target, bytes);
            return rootUri() + "/" + objectName;
        }
        MinioClient client = minioClient();
        ensureBucket(client);
        try (InputStream inputStream = new ByteArrayInputStream(bytes)) {
            client.putObject(PutObjectArgs.builder()
                    .bucket(properties.getBucket())
                    .object(objectName)
                    .stream(inputStream, bytes.length, -1)
                    .contentType(contentType == null ? "application/octet-stream" : contentType)
                    .build());
        }
        return rootUri() + "/" + objectName;
    }

    public String storageRoot(String uri) {
        if (uri == null || uri.trim().isEmpty()) {
            return rootUri();
        }
        int lastSlash = uri.lastIndexOf('/');
        return lastSlash > 0 ? uri.substring(0, lastSlash) : rootUri();
    }

    public Map<String, Object> status() {
        Map<String, Object> status = new LinkedHashMap<>();
        status.put("provider", provider());
        status.put("bucket", properties.getBucket());
        status.put("endpoint", properties.getEndpoint());
        if ("nas".equals(provider())) {
            status.put("state", "CONFIGURED");
            status.put("root", properties.getNasRoot());
            return status;
        }
        try {
            MinioClient client = minioClient();
            boolean exists = client.bucketExists(BucketExistsArgs.builder().bucket(properties.getBucket()).build());
            status.put("state", exists ? "UP" : "BUCKET_MISSING");
        } catch (Exception ex) {
            status.put("state", "DOWN");
            status.put("error", ex.getClass().getSimpleName() + ": " + ex.getMessage());
        }
        return status;
    }

    private String resolveUri(String existingUri, String category, String fileName) {
        if (existingUri != null && (existingUri.startsWith("minio://") || existingUri.startsWith("nas://"))) {
            return existingUri;
        }
        return buildUri(category, safeFileName(fileName, "study.bin"));
    }

    private String buildUri(String category, String fileName) {
        return rootUri() + "/" + objectName(category, fileName);
    }

    private String objectName(String category, String fileName) {
        String datePath = new SimpleDateFormat("yyyyMMdd").format(new Date());
        return safeObjectPrefix(category) + "/" + datePath + "/" + UUID.randomUUID() + "-" + fileName;
    }

    private String rootUri() {
        if ("nas".equals(provider())) {
            return "nas://" + trimSlashes(properties.getNasRoot());
        }
        return "minio://" + properties.getBucket();
    }

    private String provider() {
        return properties.getProvider() == null ? "minio" : properties.getProvider().trim().toLowerCase();
    }

    private MinioClient minioClient() {
        return MinioClient.builder()
                .endpoint(properties.getEndpoint())
                .credentials(properties.getAccessKey(), properties.getSecretKey())
                .build();
    }

    private void ensureBucket(MinioClient client) throws Exception {
        boolean exists = client.bucketExists(BucketExistsArgs.builder().bucket(properties.getBucket()).build());
        if (!exists) {
            client.makeBucket(MakeBucketArgs.builder().bucket(properties.getBucket()).build());
        }
    }

    private String safeFileName(String value, String fallback) {
        String raw = value == null || value.trim().isEmpty() ? fallback : value.trim();
        String normalized = raw.replace('\\', '/');
        return normalized.substring(normalized.lastIndexOf('/') + 1);
    }

    private String safePath(String value, String fallback) {
        String raw = value == null || value.trim().isEmpty() ? fallback : value.trim();
        return raw.replaceAll("[^A-Za-z0-9._-]", "_");
    }

    private String safeObjectPrefix(String value) {
        String raw = value == null || value.trim().isEmpty() ? "misc" : value.trim().replace('\\', '/');
        StringBuilder builder = new StringBuilder();
        for (String part : raw.split("/")) {
            if (part.trim().isEmpty()) {
                continue;
            }
            if (builder.length() > 0) {
                builder.append('/');
            }
            builder.append(safePath(part, "misc"));
        }
        return builder.length() == 0 ? "misc" : builder.toString();
    }

    private String trimSlashes(String value) {
        String raw = value == null ? "data/medical-imaging" : value.trim().replace('\\', '/');
        while (raw.startsWith("/")) {
            raw = raw.substring(1);
        }
        while (raw.endsWith("/")) {
            raw = raw.substring(0, raw.length() - 1);
        }
        return raw;
    }
}
