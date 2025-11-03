#!/usr/bin/env python3
"""
DenteScope AI - Comprehensive Tooth Width Analysis
Analyzes tooth widths from detected bounding boxes
Generates statistical reports and visualizations
"""

from ultralytics import YOLO
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from datetime import datetime

def analyze_tooth_widths(model_path, image_dir, output_dir, calibration_factor=0.1):
    """
    Comprehensive tooth width analysis
    
    Args:
        model_path: Path to trained YOLO model
        image_dir: Directory containing dental X-rays
        output_dir: Where to save results
        calibration_factor: Pixels to mm conversion (default 0.1)
    """
    print("🦷 DenteScope AI - Tooth Width Analysis")
    print("=" * 70)
    
    # Load model
    model = YOLO(model_path)
    print(f"✓ Model loaded: {model_path}")
    
    # Get images
    image_dir = Path(image_dir)
    images = list(image_dir.glob('*.jpg'))
    print(f"✓ Found {len(images)} images to analyze\n")
    
    # Collect measurements
    measurements = []
    
    for i, img in enumerate(images, 1):
        print(f"Processing {i}/{len(images)}: {img.name[:50]}")
        
        # Run detection
        results = model.predict(img, conf=0.25, verbose=False)
        
        for r in results:
            for box in r.boxes:
                # Extract coordinates
                x1, y1, x2, y2 = box.xyxy[0].tolist()
                
                # Calculate dimensions
                width_px = x2 - x1
                height_px = y2 - y1
                width_mm = width_px * calibration_factor
                height_mm = height_px * calibration_factor
                conf = box.conf[0].item()
                
                measurements.append({
                    'patient': img.stem[:40],
                    'image': img.name,
                    'width_px': width_px,
                    'height_px': height_px,
                    'width_mm': width_mm,
                    'height_mm': height_mm,
                    'confidence': conf,
                    'bbox': f"({x1:.0f},{y1:.0f},{x2:.0f},{y2:.0f})"
                })
                
                print(f"  ✓ Width: {width_px:.1f}px ({width_mm:.1f}mm), Conf: {conf:.1%}")
    
    # Create DataFrame
    df = pd.DataFrame(measurements)
    
    # Calculate statistics
    print("\n" + "=" * 70)
    print("📊 STATISTICAL ANALYSIS")
    print("=" * 70)
    print(f"\nTotal Measurements: {len(df)}")
    print(f"Total Patients: {len(df['patient'].unique())}")
    
    print(f"\n📏 Width Statistics (mm):")
    print(f"  Mean:      {df['width_mm'].mean():.2f} mm")
    print(f"  Median:    {df['width_mm'].median():.2f} mm")
    print(f"  Std Dev:   {df['width_mm'].std():.2f} mm")
    print(f"  Min:       {df['width_mm'].min():.2f} mm")
    print(f"  Max:       {df['width_mm'].max():.2f} mm")
    print(f"  Range:     {df['width_mm'].max() - df['width_mm'].min():.2f} mm")
    
    print(f"\n📐 Height Statistics (mm):")
    print(f"  Mean:      {df['height_mm'].mean():.2f} mm")
    print(f"  Median:    {df['height_mm'].median():.2f} mm")
    print(f"  Std Dev:   {df['height_mm'].std():.2f} mm")
    
    print(f"\n🎯 Confidence Statistics:")
    print(f"  Mean:      {df['confidence'].mean():.1%}")
    print(f"  Min:       {df['confidence'].min():.1%}")
    print(f"  Max:       {df['confidence'].max():.1%}")
    
    # Create output directory
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Save raw data
    csv_file = output_dir / f"tooth_width_analysis_{datetime.now().strftime('%Y%m%d')}.csv"
    df.to_csv(csv_file, index=False)
    print(f"\n✓ CSV saved: {csv_file}")
    
    # Save to Excel with multiple sheets
    excel_file = output_dir / f"tooth_width_report_{datetime.now().strftime('%Y%m%d')}.xlsx"
    with pd.ExcelWriter(excel_file, engine='openpyxl') as writer:
        df.to_excel(writer, sheet_name='Raw Data', index=False)
        df.describe().to_excel(writer, sheet_name='Statistics')
        df.groupby('patient')['width_mm'].agg(['mean', 'std', 'count']).to_excel(
            writer, sheet_name='Per Patient'
        )
    print(f"✓ Excel saved: {excel_file}")
    
    # Create visualizations
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    fig.suptitle('DenteScope AI - Tooth Width Analysis', fontsize=16, fontweight='bold')
    
    # Histogram
    axes[0, 0].hist(df['width_mm'], bins=20, color='skyblue', edgecolor='black', alpha=0.7)
    axes[0, 0].axvline(df['width_mm'].mean(), color='red', linestyle='--', linewidth=2,
                       label=f'Mean: {df["width_mm"].mean():.1f}mm')
    axes[0, 0].set_xlabel('Width (mm)', fontsize=12)
    axes[0, 0].set_ylabel('Frequency', fontsize=12)
    axes[0, 0].set_title('Width Distribution', fontsize=14, fontweight='bold')
    axes[0, 0].legend()
    axes[0, 0].grid(alpha=0.3)
    
    # Bar chart - Per Patient
    patient_means = df.groupby('patient')['width_mm'].mean().sort_values()
    axes[0, 1].barh(range(len(patient_means)), patient_means.values, color='green', alpha=0.6)
    axes[0, 1].set_yticks(range(len(patient_means)))
    axes[0, 1].set_yticklabels([p[:20] for p in patient_means.index], fontsize=8)
    axes[0, 1].set_xlabel('Width (mm)', fontsize=12)
    axes[0, 1].set_title('Per-Patient Width Measurements', fontsize=14, fontweight='bold')
    axes[0, 1].grid(axis='x', alpha=0.3)
    
    # Scatter - Width vs Confidence
    axes[1, 0].scatter(df['width_mm'], df['confidence'], alpha=0.6, s=100, c='purple')
    axes[1, 0].set_xlabel('Width (mm)', fontsize=12)
    axes[1, 0].set_ylabel('Confidence', fontsize=12)
    axes[1, 0].set_title('Width vs Detection Confidence', fontsize=14, fontweight='bold')
    axes[1, 0].grid(alpha=0.3)
    
    # Box plot
    axes[1, 1].boxplot([df['width_mm']], vert=True, labels=['Width'])
    axes[1, 1].set_ylabel('Width (mm)', fontsize=12)
    axes[1, 1].set_title('Width Distribution (Box Plot)', fontsize=14, fontweight='bold')
    axes[1, 1].grid(alpha=0.3)
    
    plt.tight_layout()
    viz_file = output_dir / f"tooth_width_visualizations_{datetime.now().strftime('%Y%m%d')}.png"
    plt.savefig(viz_file, dpi=300, bbox_inches='tight')
    print(f"✓ Visualizations saved: {viz_file}")
    
    print("\n" + "=" * 70)
    print("✅ Analysis complete!")
    print("=" * 70)
    
    return df

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description='Analyze tooth widths from dental X-rays')
    parser.add_argument('--model', required=True, help='Path to trained YOLO model')
    parser.add_argument('--images', required=True, help='Directory containing X-ray images')
    parser.add_argument('--output', default='width_analysis_results', help='Output directory')
    parser.add_argument('--calibration', type=float, default=0.1, help='Pixels to mm factor')
    
    args = parser.parse_args()
    
    analyze_tooth_widths(args.model, args.images, args.output, args.calibration)
