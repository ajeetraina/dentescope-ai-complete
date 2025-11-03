#!/bin/bash
"""
DenteScope AI - Complete Setup Script
Automated setup for the entire project

Author: Ajeet Singh Raina
Date: November 3, 2025
"""

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================================="
echo -e "${BLUE}🦷 DenteScope AI - Complete Setup${NC}"
echo "=========================================================="
echo ""

# Function to print step headers
print_step() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Step 1: Create directory structure
print_step "Step 1: Creating Directory Structure"

echo "📁 Creating data directories..."
mkdir -p data/train/images data/train/labels
mkdir -p data/val/images data/val/labels
mkdir -p data/valid/images data/valid/labels  # Alternate name
mkdir -p data/test/images data/test/labels
mkdir -p data/raw

echo "📁 Creating results directories..."
mkdir -p results/width_analysis
mkdir -p results/pathology_detection
mkdir -p results/batch
mkdir -p results/comparison
mkdir -p results/training_artifacts

echo "📁 Creating model directories..."
mkdir -p models/production
mkdir -p models/experimental

echo "📁 Creating pathology directories..."
mkdir -p pathology-detection/data/train/images
mkdir -p pathology-detection/data/train/labels
mkdir -p pathology-detection/data/val/images
mkdir -p pathology-detection/data/val/labels
mkdir -p pathology-detection/models
mkdir -p pathology-detection/results

echo -e "${GREEN}✅ Directory structure created${NC}"

# Step 2: Check Python installation
print_step "Step 2: Checking Python Installation"

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✅ Python found: $PYTHON_VERSION${NC}"
else
    echo -e "${RED}❌ Python 3 not found. Please install Python 3.10+${NC}"
    exit 1
fi

# Step 3: Create virtual environment
print_step "Step 3: Setting Up Virtual Environment"

if [ ! -d "venv" ]; then
    echo "🔧 Creating virtual environment..."
    python3 -m venv venv
    echo -e "${GREEN}✅ Virtual environment created${NC}"
else
    echo -e "${YELLOW}⚠️  Virtual environment already exists${NC}"
fi

echo "📦 Activating virtual environment..."
source venv/bin/activate

# Step 4: Install dependencies
print_step "Step 4: Installing Dependencies"

echo "📦 Installing core packages..."
pip install --upgrade pip -q
pip install ultralytics opencv-python pillow pyyaml matplotlib pandas openpyxl tqdm -q

echo "📦 Installing Roboflow (optional)..."
pip install roboflow -q || echo -e "${YELLOW}⚠️  Roboflow install skipped${NC}"

echo -e "${GREEN}✅ Dependencies installed${NC}"

# Step 5: Download sample data (optional)
print_step "Step 5: Dataset Setup (Optional)"

echo "Do you want to download a sample dataset from Roboflow? (y/n)"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo ""
    echo "Please enter your Roboflow API key (or press Enter to skip):"
    read -r ROBOFLOW_KEY
    
    if [ -n "$ROBOFLOW_KEY" ]; then
        echo "📥 Downloading dataset..."
        python << EOF
try:
    from roboflow import Roboflow
    rf = Roboflow(api_key="$ROBOFLOW_KEY")
    project = rf.workspace("dental-yvybz").project("panoramic-xray-mk1hj-fh78n")
    dataset = project.version(1).download("yolov8", location="./data")
    print("\n✅ Dataset downloaded successfully!")
except Exception as e:
    print(f"❌ Error downloading dataset: {e}")
    print("You can download manually later. See docs/ROBOFLOW_SETUP.md")
EOF
    else
        echo -e "${YELLOW}⚠️  Skipped dataset download${NC}"
        echo "📖 See docs/ROBOFLOW_SETUP.md for manual download instructions"
    fi
else
    echo -e "${YELLOW}⚠️  Skipped dataset download${NC}"
    echo "📖 You can:"
    echo "   1. Download from Roboflow: docs/ROBOFLOW_SETUP.md"
    echo "   2. Use your own images: place in data/raw/"
    echo "   3. Create dummy annotations for testing"
fi

# Step 6: Create data.yaml if needed
print_step "Step 6: Creating Configuration Files"

if [ ! -f "data/data.yaml" ]; then
    echo "📝 Creating data.yaml..."
    cat > data/data.yaml << 'YAML'
# DenteScope AI - Training Configuration
path: $(pwd)/data
train: train/images
val: val/images

nc: 1
names: ['tooth']
YAML
    echo -e "${GREEN}✅ data.yaml created${NC}"
else
    echo -e "${YELLOW}⚠️  data.yaml already exists${NC}"
fi

# Step 7: Verify setup
print_step "Step 7: Verifying Setup"

echo "🔍 Checking directory structure..."
if [ -d "data/train" ] && [ -d "data/val" ]; then
    echo -e "${GREEN}✅ Directory structure OK${NC}"
else
    echo -e "${RED}❌ Directory structure incomplete${NC}"
fi

echo "🔍 Checking Python packages..."
python << 'EOF'
try:
    import ultralytics
    import cv2
    import PIL
    print("✅ Core packages installed")
except ImportError as e:
    print(f"❌ Missing package: {e}")
EOF

echo "🔍 Checking data.yaml..."
if [ -f "data/data.yaml" ]; then
    echo -e "${GREEN}✅ data.yaml exists${NC}"
else
    echo -e "${RED}❌ data.yaml missing${NC}"
fi

# Step 8: Summary and next steps
print_step "Setup Complete! 🎉"

echo -e "${GREEN}✅ DenteScope AI setup completed successfully!${NC}"
echo ""
echo "📊 Setup Summary:"
echo "  ✓ Directory structure created"
echo "  ✓ Virtual environment ready"
echo "  ✓ Dependencies installed"
echo "  ✓ Configuration files created"
echo ""
echo "📝 Next Steps:"
echo ""
echo "1️⃣  Add training data:"
echo "   ${YELLOW}# Option A: Download from Roboflow${NC}"
echo "   python scripts/download_roboflow.py"
echo ""
echo "   ${YELLOW}# Option B: Use your own images${NC}"
echo "   cp /path/to/xrays/*.jpg data/raw/"
echo "   python scripts/prepare_annotations.py setup --images data/raw"
echo ""
echo "2️⃣  Train your first model:"
echo "   ${GREEN}python train_tooth_model.py \\${NC}"
echo "   ${GREEN}  --dataset ./data \\${NC}"
echo "   ${GREEN}  --model-size n \\${NC}"
echo "   ${GREEN}  --epochs 50 \\${NC}"
echo "   ${GREEN}  --batch-size 4 \\${NC}"
echo "   ${GREEN}  --device 0${NC}"
echo ""
echo "3️⃣  Test your model:"
echo "   python examples/batch_process.py --input data/val/images"
echo ""
echo "📚 Documentation:"
echo "   • Quick Setup: QUICK_SETUP.md"
echo "   • Training Guide: TRAINING_GUIDE.md"
echo "   • Roboflow Setup: docs/ROBOFLOW_SETUP.md"
echo "   • Width Analysis: docs/WIDTH_ANALYSIS_GUIDE.md"
echo ""
echo "💡 Tips:"
echo "   • Activate venv: source venv/bin/activate"
echo "   • GPU recommended for faster training"
echo "   • Start with YOLOv8n (nano) for testing"
echo ""
echo "🔗 Need help? Check: https://github.com/ajeetraina/dentescope-ai-complete"
echo ""
echo "=========================================================="
echo -e "${GREEN}Happy Training! 🚀${NC}"
echo "=========================================================="
