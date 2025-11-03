# DenteScope AI - Tooth Width Analysis

## Overview
Automated tooth width measurement system using YOLOv8 detection and pixel-to-millimeter conversion.

## Features
- Automated bounding box detection
- Width & height measurements
- Statistical analysis
- Excel & CSV export
- Visualization generation

## Quick Start
```bash
# Run complete analysis
python analyze_tooth_widths.py \
  --model ../runs/train/tooth_detection3/weights/best.pt \
  --images ../data/valid/images \
  --output results

# View results
ls results/
# → tooth_width_analysis_YYYYMMDD.csv
# → tooth_width_report_YYYYMMDD.xlsx
# → tooth_width_visualizations_YYYYMMDD.png
```

## Output Files
1. **CSV**: Raw measurements (patient, width, height, confidence)
2. **Excel**: Multi-sheet report (data, statistics, per-patient)
3. **PNG**: 4-panel visualization (histogram, bar chart, scatter, boxplot)

## Calibration
Default: `0.1` pixels/mm

To customize:
```bash
python analyze_tooth_widths.py \
  --model MODEL_PATH \
  --images IMAGE_DIR \
  --calibration 0.15  # Adjust based on your X-ray scale
```

## Results (October 31, 2025)
- Patients analyzed: 13
- Mean width: 165.7mm (± 0.5mm)
- Consistency: Excellent (σ = 0.5mm)
- Detection rate: 100%

## Documentation
- [Training Report](../docs/training-history/OCT_30_31_2025_TRAINING.md)
- [Model Registry](../docs/models/MODEL_REGISTRY.md)
