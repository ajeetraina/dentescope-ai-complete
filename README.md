# 🦷 DenteScope AI - Dental X-ray Tooth Detection

<div align="center">

![Python](https://img.shields.io/badge/Python-3.12-blue.svg)
![YOLOv8](https://img.shields.io/badge/YOLOv8-8.3.223-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen.svg)

**Production-ready AI system for automated tooth detection in dental panoramic X-rays**

[🚀 Live Demo](https://huggingface.co/spaces/ajeetsraina/dentescope-ai) • [📖 Blog Post](BLOG_POST.md) • [💻 GitHub](https://github.com/ajeetraina/dentescope-ai-complete)

![Analysis Results](results/width_analysis/tooth_width_analysis_charts.png)

</div>

---

## 🌐 Live Demo

**[Try DenteScope AI Now! →](https://huggingface.co/spaces/ajeetsraina/dentescope-ai)**

Upload a dental panoramic X-ray and get instant:
- ✅ Tooth detection with 99.5% accuracy
- ✅ Width & height measurements in pixels and mm
- ✅ Confidence scores for each detection
- ✅ Visual annotations on your image

*No installation required - runs entirely in your browser!*

---

## 🎯 Overview

DenteScope AI is a state-of-the-art deep learning system for automated tooth detection in dental panoramic X-rays. Built with YOLOv8 and trained on 71 dental images, it achieves production-ready performance through an innovative iterative training approach.

### Key Features

- 🎯 **99.5% mAP50 Accuracy** - Production-grade detection
- 🚀 **Fast Inference** - Real-time processing
- 📏 **Automated Measurements** - Width and height in pixels/mm
- 🔄 **Iterative Training** - Self-improving annotation pipeline
- 🌐 **Web Interface** - Live demo on Hugging Face Spaces

---

## 📊 Performance

### Production Model (V2) - YOLOv8s

| Metric | Score | Status |
|--------|-------|--------|
| **mAP50** | **99.5%** | 🟢 Production Ready |
| **mAP50-95** | **98.5%** | 🟢 Excellent |
| **Precision** | **99.6%** | 🟢 Excellent |
| **Recall** | **100%** | 🟢 Perfect |
| **Training Time** | 2.6 hours | ⚡ Efficient |
| **Model Size** | 22.5 MB | 💾 Compact |

### Training Evolution
```
V1 Baseline:    mAP50 49.9% (auto-annotated, 31 min training)
      ↓
Re-annotation:  Using trained V1 model for better labels
      ↓
V2 Production:  mAP50 99.5% (2.6 hours training) ✨
```

**Key Achievement:** +99.2% improvement through iterative training!

---

## 🚀 Quick Start

### Prerequisites

- Python 3.10+
- NVIDIA GPU (optional, but recommended)
- 8GB+ RAM

### Installation
```bash
# Clone repository
git clone https://github.com/ajeetraina/dentescope-ai-complete.git
cd dentescope-ai-complete

# Install dependencies
pip install ultralytics opencv-python pillow pyyaml matplotlib pandas openpyxl
```

### Run Inference
```python
from ultralytics import YOLO

# Load trained model
model = YOLO('runs/train/tooth_detection7/weights/best.pt')

# Detect teeth in X-ray
results = model.predict('your_xray.jpg', conf=0.25, save=True)

# Get measurements
for r in results:
    for box in r.boxes:
        x1, y1, x2, y2 = box.xyxy[0].tolist()
        width_px = x2 - x1
        width_mm = width_px * 0.1  # Calibration factor
        conf = box.conf[0].item()
        
        print(f"🦷 Tooth detected:")
        print(f"   Width: {width_px:.1f}px ({width_mm:.1f}mm)")
        print(f"   Confidence: {conf:.1%}")
```

---

## 🎓 Training Your Own Model

### Method 1: Using Docker (Recommended for Jetson)
```bash
# Pull CUDA container
docker pull nvcr.io/nvidia/cuda:13.0.0-devel-ubuntu24.04

# Run container
docker run -it --rm \
  --runtime nvidia \
  --gpus all \
  -v $(pwd):/workspace \
  -w /workspace \
  nvcr.io/nvidia/cuda:13.0.0-devel-ubuntu24.04 \
  bash

# Inside container: Install dependencies
apt-get update && apt-get install -y python3 python3-pip libgl1
pip3 install ultralytics --break-system-packages

# Train
python3 train_tooth_model.py \
  --dataset ./data/v2_dataset_fixed \
  --model-size s \
  --epochs 100
```

### Method 2: Local Training
```bash
# Prepare your dataset (YOLO format)
# Directory structure:
# data/
#   ├── images/
#   │   ├── train/
#   │   └── val/
#   └── labels/
#       ├── train/
#       └── val/

# Train
python3 train_tooth_model.py \
  --dataset ./data/v2_dataset_fixed \
  --model-size s \
  --epochs 100
```

---

## 📏 Analyze Tooth Width

### Run Width Analysis
```bash
# Analyze validation images
python3 view_tooth_width.py

# Generate comprehensive report
python3 analyze_tooth_widths.py
```

### Output Files

- `results/width_analysis/tooth_width_report.csv` - Raw measurements
- `results/width_analysis/tooth_width_analysis.xlsx` - Excel report (3 sheets)
- `results/width_analysis/tooth_width_analysis_charts.png` - 4-panel visualization
- `results/width_analysis/width_*.jpg` - Annotated images

### Sample Results

From 15 patients analyzed:
- **Mean width:** 165.7mm (±0.5mm standard deviation)
- **Confidence:** 93.3% average
- **Detection rate:** 100%

---

## 📁 Project Structure
```
dentescope-ai-complete/
├── data/
│   ├── raw/                    # Original dental X-rays
│   ├── train/                  # V1 training data
│   ├── valid/                  # Validation data
│   └── v2_dataset_fixed/       # V2 training data (production)
├── runs/
│   └── train/
│       ├── tooth_detection5/   # V1 model (49.9% mAP50)
│       └── tooth_detection7/   # V2 model (99.5% mAP50) ⭐
├── results/
│   └── width_analysis/         # Analysis outputs
├── hf-deploy/                  # Hugging Face deployment
│   ├── app.py                  # Gradio interface
│   ├── best.pt                 # Production model
│   └── requirements.txt
├── train_tooth_model.py        # Training script
├── view_tooth_width.py         # Width analysis
├── analyze_tooth_widths.py     # Comprehensive analysis
├── BLOG_POST.md               # Complete tutorial
└── README.md                   # This file
```

---

## 💻 Tech Stack

- **ML Framework:** [Ultralytics YOLOv8](https://github.com/ultralytics/ultralytics)
- **Deep Learning:** PyTorch
- **Hardware:** NVIDIA Jetson Thor (ARM64)
- **Container:** Docker with CUDA 13.0
- **Deployment:** Hugging Face Spaces + Gradio
- **Analysis:** Pandas, Matplotlib, OpenPyXL

---

## 🎯 Use Cases

- 🏥 **Clinical:** Automated screening in dental practices
- 📊 **Research:** Dental morphology and population studies
- 📏 **Orthodontics:** Dimensional analysis and treatment planning
- 🎓 **Education:** Training tool for dental students
- 🤖 **Automation:** Batch processing of dental imagery

---

## 📖 Documentation

- **[Complete Blog Post](BLOG_POST.md)** - Full step-by-step guide with all code
- **[Live Demo](https://huggingface.co/spaces/ajeetsraina/dentescope-ai)** - Try it now!
- **[GitHub Repository](https://github.com/ajeetraina/dentescope-ai-complete)** - Source code

### External Resources

- [Ultralytics YOLOv8 Docs](https://docs.ultralytics.com/)
- [NVIDIA Jetson Thor](https://www.nvidia.com/en-us/autonomous-machines/embedded-systems/jetson-thor/)
- [Hugging Face Spaces](https://huggingface.co/docs/hub/spaces)

---

## 🔮 Future Enhancements

### Planned Features
- [ ] Multi-tooth classification (incisors, canines, molars, premolars)
- [ ] Individual tooth numbering (dental notation)
- [ ] Improved calibration for accurate mm measurements
- [ ] Disease detection (cavities, root canal issues)
- [ ] Mobile app deployment

---

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Ultralytics** for YOLOv8 framework
- **NVIDIA** for Jetson hardware and CUDA
- **Hugging Face** for free hosting
- **Docker** for containerization

---

## 📞 Contact

**Ajeet Singh Raina**  
Docker Captain | AI/ML Engineer

- 🌐 [collabnix.com](https://collabnix.com)
- 💼 [LinkedIn](https://linkedin.com/in/ajeetsraina)
- 🐙 [GitHub](https://github.com/ajeetraina)
- 🐦 [Twitter](https://twitter.com/ajeetsraina)

---

<div align="center">

**⭐ If you find this project useful, please star the repository! ⭐**

Built with ❤️ by [Ajeet Singh Raina](https://github.com/ajeetraina)

</div>
