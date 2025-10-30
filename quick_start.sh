#!/bin/bash
# Quick start script for tooth detection training

set -e

echo "🦷 DenteScope AI - Training Pipeline"
echo "===================================="
echo ""

# Check if images directory exists
if [ ! -d "./images" ]; then
    echo "❌ Error: ./images directory not found"
    echo "Please put your 79 X-ray images in ./images/"
    exit 1
fi

# Count images
IMG_COUNT=$(find ./images -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | wc -l)
echo "📸 Found $IMG_COUNT images"

if [ $IMG_COUNT -eq 0 ]; then
    echo "❌ No images found in ./images/"
    exit 1
fi

# Step 1: Prepare dataset
echo ""
echo "📦 Step 1: Preparing dataset..."
python3 prepare_data.py --images ./images --output ./dataset

# Step 2: Train model
echo ""
echo "🎯 Step 2: Training model..."
echo "Model size: medium (m) - good balance"
echo "Epochs: 100"
echo "Batch: 16"
echo ""

python3 train_model.py \
    --data dataset/data.yaml \
    --size m \
    --epochs 100 \
    --batch 16 \
    --device 0

# Step 3: Test prediction
echo ""
echo "🔍 Step 3: Testing prediction..."
TEST_IMG=$(find ./dataset/images/test -type f -name "*.jpg" -o -name "*.png" | head -1)

if [ -n "$TEST_IMG" ]; then
    python3 predict.py --model runs/train/tooth_detection/weights/best.pt --image "$TEST_IMG"
else
    echo "No test images found"
fi

echo ""
echo "✅ Training Complete!"
echo ""
echo "📊 View results:"
echo "  - Training metrics: runs/train/tooth_detection/"
echo "  - Best model: runs/train/tooth_detection/weights/best.pt"
echo "  - Predictions: runs/predict/results/"
echo ""
echo "🚀 Use the model:"
echo "  python3 predict.py --model runs/train/tooth_detection/weights/best.pt --image your_image.jpg"
echo ""