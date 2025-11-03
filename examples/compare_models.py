#!/usr/bin/env python3
"""
DenteScope AI - Model Comparison Script
Compare performance of different model versions

Author: Ajeet Singh Raina
Date: November 3, 2025
"""

import argparse
from pathlib import Path
import pandas as pd
from ultralytics import YOLO
import matplotlib.pyplot as plt
import seaborn as sns
from tqdm import tqdm


def compare_models(model_paths: list, test_images: str, output_dir: str):
    """
    Compare multiple models on the same test set.
    
    Args:
        model_paths: List of paths to model weights
        test_images: Directory containing test images
        output_dir: Directory for comparison results
    """
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    # Load all models
    models = {}
    for model_path in model_paths:
        model_name = Path(model_path).parent.parent.name
        print(f"📦 Loading {model_name}: {model_path}")
        models[model_name] = YOLO(model_path)
    
    # Find test images
    test_path = Path(test_images)
    image_files = list(test_path.glob("*.jpg")) + list(test_path.glob("*.png"))
    print(f"📸 Found {len(image_files)} test images\n")
    
    # Compare models
    comparison_data = []
    
    for img_path in tqdm(image_files, desc="Testing"):
        for model_name, model in models.items():
            # Run inference
            results = model(str(img_path), verbose=False)
            
            # Extract metrics
            num_detections = len(results[0].boxes)
            avg_conf = 0
            avg_width = 0
            
            if num_detections > 0:
                confidences = [box.conf[0].item() for box in results[0].boxes]
                widths = [box.xyxy[0][2].item() - box.xyxy[0][0].item() 
                         for box in results[0].boxes]
                
                avg_conf = sum(confidences) / len(confidences)
                avg_width = sum(widths) / len(widths)
            
            comparison_data.append({
                "model": model_name,
                "image": img_path.name,
                "detections": num_detections,
                "avg_confidence": avg_conf,
                "avg_width_px": avg_width
            })
    
    # Create DataFrame
    df = pd.DataFrame(comparison_data)
    
    # Save results
    csv_path = output_path / "model_comparison.csv"
    df.to_csv(csv_path, index=False)
    print(f"\n📊 Results saved: {csv_path}")
    
    # Generate comparison plots
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    
    # 1. Detection rate
    detection_rate = df.groupby('model')['detections'].apply(
        lambda x: (x > 0).sum() / len(x) * 100
    )
    axes[0, 0].bar(detection_rate.index, detection_rate.values)
    axes[0, 0].set_title('Detection Rate by Model')
    axes[0, 0].set_ylabel('Detection Rate (%)')
    axes[0, 0].set_ylim(0, 100)
    
    # 2. Average confidence
    df_conf = df[df['detections'] > 0]
    sns.boxplot(data=df_conf, x='model', y='avg_confidence', ax=axes[0, 1])
    axes[0, 1].set_title('Confidence Distribution')
    axes[0, 1].set_ylabel('Confidence')
    
    # 3. Average width
    sns.violinplot(data=df_conf, x='model', y='avg_width_px', ax=axes[1, 0])
    axes[1, 0].set_title('Width Distribution')
    axes[1, 0].set_ylabel('Width (pixels)')
    
    # 4. Summary table
    summary = df.groupby('model').agg({
        'detections': ['mean', 'std'],
        'avg_confidence': ['mean', 'std'],
        'avg_width_px': ['mean', 'std']
    }).round(2)
    
    axes[1, 1].axis('off')
    table = axes[1, 1].table(cellText=summary.values,
                             rowLabels=summary.index,
                             colLabels=[f"{col[0]}\n{col[1]}" for col in summary.columns],
                             cellLoc='center',
                             loc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(9)
    table.scale(1, 2)
    axes[1, 1].set_title('Summary Statistics')
    
    plt.tight_layout()
    plot_path = output_path / "model_comparison.png"
    plt.savefig(plot_path, dpi=300, bbox_inches='tight')
    print(f"📈 Plot saved: {plot_path}")
    
    # Print summary
    print(f"\n🎯 Model Comparison Summary:")
    print("="*60)
    for model_name in models.keys():
        model_df = df[df['model'] == model_name]
        detected_df = model_df[model_df['detections'] > 0]
        
        print(f"\n{model_name}:")
        print(f"  Detection Rate: {len(detected_df)/len(model_df)*100:.1f}%")
        if len(detected_df) > 0:
            print(f"  Avg Confidence: {detected_df['avg_confidence'].mean():.1%}")
            print(f"  Avg Width: {detected_df['avg_width_px'].mean():.1f}px")


def main():
    parser = argparse.ArgumentParser(
        description="DenteScope AI - Model Comparison"
    )
    parser.add_argument(
        "--models",
        nargs="+",
        required=True,
        help="Paths to model weights to compare"
    )
    parser.add_argument(
        "--test-images",
        type=str,
        required=True,
        help="Directory with test images"
    )
    parser.add_argument(
        "--output",
        type=str,
        default="results/comparison",
        help="Output directory"
    )
    
    args = parser.parse_args()
    
    print("="*60)
    print("🔬 DenteScope AI - Model Comparison")
    print("="*60)
    
    compare_models(
        model_paths=args.models,
        test_images=args.test_images,
        output_dir=args.output
    )
    
    print("\n✅ Comparison complete!")


if __name__ == "__main__":
    main()
