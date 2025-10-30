#!/usr/bin/env python3
"""
Run predictions on dental X-rays using trained model
"""

from ultralytics import YOLO
import cv2
from pathlib import Path

def predict(
    model_path='runs/train/tooth_detection/weights/best.pt',
    image_path='test.jpg',
    conf=0.5,
    save=True
):
    """Run prediction on image"""
    
    # Load model
    model = YOLO(model_path)
    
    # Predict
    results = model.predict(
        source=image_path,
        conf=conf,
        save=save,
        project='runs/predict',
        name='results'
    )
    
    # Print results
    for r in results:
        boxes = r.boxes
        print(f"\nDetected {len(boxes)} teeth")
        for i, box in enumerate(boxes):
            conf = box.conf[0]
            cls = box.cls[0]
            print(f"  Tooth {i+1}: confidence={conf:.2f}")
    
    print(f"\n✅ Results saved to: runs/predict/results/")
    
    return results

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser()
    parser.add_argument('--model', default='runs/train/tooth_detection/weights/best.pt', help='Model path')
    parser.add_argument('--image', required=True, help='Image path')
    parser.add_argument('--conf', type=float, default=0.5, help='Confidence threshold')
    
    args = parser.parse_args()
    
    predict(
        model_path=args.model,
        image_path=args.image,
        conf=args.conf
    )