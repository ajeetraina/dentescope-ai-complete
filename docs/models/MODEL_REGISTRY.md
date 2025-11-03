# DenteScope AI - Model Registry

## 📋 Overview
This document catalogs all trained models in the DenteScope AI project.

---

## 🏆 Production Models

### tooth_detection3 (October 31, 2025) ⭐ CURRENT PRODUCTION

**Location:** `runs/train/tooth_detection3/weights/best.pt`

**Performance:**
- mAP50: 99.5%
- mAP50-95: 68.2%
- Precision: 99.6%
- Recall: 100%
- Inference Speed: 173ms (CPU)

**Specifications:**
- Architecture: YOLOv8n (nano)
- Parameters: 3,005,843
- Model Size: 6.2 MB
- Training Device: CPU (Jetson Thor)
- Training Time: 33 minutes (50 epochs)

**Training Data:**
- Train: 60 images
- Validation: 13 images
- Annotation: Auto-annotation + review

**Use Cases:**
- ✅ Tooth detection in panoramic X-rays
- ✅ Width measurement analysis
- ✅ Batch processing
- ✅ Edge deployment
- ✅ Production inference

**Download:**
```bash
# Model is included in repository
model_path = "runs/train/tooth_detection3/weights/best.pt"
```

**Status:** ✅ Production Ready | Validated October 31, 2025

---

## 📚 Development Models

### tooth_detection5 (Earlier Version)

**Location:** `runs/train/tooth_detection5/weights/best.pt`

**Performance:**
- mAP50: 49.9%
- Precision: 53.6%
- Recall: 53.8%

**Notes:**
- V1 baseline model
- Trained with auto-annotations
- Used for re-annotation pipeline
- **Status:** ⚠️ Deprecated - Use tooth_detection3

---

### tooth_detection7 (Blog Post Model?)

**Location:** `runs/train/tooth_detection7/weights/best.pt`

**Performance:**
- mAP50: 99.5%
- Model Size: 22.5 MB
- Architecture: YOLOv8s (small)

**Notes:**
- Mentioned in blog post
- Larger model (4× parameters vs detection3)
- **Status:** ❓ Needs clarification vs detection3

---

## 🔬 Model Comparison

| Model | mAP50 | Size | Speed | Device | Use Case |
|-------|-------|------|-------|--------|----------|
| **detection3** ⭐ | **99.5%** | **6.2 MB** | **173ms** | CPU | **Production** |
| detection5 | 49.9% | 6.2 MB | 173ms | CPU | Deprecated |
| detection7 | 99.5% | 22.5 MB | 571ms | CPU | ? |

---

## 📖 Model Selection Guide

### For Production Deployment
→ Use **tooth_detection3**
- Best balance of accuracy and speed
- Smallest size (6.2 MB)
- Runs on any hardware

### For Maximum Accuracy
→ Use **tooth_detection3** or **tooth_detection7**
- Both achieve 99.5% mAP50
- detection3 is faster and smaller

### For Edge Devices
→ Use **tooth_detection3**
- Optimized for low-resource devices
- Fast inference on CPU
- Small model size

### For Development
→ Use **tooth_detection3**
- Current production standard
- Well-documented
- Validated results

---

## 🚀 Loading Models

### Python
```python
from ultralytics import YOLO

# Load production model
model = YOLO('runs/train/tooth_detection3/weights/best.pt')

# Run inference
results = model('dental_xray.jpg', conf=0.25)
```

### Command Line
```bash
# Single image
yolo predict model=runs/train/tooth_detection3/weights/best.pt \
  source=image.jpg \
  conf=0.25

# Batch processing
yolo predict model=runs/train/tooth_detection3/weights/best.pt \
  source=images/ \
  conf=0.25
```

---

## 📊 Training History

### October 2025
- **October 31**: tooth_detection3 trained (99.5% mAP50)
- **Status**: Production deployment ready

### Earlier (Blog Post)
- detection5: V1 baseline (49.9% mAP50)
- detection7: V2 production (99.5% mAP50)

---

## 🔄 Model Versioning

**Current Production:** v3.0 (tooth_detection3)
**Previous:** v1.0 (detection5), v2.0 (detection7?)
**Next:** v4.0 (pathology detection planned)

---

## 📝 Adding New Models

When training a new model:

1. Document in this registry
2. Include performance metrics
3. Compare with existing models
4. Update production status if applicable
5. Archive old models

---

## 📞 Questions

**Which model should I use?**
→ tooth_detection3 for all current use cases

**Where is tooth_detection7?**
→ Mentioned in blog - need to clarify location

**Can I train my own?**
→ Yes! Use `train_tooth_model.py`

---

**Last Updated:** November 3, 2025

**Maintainer:** Ajeet Singh Raina (@ajeetraina)
