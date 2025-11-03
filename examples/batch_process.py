#!/usr/bin/env python3
"""
DenteScope AI - Batch Processing Script
Process multiple dental X-rays efficiently

Author: Ajeet Singh Raina
Date: November 3, 2025
"""

import argparse
from pathlib import Path
import pandas as pd
from ultralytics import YOLO
from tqdm import tqdm
import json
from datetime import datetime


def batch_process(model_path: str, input_dir: str, output_dir: str, 
                  conf_threshold: float = 0.25, save_images: bool = True):
    """
    Process multiple dental X-rays in batch mode.
    
    Args:
        model_path: Path to trained model weights
        input_dir: Directory containing input images
        output_dir: Directory for output results
        conf_threshold: Confidence threshold for detections
        save_images: Whether to save annotated images
    """
    # Load model
    print(f"📦 Loading model: {model_path}")
    model = YOLO(model_path)
    
    # Create output directory
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    if save_images:
        (output_path / "images").mkdir(exist_ok=True)
    
    # Find all images
    input_path = Path(input_dir)
    image_files = list(input_path.glob("*.jpg")) + \
                  list(input_path.glob("*.png")) + \
                  list(input_path.glob("*.jpeg"))
    
    print(f"📸 Found {len(image_files)} images")
    
    # Process images
    results_data = []
    
    for img_path in tqdm(image_files, desc="Processing"):
        # Run inference
        results = model(str(img_path), conf=conf_threshold, verbose=False)
        
        # Extract results
        for box in results[0].boxes:
            x1, y1, x2, y2 = box.xyxy[0].tolist()
            conf = box.conf[0].item()
            
            # Calculate measurements
            width_px = x2 - x1
            height_px = y2 - y1
            width_mm = width_px * 0.1  # Calibration factor
            height_mm = height_px * 0.1
            
            results_data.append({
                "image": img_path.name,
                "patient": img_path.stem.split('_')[0],  # Extract patient ID
                "width_px": round(width_px, 2),
                "width_mm": round(width_mm, 2),
                "height_px": round(height_px, 2),
                "height_mm": round(height_mm, 2),
                "confidence": round(conf, 3),
                "x1": round(x1, 2),
                "y1": round(y1, 2),
                "x2": round(x2, 2),
                "y2": round(y2, 2)
            })
        
        # Save annotated image
        if save_images and len(results[0].boxes) > 0:
            save_path = output_path / "images" / f"annotated_{img_path.name}"
            results[0].save(str(save_path))
    
    # Save results
    if results_data:
        # CSV
        df = pd.DataFrame(results_data)
        csv_path = output_path / "batch_results.csv"
        df.to_csv(csv_path, index=False)
        print(f"📊 CSV saved: {csv_path}")
        
        # Excel
        excel_path = output_path / "batch_results.xlsx"
        with pd.ExcelWriter(excel_path) as writer:
            df.to_excel(writer, sheet_name="Raw Data", index=False)
            
            # Summary statistics
            summary = df[['width_mm', 'height_mm', 'confidence']].describe()
            summary.to_excel(writer, sheet_name="Statistics")
        
        print(f"📈 Excel saved: {excel_path}")
        
        # JSON
        json_path = output_path / "batch_results.json"
        with open(json_path, 'w') as f:
            json.dump({
                "metadata": {
                    "processed_date": datetime.now().isoformat(),
                    "model": model_path,
                    "total_images": len(image_files),
                    "total_detections": len(results_data)
                },
                "results": results_data
            }, f, indent=2)
        
        print(f"📝 JSON saved: {json_path}")
        
        # Summary
        print(f"\n🎯 Summary:")
        print(f"  • Images processed: {len(image_files)}")
        print(f"  • Total detections: {len(results_data)}")
        print(f"  • Average confidence: {df['confidence'].mean():.1%}")
        print(f"  • Mean width: {df['width_mm'].mean():.1f}mm (±{df['width_mm'].std():.2f})")
    else:
        print("⚠️  No detections found")


def main():
    parser = argparse.ArgumentParser(
        description="DenteScope AI - Batch Processing"
    )
    parser.add_argument(
        "--model",
        type=str,
        default="runs/train/tooth_detection3/weights/best.pt",
        help="Path to model weights"
    )
    parser.add_argument(
        "--input",
        type=str,
        required=True,
        help="Input directory with images"
    )
    parser.add_argument(
        "--output",
        type=str,
        default="results/batch",
        help="Output directory"
    )
    parser.add_argument(
        "--conf",
        type=float,
        default=0.25,
        help="Confidence threshold"
    )
    parser.add_argument(
        "--no-save-images",
        action="store_true",
        help="Don't save annotated images"
    )
    
    args = parser.parse_args()
    
    print("="*60)
    print("🦷 DenteScope AI - Batch Processing")
    print("="*60)
    
    batch_process(
        model_path=args.model,
        input_dir=args.input,
        output_dir=args.output,
        conf_threshold=args.conf,
        save_images=not args.no_save_images
    )
    
    print("\n✅ Batch processing complete!")


if __name__ == "__main__":
    main()
