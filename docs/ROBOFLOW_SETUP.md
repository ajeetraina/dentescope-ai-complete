# 🤖 Roboflow Dataset Setup Guide

## Overview

This guide shows how to download pre-annotated dental datasets from Roboflow Universe for training DenteScope AI models.

**Advantages:**
- ✅ Pre-annotated datasets (saves 6-13 hours of manual work)
- ✅ Professional quality annotations
- ✅ Train/val/test splits already done
- ✅ YOLO format ready
- ✅ Free public datasets available

---

## 🚀 Quick Start

### Step 1: Get Roboflow API Key

1. Go to [https://app.roboflow.com/](https://app.roboflow.com/)
2. Sign up for a free account
3. Navigate to **Settings** → **Roboflow API**
4. Copy your API key

---

### Step 2: Install Roboflow

```bash
# Install roboflow package
pip install roboflow --break-system-packages

# Or with venv
source venv/bin/activate
pip install roboflow
```

**Expected output:**
```
Collecting roboflow
  Downloading roboflow-1.2.11-py3-none-any.whl (89 kB)
...
Successfully installed roboflow-1.2.11
```

---

## 📥 Download Pre-Annotated Dataset

### Method 1: Using Python Script

Create `download_roboflow_data.py`:

```python
from roboflow import Roboflow

# Initialize Roboflow with your API key
rf = Roboflow(api_key="YOUR_API_KEY_HERE")  # Replace with your key

# Access the dental workspace and project
project = rf.workspace("dental-yvybz").project("panoramic-xray-mk1hj-fh78n")

# Download the dataset in YOLOv8 format
print("📥 Downloading dataset...")
dataset = project.version(1).download("yolov8", location="./data")

print(f"\n✅ Dataset downloaded to: {dataset.location}")
print("\n📊 Dataset structure:")
print(f"  - Training images: data/train/images/")
print(f"  - Training labels: data/train/labels/")
print(f"  - Validation images: data/valid/images/")
print(f"  - Validation labels: data/valid/labels/")
print(f"  - Configuration: data/data.yaml")
```

**Run it:**
```bash
python download_roboflow_data.py
```

**Expected output:**
```
loading Roboflow workspace...
loading Roboflow project...
Downloading Dataset Version Zip in yolov8 to ./data: 100%|████| 10.5M/10.5M
Extracting Dataset Version Zip to ./data... Done!

✅ Dataset downloaded to: /home/user/dentescope-ai-complete/data

📊 Dataset structure:
  - Training images: data/train/images/
  - Training labels: data/train/labels/
  - Validation images: data/valid/images/
  - Validation labels: data/valid/labels/
  - Configuration: data/data.yaml
```

---

### Method 2: Direct Download (Command Line)

```bash
# Create download script
cat > download_dataset.py << 'EOF'
from roboflow import Roboflow

rf = Roboflow(api_key="40NFqklaKRRkEDSxmjww")  # Your API key
project = rf.workspace("dental-yvybz").project("panoramic-xray-mk1hj-fh78n")

try:
    dataset = project.version(1).download("yolov8", location="./data")
    print(f"\n✅ Dataset downloaded to: {dataset.location}")
except Exception as e:
    print(f"❌ Error: {e}")
EOF

# Run it
python download_dataset.py
```

---

## 🔍 Find Dental Datasets on Roboflow

### Browse Roboflow Universe

1. **Visit:** [https://universe.roboflow.com/](https://universe.roboflow.com/)
2. **Search for:** "dental", "tooth detection", "dental xray", or "panoramic xray"
3. **Filter by:**
   - Task type: Object Detection
   - Format: YOLOv8
   - License: Open source

### Popular Dental Datasets

| Dataset | Images | Classes | Quality | Link |
|---------|--------|---------|---------|------|
| Panoramic X-ray | 100+ | 1-3 | High | [Link](https://universe.roboflow.com/search?q=panoramic) |
| Tooth Detection | 200+ | 1 | Good | [Link](https://universe.roboflow.com/search?q=tooth) |
| Dental Caries | 150+ | 2 | Medium | [Link](https://universe.roboflow.com/search?q=caries) |

---

## 📁 Dataset Structure After Download

```
data/
├── train/
│   ├── images/          # Training images
│   │   ├── img001.jpg
│   │   ├── img002.jpg
│   │   └── ...
│   └── labels/          # YOLO format annotations
│       ├── img001.txt
│       ├── img002.txt
│       └── ...
├── valid/
│   ├── images/          # Validation images
│   └── labels/          # Validation annotations
├── test/                # Optional test set
│   ├── images/
│   └── labels/
└── data.yaml            # Dataset configuration
```

### data.yaml Example

```yaml
train: ../train/images
val: ../valid/images

nc: 1
names: ['tooth']

roboflow:
  workspace: dental-yvybz
  project: panoramic-xray-mk1hj-fh78n
  version: 1
  license: CC BY 4.0
  url: https://universe.roboflow.com/dental-yvybz/panoramic-xray-mk1hj-fh78n/dataset/1
```

---

## ✅ Verify Downloaded Dataset

```bash
# Check directory structure
ls -R data/

# Count images
echo "Training images: $(ls data/train/images/ | wc -l)"
echo "Training labels: $(ls data/train/labels/ | wc -l)"
echo "Validation images: $(ls data/valid/images/ | wc -l)"
echo "Validation labels: $(ls data/valid/labels/ | wc -l)"

# View data.yaml
cat data/data.yaml

# Check a label file
head -5 data/train/labels/*.txt | head -20
```

**Expected output:**
```
Training images: 58
Training labels: 58
Validation images: 15
Validation labels: 15
```

---

## 🎯 Start Training Immediately

Once downloaded, you can start training right away:

```bash
python train_tooth_model.py \
  --dataset ./data \
  --model-size n \
  --epochs 50 \
  --batch-size 4 \
  --device 0
```

**No annotation needed!** The dataset is ready to use.

---

## 🔧 Troubleshooting

### Issue: "API key invalid"

**Solution:**
```bash
# Get new API key from Roboflow settings
# Update in your script
rf = Roboflow(api_key="YOUR_NEW_KEY")
```

### Issue: "Project not found"

**Solution:**
```python
# Check project info first
rf = Roboflow(api_key="YOUR_API_KEY")
project = rf.workspace("dental-yvybz").project("panoramic-xray-mk1hj-fh78n")

# Print project details
print(project)
print(project.versions)  # See available versions
```

### Issue: "Download fails"

**Solution:**
```bash
# Check internet connection
ping universe.roboflow.com

# Try downloading to different location
dataset = project.version(1).download("yolov8", location="./downloads")

# Check disk space
df -h .
```

### Issue: "Dataset format incorrect"

**Solution:**
```python
# Ensure YOLOv8 format
dataset = project.version(1).download(
    "yolov8",  # Must be "yolov8" for YOLO format
    location="./data"
)

# Other formats available:
# - "yolov5"
# - "coco"
# - "voc"
# - "tensorflow"
```

---

## 🆚 Roboflow vs Manual Annotation

| Aspect | Roboflow | Manual Annotation |
|--------|----------|-------------------|
| **Time** | 5 minutes | 6-13 hours |
| **Cost** | Free (public) | Time = money |
| **Quality** | Professional | Varies |
| **Format** | YOLO ready | Needs conversion |
| **Splits** | Pre-done | Manual |
| **Validation** | Expert reviewed | Self-check |

**Recommendation:** Start with Roboflow, then add your own data later.

---

## 🔄 Alternative: Use Local Dataset

If Roboflow doesn't work or you prefer local data:

```bash
# Create directory structure
mkdir -p data/train/images data/train/labels
mkdir -p data/val/images data/val/labels

# Place your images
cp /path/to/xrays/*.jpg data/raw/

# Create annotations
python scripts/prepare_annotations.py setup --images data/raw

# Or use labelImg/CVAT for manual annotation
```

---

## 📊 Example Dataset Statistics

**Panoramic X-ray Dataset (dental-yvybz):**

```
Total Images: 73
Training: 58 (79.5%)
Validation: 15 (20.5%)

Classes: 1 (tooth)
Annotations per image: 1-32
Image dimensions: 1280x640 to 2560x1280

Format: YOLO (YOLOv8)
Annotation quality: Expert-reviewed
License: CC BY 4.0
```

---

## 📚 Additional Resources

### Roboflow Documentation
- [Roboflow Python Package](https://docs.roboflow.com/python)
- [Universe Datasets](https://universe.roboflow.com/)
- [YOLOv8 Format](https://docs.roboflow.com/exporting-data/yolov8)

### DenteScope AI Guides
- [Training Guide](../TRAINING_GUIDE.md)
- [Quick Setup](../QUICK_SETUP.md)
- [Training History](training-history/)

---

## 💡 Tips for Best Results

1. **Check dataset quality** before downloading
   - View sample images
   - Check annotation quality
   - Read dataset description

2. **Start with small dataset** for testing
   - Verify the pipeline works
   - Then download larger datasets

3. **Combine datasets** for better results
   - Download multiple related datasets
   - Merge them manually
   - Retrain on combined data

4. **Validate annotations** after download
   - Spot check a few images
   - Ensure labels are correct
   - Fix any obvious errors

---

## 🤝 Contributing Your Dataset

Trained a great model? Consider sharing:

1. Create a Roboflow account
2. Upload your annotated dataset
3. Make it public
4. Help the community! 🎉

---

## 📞 Support

**Need help with Roboflow?**
- Roboflow Docs: [docs.roboflow.com](https://docs.roboflow.com/)
- Community Forum: [forum.roboflow.com](https://forum.roboflow.com/)
- Email: help@roboflow.com

**DenteScope AI Questions?**
- GitHub Issues: [Report issue](https://github.com/ajeetraina/dentescope-ai-complete/issues)
- Email: ajeet.raina@docker.com

---

**Quick command to get started:**

```bash
pip install roboflow
python -c "from roboflow import Roboflow; rf = Roboflow(api_key='YOUR_KEY'); rf.workspace('dental-yvybz').project('panoramic-xray-mk1hj-fh78n').version(1).download('yolov8', location='./data')"
python train_tooth_model.py --dataset ./data --model-size n --epochs 50
```

---

**Last Updated:** November 3, 2025  
**Version:** 1.0
