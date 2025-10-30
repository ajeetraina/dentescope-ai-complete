#!/usr/bin/env python3
"""
DenteScope AI - YOLOv8 Tooth Detection Model Training
Train a custom YOLOv8 model to detect and measure tooth widths
"""

from ultralytics import YOLO
import yaml
import os
from pathlib import Path

def create_data_yaml(dataset_path, num_classes=1):
    """
    Create data.yaml configuration file for YOLOv8 training
    """
    data_config = {
        'path': str(dataset_path),  # Dataset root directory
        'train': 'train/images',    # Train images
        'val': 'val/images',        # Validation images
        'test': 'test/images',      # Test images (optional)
        
        # Classes
        'nc': num_classes,          # Number of classes
        'names': ['tooth']          # Class names
    }
    
    yaml_path = os.path.join(dataset_path, 'data.yaml')
    with open(yaml_path, 'w') as f:
        yaml.dump(data_config, f, default_flow_style=False)
    
    print(f"✓ Created data.yaml at {yaml_path}")
    return yaml_path

def train_model(
    data_yaml_path,
    model_size='n',  # n, s, m, l, x
    epochs=100,
    imgsz=640,
    batch_size=16,
    device='0',  # GPU device, or 'cpu'
    project='runs/train',
    name='tooth_detection'
):
    """
    Train YOLOv8 model for tooth detection
    
    Args:
        data_yaml_path: Path to data.yaml file
        model_size: Model size (n=nano, s=small, m=medium, l=large, x=xlarge)
        epochs: Number of training epochs
        imgsz: Input image size
        batch_size: Batch size for training
        device: GPU device ID or 'cpu'
        project: Project directory
        name: Experiment name
    """
    
    print("=" * 60)
    print("DenteScope AI - YOLOv8 Training")
    print("=" * 60)
    
    # Load pretrained YOLOv8 model
    model_name = f'yolov8{model_size}.pt'
    print(f"\n📦 Loading pretrained model: {model_name}")
    model = YOLO(model_name)
    
    # Training parameters
    print(f"\n⚙️  Training Configuration:")
    print(f"   • Dataset: {data_yaml_path}")
    print(f"   • Epochs: {epochs}")
    print(f"   • Image Size: {imgsz}")
    print(f"   • Batch Size: {batch_size}")
    print(f"   • Device: {device}")
    
    # Start training
    print(f"\n🚀 Starting training...")
    results = model.train(
        data=data_yaml_path,
        epochs=epochs,
        imgsz=imgsz,
        batch=batch_size,
        device=device,
        project=project,
        name=name,
        patience=50,  # Early stopping patience
        save=True,
        save_period=10,  # Save checkpoint every 10 epochs
        cache=True,  # Cache images for faster training
        verbose=True,
        plots=True,  # Generate training plots
        
        # Data augmentation
        hsv_h=0.015,  # HSV-Hue augmentation
        hsv_s=0.7,    # HSV-Saturation augmentation
        hsv_v=0.4,    # HSV-Value augmentation
        degrees=10,   # Rotation augmentation
        translate=0.1,  # Translation augmentation
        scale=0.5,    # Scale augmentation
        shear=0.0,    # Shear augmentation
        perspective=0.0,  # Perspective augmentation
        flipud=0.5,   # Flip up-down augmentation
        fliplr=0.5,   # Flip left-right augmentation
        mosaic=1.0,   # Mosaic augmentation
        mixup=0.0,    # Mixup augmentation
    )
    
    print(f"\n✅ Training completed!")
    print(f"   • Best model saved to: {project}/{name}/weights/best.pt")
    print(f"   • Last model saved to: {project}/{name}/weights/last.pt")
    
    return results

def validate_model(model_path, data_yaml_path):
    """
    Validate the trained model
    """
    print("\n" + "=" * 60)
    print("Model Validation")
    print("=" * 60)
    
    model = YOLO(model_path)
    
    # Validate on validation set
    results = model.val(data=data_yaml_path)
    
    print(f"\n📊 Validation Metrics:")
    print(f"   • mAP@0.5: {results.box.map50:.4f}")
    print(f"   • mAP@0.5:0.95: {results.box.map:.4f}")
    print(f"   • Precision: {results.box.mp:.4f}")
    print(f"   • Recall: {results.box.mr:.4f}")
    
    return results

def test_prediction(model_path, test_image_path, save_dir='runs/predict'):
    """
    Test prediction on a sample image
    """
    print("\n" + "=" * 60)
    print("Test Prediction")
    print("=" * 60)
    
    model = YOLO(model_path)
    
    # Run inference
    results = model.predict(
        source=test_image_path,
        save=True,
        save_txt=True,
        project=save_dir,
        name='test',
        conf=0.25,  # Confidence threshold
        iou=0.45,   # NMS IOU threshold
    )
    
    print(f"\n✓ Predictions saved to: {save_dir}/test")
    
    # Display detection results
    for r in results:
        boxes = r.boxes
        print(f"\n🦷 Detected {len(boxes)} tooth/teeth:")
        for i, box in enumerate(boxes):
            conf = box.conf[0].item()
            cls = int(box.cls[0].item())
            xyxy = box.xyxy[0].tolist()
            print(f"   {i+1}. Class: {cls}, Confidence: {conf:.3f}, BBox: {xyxy}")
    
    return results

def export_model(model_path, export_format='onnx'):
    """
    Export model to different formats for deployment
    """
    print("\n" + "=" * 60)
    print(f"Exporting Model to {export_format.upper()}")
    print("=" * 60)
    
    model = YOLO(model_path)
    
    # Export model
    model.export(format=export_format)
    
    print(f"✓ Model exported to {export_format.upper()} format")

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Train YOLOv8 for tooth detection')
    parser.add_argument('--dataset', type=str, required=True, help='Path to dataset directory')
    parser.add_argument('--model-size', type=str, default='n', choices=['n', 's', 'm', 'l', 'x'],
                        help='Model size (n=nano, s=small, m=medium, l=large, x=xlarge)')
    parser.add_argument('--epochs', type=int, default=100, help='Number of training epochs')
    parser.add_argument('--batch-size', type=int, default=16, help='Batch size')
    parser.add_argument('--imgsz', type=int, default=640, help='Input image size')
    parser.add_argument('--device', type=str, default='0', help='GPU device (0, 1, 2, ...) or cpu')
    parser.add_argument('--validate', action='store_true', help='Run validation after training')
    parser.add_argument('--test-image', type=str, help='Test prediction on a sample image')
    parser.add_argument('--export', type=str, choices=['onnx', 'torchscript', 'coreml', 'tflite'],
                        help='Export model format after training')
    
    args = parser.parse_args()
    
    # Create data.yaml if it doesn't exist
    data_yaml = os.path.join(args.dataset, 'data.yaml')
    if not os.path.exists(data_yaml):
        print("\n⚠️  data.yaml not found, creating one...")
        data_yaml = create_data_yaml(args.dataset)
    
    # Train model
    results = train_model(
        data_yaml_path=data_yaml,
        model_size=args.model_size,
        epochs=args.epochs,
        imgsz=args.imgsz,
        batch_size=args.batch_size,
        device=args.device
    )
    
    # Get best model path
    best_model = f'runs/train/tooth_detection/weights/best.pt'
    
    # Validate if requested
    if args.validate:
        validate_model(best_model, data_yaml)
    
    # Test prediction if image provided
    if args.test_image:
        test_prediction(best_model, args.test_image)
    
    # Export if requested
    if args.export:
        export_model(best_model, args.export)
    
    print("\n" + "=" * 60)
    print("🎉 All operations completed successfully!")
    print("=" * 60)
