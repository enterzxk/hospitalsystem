FROM python:3.9-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 安装 demo worker 运行依赖；真实 MedSAM 权重/torch 可按 requirements.txt 在专用推理环境中扩展。
RUN pip install --no-cache-dir \
    flask==2.3.3 \
    flask-cors==4.0.0 \
    numpy==1.24.3 \
    Pillow==10.1.0 \
    requests==2.31.0 \
    gunicorn==21.2.0

# 复制应用代码
COPY . .

# 暴露端口
EXPOSE 5000

# 启动命令
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]
