# YOLOv8 Tooth Detection Training Guide

## 🎯 Overview

This guide shows you how to train a YOLOv8 model to detect teeth in your 79 patient dental X-ray dataset.

## 📋 Quick Steps

### 1. Install Dependencies

```bash
cd dentescope-ai-complete
pip3 install -r training-requirements.txt
```

###  2. Your Dataset is Ready!

You already have 79 patient images in `data/samples/`:
```bash
ls data/samples/*.jpg data/samples/*.tif
```

### 3. ⚠️ ANNOTATE IMAGES (CRITICAL STEP)

Before training, you MUST label each tooth in every image.

**Recommended: Use Roboflow (Easiest & Fastest)**

1. **Go to** [roboflow.com](https://roboflow.com)
2. **Create free account**
3. **Create new project** → Object Detection
4. **Upload** all 79 images from `data/samples/`
5. **Annotate** each image:
   - Click on image
   - Press 'B' or click box tool  
   - Draw rectangle around each tooth
   - Label as: **"tooth"**
   - Save and move to next
6. **Generate dataset**:
   - Click "Generate" → "New Version"
   - Resize: 640x640
   - Add augmentation (optional)
7. **Export**:
   - Format: **YOLOv8**
   - Download ZIP file

**Time needed:** 2-6 hours for 79 images

### 4. Prepare Dataset Structure

After annotation, organize like this:

```
data/
└── prepared/
    ├── data.yaml
    ├── train/
    │   ├── images/
    │   └── labels/
    ├── val/
    │   ├── images/
    │   └── labels/
    └── test/
        ├── images/
        └── labels/
```

**Split by patient** (recommended):
- Train: 55 patients (70%)
- Val: 16 patients (20%)
- Test: 8 patients (10%)

### 5. Train the Model

**Basic training:**
```bash
python3 train_tooth_model.py \
  --dataset ./data/prepared \
  --epochs 100 \
  --model-size n
```

**Recommended training (better accuracy):**
```bash
python3 train_tooth_model.py \
  --dataset ./data/prepared \
  --model-size m \
  --epochs 200 \
  --batch-size 16 \
  --device 0 \
  --validate
```

### 6. Monitor Training

```bash
# View training progress
tensorboard --logdir runs/train

# Open browser: http://localhost:6006
```

Training results saved to:
- `runs/train/tooth_detection/weights/best.pt` - Best model
- `runs/train/tooth_detection/results.png` - Training curves

### 7. Test the Model

```bash
python3 train_tooth_model.py \
  --dataset ./data/prepared \
  --test-image ./data/samples/AARUSH*.jpg
```

### 8. Use the Trained Model

```python
from ultralytics import YOLO

# Load trained model
model = YOLO('runs/train/tooth_detection/weights/best.pt')

# Run inference on new image
results = model.predict('new_dental_xray.jpg', save=True)

# Results saved to runs/predict/
```

## 🎓 Model Sizes

- **nano (n)**: Fastest, 3.2M params - good for testing
- **small (s)**: Balanced, 11.2M params - good start
- **medium (m)**: Better accuracy, 25.9M params - **RECOMMENDED**
- **large (l)**: High accuracy, 43.7M params - if you have GPU
- **xlarge (x)**: Best accuracy, 68.2M params - research/production

## ⏱️ Training Time Estimates

| Model | GPU | Epochs | Time |
|-------|-----|--------|------|
| nano | GTX 1060 | 100 | 2-3 hrs |
| small | GTX 1060 | 100 | 3-4 hrs |
| medium | RTX 3080 | 200 | 6-8 hrs |
| large | A100 | 300 | 8-10 hrs |

## 📊 Expected Results

With good annotations:
- **mAP@0.5**: 0.85-0.95
- **Precision**: 0.88-0.95
- **Recall**: 0.82-0.92

## 🔧 Troubleshooting

### Out of Memory
```bash
python3 train_tooth_model.py --dataset ./data/prepared --batch-size 8 --model-size n
```

### Slow Training
```bash
# Use smaller images
python3 train_tooth_model.py --dataset ./data/prepared --imgsz 416
```

### Poor Accuracy
1. Check annotation quality
2. Train longer (200-300 epochs)
3. Use larger model (medium or large)
4. Ensure patient-based splitting (no data leakage)

## 📚 Annotation Tools Comparison

| Tool | Difficulty | Speed | Cost | Recommendation |
|------|-----------|-------|------|----------------|
| **Roboflow** | Easy | Fast | Free tier | ⭐ Best for beginners |
| **LabelImg** | Medium | Medium | Free | Good for local work |
| **CVAT** | Hard | Fast | Free | Advanced users |

## 💡 Pro Tips

1. **Start with Roboflow** - fastest and easiest
2. **Annotate in batches** - 20 images at a time
3. **Be consistent** - use same labeling approach
4. **Patient-based split** - prevents data leakage
5. **Monitor validation** - catch overfitting early
6. **Use medium model** - best balance for 79 images

## 📞 Need Help?

1. Check training logs in `runs/train/`
2. Open issue on GitHub
3. Check [Ultralytics YOLOv8 docs](https://docs.ultralytics.com)

## 🚀 Next Steps After Training

1. **Integrate with backend** - Use model in FastAPI app
2. **Add tooth width measurement** - Post-processing
3. **Deploy model** - Export to ONNX or TensorFlow
4. **Create web interface** - Frontend for image upload

---

**Remember**: Good annotations = Good model! Spend time on quality labeling. 🦷
