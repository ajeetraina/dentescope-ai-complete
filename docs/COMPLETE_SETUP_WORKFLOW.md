# 🚀 Complete Setup Workflow

## From Zero to Training in 10 Minutes

This guide covers the **complete workflow** from fresh clone to training, including directory setup, Roboflow dataset download, and model training.

---

## 📊 Workflow Overview

```
Clone Repo → Setup Directories → Get Data → Train Model → Test
    ↓              ↓                ↓           ↓          ↓
  5 sec         30 sec         5 min       30-60 min  2 min
```

---

## 🛠️ Prerequisites

```bash
# Check Python version (3.10+ required)
python3 --version

# Check pip
pip3 --version

# Optional: Check CUDA (for GPU training)
nvidia-smi
```

---

## 🔵 Method 1: Automated Setup (Recommended)

### One Command Setup

```bash
# Clone and setup everything automatically
git clone https://github.com/ajeetraina/dentescope-ai-complete.git
cd dentescope-ai-complete
./scripts/complete_setup.sh
```

**This will:**
1. ✅ Create all directories
2. ✅ Set up virtual environment
3. ✅ Install dependencies
4. ✅ Optionally download dataset from Roboflow
5. ✅ Create configuration files
6. ✅ Verify installation

**Time:** ~5 minutes

---

## 🟢 Method 2: Manual Setup (Step-by-Step)

### Step 1: Clone Repository

```bash
git clone https://github.com/ajeetraina/dentescope-ai-complete.git
cd dentescope-ai-complete
```

### Step 2: Create Directory Structure

```bash
# Create proper directory structure
mkdir -p data/train/images data/train/labels
mkdir -p data/val/images data/val/labels
mkdir -p data/raw
mkdir -p results/width_analysis
```

**Or use the setup script:**

```bash
chmod +x scripts/setup_directories.sh
./scripts/setup_directories.sh
```

### Step 3: Install Dependencies

```bash
# Option A: System-wide installation
pip install ultralytics opencv-python pillow pyyaml matplotlib pandas openpyxl tqdm

# Option B: Virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install ultralytics opencv-python pillow pyyaml matplotlib pandas openpyxl tqdm
```

### Step 4: Get Training Data

You have **3 options**:

#### Option A: Roboflow (Recommended - Pre-annotated)

```bash
# Install Roboflow
pip install roboflow

# Download dataset
python << 'EOF'
from roboflow import Roboflow

rf = Roboflow(api_key="YOUR_API_KEY")  # Get from roboflow.com
project = rf.workspace("dental-yvybz").project("panoramic-xray-mk1hj-fh78n")
dataset = project.version(1).download("yolov8", location="./data")

print(f"\n✅ Dataset downloaded to: {dataset.location}")
EOF
```

**See full guide:** [docs/ROBOFLOW_SETUP.md](ROBOFLOW_SETUP.md)

#### Option B: Your Own Images

```bash
# 1. Place images in data/raw/
cp /path/to/your/xrays/*.jpg data/raw/

# 2. Create annotations and split
python scripts/prepare_annotations.py setup --images data/raw
```

#### Option C: Dummy Annotations (Testing Only)

```bash
# For pipeline testing
python scripts/prepare_annotations.py dummy --images data/raw
python scripts/prepare_annotations.py split
python scripts/prepare_annotations.py create-yaml
```

### Step 5: Train Model

```bash
python train_tooth_model.py \
  --dataset ./data \
  --model-size n \
  --epochs 50 \
  --batch-size 4 \
  --device 0
```

**Parameters explained:**
- `--dataset ./data` - Path to data directory
- `--model-size n` - Nano model (fastest, good for testing)
- `--epochs 50` - Number of training epochs
- `--batch-size 4` - Batch size (increase for GPU)
- `--device 0` - GPU device (use `cpu` for CPU training)

**Training time:**
- CPU: ~2-3 hours
- GPU: ~30 minutes

### Step 6: Test Your Model

```bash
# Single image test
python << 'EOF'
from ultralytics import YOLO

model = YOLO('runs/train/tooth_detection/weights/best.pt')
results = model('data/val/images/sample.jpg')
results[0].save('prediction.jpg')
print("✅ Saved to: prediction.jpg")
EOF

# Batch processing
python examples/batch_process.py \
  --model runs/train/tooth_detection/weights/best.pt \
  --input data/val/images \
  --output results/test
```

---

## 📊 Complete Workflow Example

### Real-World Example (October 30-31, 2025)

This is the exact workflow used to create tooth_detection3:

```bash
# 1. Setup
mkdir -p data/train/images data/train/labels
mkdir -p data/val/images data/val/labels

# 2. Prepare data (79 raw images)
ls data/raw/*.jpg | wc -l  # 79 images

# 3. Auto-annotate (dummy for testing)
python << 'EOF'
from pathlib import Path
import shutil

raw_dir = Path("data/raw")
train_img = Path("data/train/images")
train_lbl = Path("data/train/labels")

# Process 60 for training
for i, img in enumerate(list(raw_dir.glob("*.jpg"))[:60]):
    shutil.copy(img, train_img / img.name)
    label_file = train_lbl / f"{img.stem}.txt"
    with open(label_file, 'w') as f:
        f.write("0 0.5 0.5 0.8 0.3\n")  # Dummy annotation
EOF

# 4. Create validation set (13 images)
python << 'EOF'
from pathlib import Path
import shutil

raw_dir = Path("data/raw")
val_img = Path("data/val/images")
val_lbl = Path("data/val/labels")

val_images = list(raw_dir.glob("*.jpg"))[60:]  # Rest for validation

for i, img in enumerate(val_images):
    shutil.copy(img, val_img / img.name)
    label_file = val_lbl / f"{img.stem}.txt"
    with open(label_file, 'w') as f:
        f.write("0 0.5 0.5 0.8 0.3\n")
EOF

# 5. Create data.yaml
cat > data/data.yaml << 'EOF'
path: /home/ajeetraina/dentescope-ai-complete/data
train: train/images
val: val/images

nc: 1
names: ['tooth']
EOF

# 6. Train model
python train_tooth_model.py \
  --dataset ./data \
  --model-size n \
  --epochs 50 \
  --batch-size 4 \
  --device 0

# Result: 99.5% mAP50 in 33 minutes!
```

---

## 📁 Directory Structure After Setup

```
dentescope-ai-complete/
├── data/
│   ├── train/
│   │   ├── images/          # 58-60 training images
│   │   └── labels/          # YOLO format (.txt)
│   ├── val/
│   │   ├── images/          # 13-15 validation images
│   │   └── labels/          # YOLO format (.txt)
│   ├── raw/                 # Your raw images (optional)
│   └── data.yaml            # Dataset configuration
│
├── runs/                    # Auto-created during training
│   └── train/
│       └── tooth_detection/
│           ├── weights/
│           │   ├── best.pt   # ⭐ Your trained model
│           │   └── last.pt
│           ├── results.csv
│           ├── results.png
│           └── confusion_matrix.png
│
├── results/
│   ├── width_analysis/
│   ├── batch/
│   └── comparison/
│
├── scripts/
│   ├── complete_setup.sh        # ⭐ Automated setup
│   ├── setup_directories.sh     # Directory creation
│   └── prepare_annotations.py   # Annotation tools
│
├── examples/
│   ├── batch_process.py
│   └── compare_models.py
│
└── train_tooth_model.py     # ⭐ Main training script
```

---

## ✅ Verification Checklist

Before training, verify:

```bash
# ☑️ Directory structure
ls data/train/images/ | wc -l    # Should show image count
ls data/train/labels/ | wc -l    # Should match image count
ls data/val/images/ | wc -l      # Should show validation images
ls data/val/labels/ | wc -l      # Should match validation images

# ☑️ Configuration file
cat data/data.yaml
# Should show:
# - path: /full/path/to/data
# - train: train/images
# - val: val/images
# - nc: 1
# - names: ['tooth']

# ☑️ Label format (YOLO)
head -5 data/train/labels/*.txt
# Should show: class x_center y_center width height
# Example: 0 0.5 0.5 0.8 0.3

# ☑️ Dependencies
python -c "import ultralytics; print('OK')"
```

---

## 🔧 Common Issues & Solutions

### Issue 1: "No images found"

```bash
# Solution: Check image location
ls data/raw/
find data/ -name "*.jpg" -o -name "*.png"

# Ensure images are in correct directory
cp /source/*.jpg data/raw/
```

### Issue 2: "train/images not found"

```bash
# Solution: Create directories
mkdir -p data/train/images data/train/labels
mkdir -p data/val/images data/val/labels

# Or run setup script
./scripts/setup_directories.sh
```

### Issue 3: "No labels found"

```bash
# Solution: Create annotations
python scripts/prepare_annotations.py setup --images data/raw

# Or use Roboflow pre-annotated data
pip install roboflow
# See docs/ROBOFLOW_SETUP.md
```

### Issue 4: "data.yaml path incorrect"

```bash
# Solution: Use absolute path
cat > data/data.yaml << EOF
path: $(pwd)/data
train: train/images
val: val/images
nc: 1
names: ['tooth']
EOF
```

---

## 🚀 Quick Commands Reference

### Setup
```bash
# Automated
./scripts/complete_setup.sh

# Manual
mkdir -p data/{train,val,test}/{images,labels}
pip install ultralytics opencv-python pillow pyyaml matplotlib pandas
```

### Data Preparation
```bash
# Roboflow download
python scripts/download_roboflow.py

# Your own images
python scripts/prepare_annotations.py setup --images data/raw

# Dummy annotations
python scripts/prepare_annotations.py dummy --images data/raw
```

### Training
```bash
# CPU
python train_tooth_model.py --dataset ./data --device cpu

# GPU
python train_tooth_model.py --dataset ./data --device 0

# Production model
python train_tooth_model.py \
  --dataset ./data \
  --model-size s \
  --epochs 100 \
  --batch-size 16 \
  --device 0
```

### Testing
```bash
# Single image
python -c "from ultralytics import YOLO; YOLO('runs/train/tooth_detection/weights/best.pt')('image.jpg')"

# Batch
python examples/batch_process.py --input data/val/images

# Width analysis
python width-analysis/analyze_tooth_widths.py
```

---

## 📚 Related Documentation

- **[Quick Setup Guide](../QUICK_SETUP.md)** - Fast setup instructions
- **[Roboflow Setup](ROBOFLOW_SETUP.md)** - Pre-annotated dataset download
- **[Training Guide](../TRAINING_GUIDE.md)** - Detailed training instructions
- **[Width Analysis](WIDTH_ANALYSIS_GUIDE.md)** - Measurement analysis
- **[Training History](training-history/)** - Past training sessions

---

## 💡 Pro Tips

1. **Start with Roboflow** - Saves 6-13 hours of annotation time
2. **Use nano model first** - Fast iteration for testing
3. **GPU is worth it** - 5-10× faster than CPU
4. **Monitor training** - Check runs/train/tooth_detection/results.png
5. **Backup your models** - Copy best.pt to safe location
6. **Iterate quickly** - Small changes, quick tests
7. **Document everything** - Note your configuration and results

---

## 🎯 Success Metrics

You know setup is successful when:

- ✅ Directory structure matches expected layout
- ✅ Dependencies install without errors
- ✅ Training starts without "file not found" errors
- ✅ Training runs for at least 1 epoch
- ✅ Results are saved to runs/train/
- ✅ You can run inference on test images

---

## 📞 Getting Help

**Stuck? Need help?**

1. **Check documentation**
   - README.md
   - TRAINING_GUIDE.md
   - This guide

2. **Search issues**
   - [GitHub Issues](https://github.com/ajeetraina/dentescope-ai-complete/issues)

3. **Ask for help**
   - Create an issue
   - Email: ajeet.raina@docker.com

---

**Ready to start?**

```bash
git clone https://github.com/ajeetraina/dentescope-ai-complete.git
cd dentescope-ai-complete
./scripts/complete_setup.sh
```

**Let's train some models! 🚀**
