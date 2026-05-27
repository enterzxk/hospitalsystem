# MedSAM 医学图像分割服务

基于 MedSAM 模型的医学图像分割 REST API 服务，支持点 prompt、框 prompt、文本 prompt 的分割功能。

## 功能特性

- **点 prompt 分割**：通过标注点进行分割
- **框 prompt 分割**：通过矩形框进行分割
- **文本 prompt 分割**：通过文本描述进行分割
- **自动分割**：无需 prompt，自动检测感兴趣区域

## 环境要求

- Python 3.9+
- CUDA（可选，用于 GPU 加速）
- Docker（可选，用于容器化部署）

## 安装

### 本地安装

```bash
# 克隆项目
git clone <repository-url>
cd medsam-service

# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Linux/Mac
# 或
venv\Scripts\activate  # Windows

# 安装依赖
pip install -r requirements.txt
```

### Docker 安装

```bash
# 构建镜像
docker build -t medsam-service .

# 运行容器
docker run -p 5000:5000 medsam-service
```

## 启动服务

### 本地启动

```bash
python app.py
```

服务将在 `http://localhost:5000` 启动。

### Docker 启动

```bash
docker run -p 5000:5000 medsam-service
```

## API 文档

### 健康检查

```
GET /health
```

响应：
```json
{
  "status": "healthy",
  "model_loaded": true,
  "device": "cuda"
}
```

### 点 prompt 分割

```
POST /api/segment/point
```

请求：
```json
{
  "image": "base64编码的图像",
  "points": [[100, 100], [150, 150]],
  "labels": [1, 0],
  "imaging_id": 123
}
```

响应：
```json
{
  "success": true,
  "mask": "data:image/png;base64,...",
  "result_image": "data:image/png;base64,...",
  "area": 5000,
  "confidence": 0.95
}
```

### 框 prompt 分割

```
POST /api/segment/box
```

请求：
```json
{
  "image": "base64编码的图像",
  "box": [100, 100, 200, 200],
  "imaging_id": 123
}
```

### 文本 prompt 分割

```
POST /api/segment/text
```

请求：
```json
{
  "image": "base64编码的图像",
  "text": "肿瘤",
  "imaging_id": 123
}
```

### 自动分割

```
POST /api/segment/auto
```

请求：
```json
{
  "image": "base64编码的图像",
  "imaging_id": 123
}
```

## 配置

### 环境变量

- `FLASK_ENV`：运行环境（development/production）
- `PORT`：服务端口（默认 5000）
- `MODEL_PATH`：模型文件路径

### 模型下载

1. 访问 [MedSAM GitHub](https://github.com/bowang-lab/MedSAM)
2. 下载预训练模型权重
3. 放置到 `models/` 目录

## 使用示例

### Python 客户端

```python
import requests
import base64
from PIL import Image
import io

# 读取图像
with open("ct_image.png", "rb") as f:
    image_base64 = base64.b64encode(f.read()).decode()

# 调用API
response = requests.post(
    "http://localhost:5000/api/segment/point",
    json={
        "image": f"data:image/png;base64,{image_base64}",
        "points": [[100, 100]],
        "labels": [1]
    }
)

result = response.json()
print(f"分割面积: {result['area']}")
```

### JavaScript 客户端

```javascript
// 读取图像
const fileInput = document.querySelector('input[type="file"]');
const file = fileInput.files[0];
const reader = new FileReader();

reader.onload = async (e) => {
  const imageBase64 = e.target.result;

  // 调用API
  const response = await fetch('http://localhost:5000/api/segment/point', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      image: imageBase64,
      points: [[100, 100]],
      labels: [1]
    })
  });

  const result = await response.json();
  console.log('分割面积:', result.area);
};

reader.readAsDataURL(file);
```

## 性能优化

1. **GPU 加速**：安装 CUDA 版本的 PyTorch
2. **模型量化**：使用 INT8 量化减少内存占用
3. **批量处理**：支持批量图像分割
4. **缓存**：缓存常用分割结果

## 常见问题

### Q: 模型加载失败？

A: 检查模型文件是否存在，以及 CUDA 环境是否正确配置。

### Q: 分割效果不理想？

A: 尝试调整标注点/框的位置，或使用更精确的文本描述。

### Q: 内存不足？

A: 减小输入图像尺寸，或使用 GPU 加速。

## 许可证

本项目基于 Apache 2.0 许可证开源。

## 联系方式

- 作者：YuJian95
- 邮箱：clj9509@163.com
