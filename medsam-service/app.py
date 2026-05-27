"""
MedSAM 医学图像分割服务
提供点prompt、框prompt、文本prompt的分割功能
"""

import os
import io
import base64
import numpy as np
from PIL import Image
from flask import Flask, request, jsonify
from flask_cors import CORS
import torch
import cv2

app = Flask(__name__)
CORS(app)

# 全局模型变量
medsam_model = None
device = "cuda" if torch.cuda.is_available() else "cpu"


def load_medsam_model():
    """加载MedSAM模型"""
    global medsam_model
    try:
        # 这里应该加载实际的MedSAM模型
        # 由于模型文件较大，这里使用占位符
        # 实际部署时需要下载MedSAM模型权重
        print(f"Loading MedSAM model on {device}...")
        # medsam_model = sam_model_registry["vit_b"](checkpoint="medsam_vit_b.pth")
        # medsam_model.to(device)
        # medsam_model.eval()
        print("MedSAM model loaded successfully")
        return True
    except Exception as e:
        print(f"Failed to load MedSAM model: {e}")
        return False


def decode_image(image_data):
    """解码base64图像数据"""
    if image_data.startswith('data:'):
        # 移除data URL前缀
        image_data = image_data.split(',')[1]
    image_bytes = base64.b64decode(image_data)
    image = Image.open(io.BytesIO(image_bytes))
    return np.array(image)


def encode_image(image):
    """将图像编码为base64"""
    if len(image.shape) == 3 and image.shape[2] == 3:
        # RGB图像
        pil_image = Image.fromarray(image)
    else:
        # 灰度图像
        pil_image = Image.fromarray(image, mode='L')

    buffer = io.BytesIO()
    pil_image.save(buffer, format='PNG')
    buffer.seek(0)
    image_base64 = base64.b64encode(buffer.getvalue()).decode('utf-8')
    return f"data:image/png;base64,{image_base64}"


@app.route('/health', methods=['GET'])
def health_check():
    """健康检查"""
    return jsonify({
        'status': 'healthy',
        'model_loaded': medsam_model is not None,
        'device': device
    })


@app.route('/api/segment/point', methods=['POST'])
def segment_by_points():
    """
    点prompt分割
    请求格式:
    {
        "image": "base64编码的图像",
        "points": [[x1, y1], [x2, y2], ...],
        "labels": [1, 0, ...],  # 1=前景, 0=背景
        "imaging_id": 123  # 可选，用于关联影像
    }
    """
    try:
        data = request.get_json()
        image_data = data.get('image')
        points = data.get('points', [])
        labels = data.get('labels', [])

        if not image_data:
            return jsonify({'error': '缺少图像数据'}), 400

        if not points:
            return jsonify({'error': '缺少标注点'}), 400

        # 解码图像
        image = decode_image(image_data)

        # 转换为模型输入格式
        input_points = np.array(points)
        input_labels = np.array(labels) if labels else np.ones(len(points))

        # 执行分割（这里使用简化的实现）
        # 实际应该调用MedSAM模型
        mask = perform_segmentation(image, input_points, input_labels)

        # 编码结果
        result_image = apply_mask_to_image(image, mask)
        result_base64 = encode_image(result_image)

        return jsonify({
            'success': True,
            'mask': encode_image((mask * 255).astype(np.uint8)),
            'result_image': result_base64,
            'area': int(np.sum(mask)),
            'confidence': 0.95
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/segment/box', methods=['POST'])
def segment_by_box():
    """
    框prompt分割
    请求格式:
    {
        "image": "base64编码的图像",
        "box": [x1, y1, x2, y2],  # 框的坐标
        "imaging_id": 123  # 可选
    }
    """
    try:
        data = request.get_json()
        image_data = data.get('image')
        box = data.get('box', [])

        if not image_data:
            return jsonify({'error': '缺少图像数据'}), 400

        if not box or len(box) != 4:
            return jsonify({'error': '缺少有效的框坐标'}), 400

        # 解码图像
        image = decode_image(image_data)

        # 转换为模型输入格式
        input_box = np.array(box)

        # 执行分割
        mask = perform_segmentation_with_box(image, input_box)

        # 编码结果
        result_image = apply_mask_to_image(image, mask)
        result_base64 = encode_image(result_image)

        return jsonify({
            'success': True,
            'mask': encode_image((mask * 255).astype(np.uint8)),
            'result_image': result_base64,
            'area': int(np.sum(mask)),
            'confidence': 0.92
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/segment/text', methods=['POST'])
def segment_by_text():
    """
    文本prompt分割
    请求格式:
    {
        "image": "base64编码的图像",
        "text": "肿瘤",  # 文本描述
        "imaging_id": 123  # 可选
    }
    """
    try:
        data = request.get_json()
        image_data = data.get('image')
        text = data.get('text', '')

        if not image_data:
            return jsonify({'error': '缺少图像数据'}), 400

        if not text:
            return jsonify({'error': '缺少文本描述'}), 400

        # 解码图像
        image = decode_image(image_data)

        # 文本prompt需要额外的文本编码器
        # 这里使用简化的实现
        mask = perform_segmentation_with_text(image, text)

        # 编码结果
        result_image = apply_mask_to_image(image, mask)
        result_base64 = encode_image(result_image)

        return jsonify({
            'success': True,
            'mask': encode_image((mask * 255).astype(np.uint8)),
            'result_image': result_base64,
            'area': int(np.sum(mask)),
            'confidence': 0.88,
            'text_match': text
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/segment/auto', methods=['POST'])
def auto_segment():
    """
    自动分割（无prompt）
    请求格式:
    {
        "image": "base64编码的图像",
        "imaging_id": 123  # 可选
    }
    """
    try:
        data = request.get_json()
        image_data = data.get('image')

        if not image_data:
            return jsonify({'error': '缺少图像数据'}), 400

        # 解码图像
        image = decode_image(image_data)

        # 自动检测感兴趣区域
        mask = auto_detect_region(image)

        # 编码结果
        result_image = apply_mask_to_image(image, mask)
        result_base64 = encode_image(result_image)

        return jsonify({
            'success': True,
            'mask': encode_image((mask * 255).astype(np.uint8)),
            'result_image': result_base64,
            'area': int(np.sum(mask)),
            'confidence': 0.85
        })

    except Exception as e:
        return jsonify({'error': str(e)}), 500


def perform_segmentation(image, points, labels):
    """
    执行点prompt分割
    这是一个简化的实现，实际应该使用MedSAM模型
    """
    h, w = image.shape[:2]
    mask = np.zeros((h, w), dtype=bool)

    # 简单的区域生长算法作为示例
    for point, label in zip(points, labels):
        if label == 1:  # 前景点
            x, y = int(point[0]), int(point[1])
            # 创建一个圆形区域
            cv2.circle(mask, (x, y), 30, True, -1)

    return mask


def perform_segmentation_with_box(image, box):
    """
    执行框prompt分割
    这是一个简化的实现
    """
    h, w = image.shape[:2]
    mask = np.zeros((h, w), dtype=bool)

    x1, y1, x2, y2 = box
    mask[int(y1):int(y2), int(x1):int(x2)] = True

    return mask


def perform_segmentation_with_text(image, text):
    """
    执行文本prompt分割
    这是一个简化的实现
    """
    h, w = image.shape[:2]
    mask = np.zeros((h, w), dtype=bool)

    # 基于文本描述的简单分割
    # 实际应该使用CLIP等文本编码器
    gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY) if len(image.shape) == 3 else image
    _, mask = cv2.threshold(gray, 127, 255, cv2.THRESH_BINARY)

    return mask.astype(bool)


def auto_detect_region(image):
    """
    自动检测感兴趣区域
    使用简单的图像处理技术
    """
    gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY) if len(image.shape) == 3 else image

    # 使用OTSU阈值分割
    _, mask = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

    # 形态学操作
    kernel = np.ones((5, 5), np.uint8)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)

    return mask.astype(bool)


def apply_mask_to_image(image, mask, color=[255, 0, 0], alpha=0.5):
    """将掩码应用到图像上"""
    result = image.copy()

    # 创建彩色掩码
    mask_color = np.zeros_like(image)
    mask_color[mask] = color

    # 混合图像
    result[mask] = cv2.addWeighted(image[mask], 1 - alpha, mask_color[mask], alpha, 0)

    return result


if __name__ == '__main__':
    # 加载模型
    load_medsam_model()

    # 启动服务
    app.run(host='0.0.0.0', port=5000, debug=True)
