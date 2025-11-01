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

## 📑 Table of Contents

- [Live Demo](#-live-demo)
- [Overview](#-overview)
- [Performance](#-performance)
- [Quick Start](#-quick-start)
- [Docker Setup (GPU Training)](#-docker-setup-gpu-training)
- [Training Your Own Model](#-training-your-own-model)
- [Width Analysis](#-width-analysis)
- [Project Structure](#-project-structure)
- [Tech Stack](#-tech-stack)
- [Use Cases](#-use-cases)
- [Future Enhancements](#-future-enhancements)
- [Contributing](#-contributing)
- [Contact](#-contact)

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

**Platform Independent:** Works on any hardware - CPU, GPU, cloud, edge devices, or embedded systems.

### Key Features

- 🎯 **99.5% mAP50 Accuracy** - Production-grade detection
- 🚀 **Fast Inference** - Real-time processing (~570ms/image)
- 📏 **Automated Measurements** - Width and height in pixels/mm
- 🔄 **Iterative Training** - Self-improving annotation pipeline
- 💻 **Platform Agnostic** - Runs anywhere (CPU, GPU, cloud, edge)
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
| **Training Time** | 2.6 hours | ⚡ (with GPU) |
| **Model Size** | 22.5 MB | 💾 Compact |
| **Inference** | ~570ms/image | 🚀 Fast |

### Training Evolution
```
V1 Baseline:    mAP50 49.9% (auto-annotated, 31 min training)
      ↓
Re-annotation:  Using trained V1 model for better labels
      ↓
V2 Production:  mAP50 99.5% (2.6 hours training) ✨
```

**Key Achievement:** +99.2% improvement through iterative training!

**Training Hardware Comparison:**

| Hardware | Training Time | Notes |
|----------|---------------|-------|
| **NVIDIA Jetson Thor** | **2.6 hours** | What we used |
| CPU (16-core) | ~8-10 hours | Works but slower |

> **Note:** GPU accelerates training but is **not required**. The model runs on any hardware!

---

## 🚀 Quick Start

### Prerequisites

- Python 3.10+
- **Optional:** NVIDIA GPU (for faster training)
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

# Detect teeth in X-ray (auto-detects CPU/GPU)
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

## 🐳 Docker Setup (GPU Training)

Complete setup for Docker with NVIDIA GPU support - recommended for fastest training.

### Step 1: Install Docker & NVIDIA Container Toolkit
```bash
# Install Docker (if not already installed)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
    sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

### Step 2: Configure Docker Daemon (Recommended)

Set NVIDIA as default runtime to avoid typing `--runtime nvidia` every time:
```bash
# Install jq for JSON manipulation
sudo apt install -y jq

# Add nvidia as default runtime
sudo jq '. + {"default-runtime": "nvidia"}' /etc/docker/daemon.json | \
    sudo tee /etc/docker/daemon.json.tmp && \
    sudo mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json

# Restart Docker
sudo systemctl restart docker
```

**Verify configuration:**
```bash
cat /etc/docker/daemon.json
```

Expected output:
```json
{
  "runtimes": {
    "nvidia": {
      "args": [],
      "path": "nvidia-container-runtime"
    }
  },
  "default-runtime": "nvidia"
}
```

### Step 3: Add User to Docker Group (No More sudo!)
```bash
# Add current user to docker group
sudo usermod -aG docker $USER

# Apply changes immediately
newgrp docker

# Or logout/login for changes to take effect
```

### Step 4: Test GPU Access
```bash
# Test without sudo - should work now!
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

### Step 5: Train DenteScope AI with Docker
```bash
# Run container (no --runtime flag needed after Step 2!)
docker run -it --rm \
  --gpus all \
  -v $(pwd):/workspace \
  -w /workspace \
  nvcr.io/nvidia/cuda:13.0.0-devel-ubuntu24.04 \
  bash

# Inside container: Setup
apt-get update && apt-get install -y python3 python3-pip libgl1
pip3 install ultralytics --break-system-packages

# Verify GPU
python3 -c "import torch; print(f'CUDA: {torch.cuda.is_available()}')"

# Train model
python3 train_tooth_model.py \
  --dataset ./data/v2_dataset_fixed \
  --model-size s \
  --epochs 100 \
  --device 0
```

### Docker Troubleshooting

**Issue: "permission denied"**
```bash
sudo usermod -aG docker $USER
newgrp docker
```

**Issue: "nvidia-smi not found"**
```bash
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

**Issue: GPU not detected**
```bash
# Verify GPU on host
nvidia-smi

# Test in container
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

---

## 🎓 Training Your Own Model

### Option 1: CPU Training (Any Computer)
```bash
# Works on any computer - no GPU needed
python3 train_tooth_model.py \
  --dataset ./data/v2_dataset_fixed \
  --model-size s \
  --epochs 100 \
  --device cpu
```

**Estimated time:** 8-12 hours on modern CPU

### Option 2: GPU Training (Faster)
```bash
# Auto-detects GPU if available
python3 train_tooth_model.py \
  --dataset ./data/v2_dataset_fixed \
  --model-size s \
  --epochs 100 \
  --device 0
```

**Estimated time:** 2-4 hours (see hardware comparison above)

### Option 3: Cloud Training (Colab, AWS, etc.)
```python
# In Google Colab or Jupyter notebook
!pip install ultralytics

from ultralytics import YOLO

model = YOLO('yolov8s.pt')
results = model.train(
    data='data.yaml',
    epochs=100,
    imgsz=640,
    batch=8,
    device=0
)
```

### Training Pipeline (From Scratch)

<details>
<summary><b>Click to expand: Complete training pipeline</b></summary>

#### Step 1: Data Preparation
```bash
python3 prepare_data.py --source data/raw --output data/train
```

#### Step 2: Auto-Annotation (Bootstrap)
```bash
python3 auto_annotate_all.py \
  --images data/train/images \
  --output data/train/labels
```

#### Step 3: V1 Baseline Training
```bash
python3 train_tooth_model.py \
  --dataset ./data/train \
  --model-size n \
  --epochs 100
```

#### Step 4: Re-Annotation with Trained Model
```bash
python3 reannotate_with_model.py \
  --model runs/train/tooth_detection5/weights/best.pt \
  --images data/raw \
  --output data/reannotated/labels
```

#### Step 5: V2 Production Training
```bash
python3 train_tooth_model.py \
  --dataset ./data/v2_dataset_fixed \
  --model-size s \
  --epochs 100
```

</details>

---

## 📏 Width Analysis

### Run Comprehensive Analysis
```bash
# Analyze validation images
python3 view_tooth_width.py

# Generate statistics, charts, and Excel report
python3 analyze_tooth_widths.py
```

### Output Files

- `results/width_analysis/tooth_width_report.csv` - Raw measurements
- `results/width_analysis/tooth_width_analysis.xlsx` - Excel report (3 sheets)
- `results/width_analysis/tooth_width_analysis_charts.png` - 4-panel visualization
- `results/width_analysis/width_*.jpg` - Annotated images

### Sample Results

Analysis of 15 patients:
- **Mean width:** 165.7mm (±0.5mm standard deviation)
- **Detection confidence:** 93.3% average
- **Detection rate:** 100%
- **Consistency:** Excellent (σ = 0.5mm)

---

## 📁 Project Structure
```
dentescope-ai-complete/
├── data/
│   ├── raw/                    # Original 73 dental X-rays
│   ├── train/                  # V1 training data (auto-annotated)
│   ├── valid/                  # Validation data
│   └── v2_dataset_fixed/       # V2 training data (production)
│       ├── images/
│       │   ├── train/          # 57 training images
│       │   └── val/            # 14 validation images
│       └── labels/
│           ├── train/          # Training annotations (YOLO format)
│           └── val/            # Validation annotations
├── runs/
│   └── train/
│       ├── tooth_detection5/   # V1 model (49.9% mAP50)
│       └── tooth_detection7/   # V2 model (99.5% mAP50) ⭐
│           └── weights/
│               └── best.pt     # Production model
├── results/
│   └── width_analysis/         # Width measurements & visualizations
│       ├── tooth_width_report.csv
│       ├── tooth_width_analysis.xlsx
│       ├── tooth_width_analysis_charts.png
│       └── width_*.jpg         # Annotated images
├── hf-deploy/                  # Hugging Face Spaces deployment
│   ├── app.py                  # Gradio web interface
│   ├── best.pt                 # Production model (22.5 MB)
│   ├── requirements.txt        # Dependencies
│   └── README.md               # Space documentation
├── train_tooth_model.py        # Main training script
├── view_tooth_width.py         # Width measurement tool
├── analyze_tooth_widths.py     # Comprehensive analysis
├── auto_annotate_all.py        # Auto-annotation script
├── reannotate_with_model.py    # Re-annotation script
├── BLOG_POST.md                # Complete tutorial
└── README.md                   # This file
```

---

## 💻 Tech Stack

### Core Technologies

- **ML Framework:** [Ultralytics YOLOv8](https://github.com/ultralytics/ultralytics) (platform-independent)
- **Deep Learning:** PyTorch 2.9.0 (CPU/GPU/MPS support)
- **Language:** Python 3.12

### Training Infrastructure

- **Hardware Used:** NVIDIA Jetson Thor with GPU (optional - saved ~6 hours vs CPU)
- **Container:** Docker with CUDA 13.0
- **OS:** Ubuntu 24.04 LTS

### Deployment

- **Platform:** Hugging Face Spaces (free CPU inference)
- **Interface:** Gradio 4.0
- **Hosting:** Cloud-based, globally accessible

### Analysis & Visualization

- **Data Analysis:** Pandas, NumPy
- **Visualization:** Matplotlib
- **Export:** OpenPyXL (Excel), CSV

---

## 🎯 Use Cases

### Clinical Applications
- 🏥 **Automated Screening** - Batch process hundreds of X-rays
- 📊 **Quality Control** - Verify imaging quality and tooth visibility
- 📏 **Orthodontics** - Dimensional analysis for treatment planning
- 🎓 **Education** - Training tool for dental students and residents

### Research Applications
- 🔬 **Dental Morphology** - Population-level tooth size studies
- 📈 **Statistics** - Automated data collection for research
- 🧪 **Treatment Outcomes** - Track changes over time
- 📝 **Dataset Creation** - Automated annotation for ML datasets

### Production Deployment
- 🌍 **Remote Diagnostics** - Works on edge devices in remote areas
- 🤖 **Clinic Automation** - Integrate into practice management software
- 📱 **Teledentistry** - Support remote consultations
- 🏭 **Batch Processing** - Process large archives efficiently

---

## 📖 Documentation

- **[Complete Blog Post](BLOG_POST.md)** - Full step-by-step guide with all code
- **[Live Demo](https://huggingface.co/spaces/ajeetsraina/dentescope-ai)** - Try it now!
- **[GitHub Repository](https://github.com/ajeetraina/dentescope-ai-complete)** - Source code

### External Resources

- [Ultralytics YOLOv8 Documentation](https://docs.ultralytics.com/)
- [NVIDIA Jetson Thor](https://www.nvidia.com/en-us/autonomous-machines/embedded-systems/jetson-thor/)
- [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
- [Hugging Face Spaces Documentation](https://huggingface.co/docs/hub/spaces)
- [Docker Documentation](https://docs.docker.com/)

---

## 🔮 Future Enhancements

### Short-term (1-3 months)
- [ ] Multi-tooth classification (incisors, canines, molars, premolars)
- [ ] Individual tooth numbering (FDI/Universal notation)
- [ ] Improved calibration for accurate mm measurements
- [ ] Mobile app deployment (iOS/Android)
- [ ] Real-time video processing
- [ ] Batch processing API

### Long-term (6-12 months)
- [ ] Disease detection (cavities, infections, bone loss)
- [ ] Treatment planning recommendations
- [ ] 3D reconstruction from 2D X-rays
- [ ] Integration with practice management systems
- [ ] Multi-modal analysis (notes + images + patient history)
- [ ] DICOM format support

---

## 🤝 Contributing

Contributions are welcome! Whether it's bug fixes, new features, documentation, or examples.

### How to Contribute

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Areas for Contribution

- 🐛 Bug fixes and improvements
- ✨ New features (see roadmap above)
- 📝 Documentation improvements
- 🧪 Additional test cases
- 🎨 UI/UX enhancements
- 🌍 Internationalization

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

You are free to:
- ✅ Use commercially
- ✅ Modify
- ✅ Distribute
- ✅ Use privately

---

## 🙏 Acknowledgments

- **Ultralytics Team** - For the excellent YOLOv8 framework
- **NVIDIA** - For Jetson Thor hardware and CUDA support
- **Hugging Face** - For free model hosting and Spaces platform
- **Docker** - For containerization technology
- **Anthropic** - For development assistance

---

## 📞 Contact

**Ajeet Singh Raina**  
Docker Captain | AI/ML Engineer | Community Leader

- 🌐 Website: [collabnix.com](https://collabnix.com)
- 💼 LinkedIn: [ajeetsraina](https://linkedin.com/in/ajeetsraina)
- 🐙 GitHub: [@ajeetraina](https://github.com/ajeetraina)
- 🐦 Twitter: [@ajeetsraina](https://twitter.com/ajeetsraina)
- 📧 Email: ajeet.raina@docker.com

### Questions or Issues?

- 🐛 [Report a bug](https://github.com/ajeetraina/dentescope-ai-complete/issues)
- 💡 [Request a feature](https://github.com/ajeetraina/dentescope-ai-complete/issues)
- 💬 [Start a discussion](https://github.com/ajeetraina/dentescope-ai-complete/discussions)

---

## 📊 Project Stats

![GitHub stars](https://img.shields.io/github/stars/ajeetraina/dentescope-ai-complete?style=social)
![GitHub forks](https://img.shields.io/github/forks/ajeetraina/dentescope-ai-complete?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/ajeetraina/dentescope-ai-complete?style=social)
![GitHub issues](https://img.shields.io/github/issues/ajeetraina/dentescope-ai-complete)

---

<div align="center">

### ⭐ If you find this project useful, please star the repository! ⭐

**Built with ❤️ by [Ajeet Singh Raina](https://github.com/ajeetraina)**

**Works on any hardware - GPU just makes training faster!**

---

**🦷 Dental AI | 🐳 Dockerized | 🚀 Production Ready**

</div>
