# Train Tooth Detection Model

## Quick Start (3 Steps)

### 1. Setup
```bash
pip install -r requirements-training.txt
```

### 2. Prepare Data
Put your 79 X-ray images in `./images/`

If you have labels (YOLO format .txt files), put them with the images.
If no labels, you need to annotate first using Roboflow or LabelImg.

### 3. Train
```bash
./quick_start.sh
```

That's it! The script will:
- Split data (train/val/test)
- Train YOLOv8 model
- Test prediction
- Save model to `runs/train/tooth_detection/weights/best.pt`

## Manual Training

```bash
# Prepare dataset
python3 prepare_data.py --images ./images --output ./dataset

# Train model
python3 train_model.py --data dataset/data.yaml --size m --epochs 100

# Run prediction
python3 predict.py --model runs/train/tooth_detection/weights/best.pt --image test.jpg
```

## Model Sizes

- `n` (nano) - Fast, 3M params
- `s` (small) - Balanced, 11M params  
- `m` (medium) - **Recommended**, 26M params
- `l` (large) - Accurate, 44M params
- `x` (xlarge) - Best, 68M params

## Expected Results

- Training time: 30-60 min (GPU) or 2-4 hours (CPU)
- mAP50: 0.70-0.90 (with good annotations)
- Inference: ~20-100 FPS

## Use Trained Model

```python
from ultralytics import YOLO

model = YOLO('runs/train/tooth_detection/weights/best.pt')
results = model.predict('xray.jpg', conf=0.5)

for r in results:
    print(f"Detected {len(r.boxes)} teeth")
```