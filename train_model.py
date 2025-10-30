#!/usr/bin/env python3
"""
Simple YOLOv8 Training Script for Tooth Detection
"""

import os
from ultralytics import YOLO

def train_model(
    data_yaml='data.yaml',
    model_size='n',  # n, s, m, l, x
    epochs=100,
    imgsz=640,
    batch=16,
    device='0'
):
    """Train YOLOv8 model"""
    
    # Load model
    model = YOLO(f'yolov8{model_size}.pt')
    
    # Train
    results = model.train(
        data=data_yaml,
        epochs=epochs,
        imgsz=imgsz,
        batch=batch,
        device=device,
        project='runs/train',
        name='tooth_detection',
        patience=50,
        save=True,
        plots=True
    )
    
    # Validate
    metrics = model.val()
    
    print(f"\n✅ Training Complete!")
    print(f"Best model: runs/train/tooth_detection/weights/best.pt")
    print(f"mAP50: {metrics.box.map50:.3f}")
    print(f"mAP50-95: {metrics.box.map:.3f}")
    
    return model

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser()
    parser.add_argument('--data', default='data.yaml', help='data.yaml path')
    parser.add_argument('--size', default='m', choices=['n','s','m','l','x'], help='model size')
    parser.add_argument('--epochs', type=int, default=100, help='epochs')
    parser.add_argument('--batch', type=int, default=16, help='batch size')
    parser.add_argument('--device', default='0', help='cuda device, i.e. 0 or cpu')
    
    args = parser.parse_args()
    
    train_model(
        data_yaml=args.data,
        model_size=args.size,
        epochs=args.epochs,
        batch=args.batch,
        device=args.device
    )