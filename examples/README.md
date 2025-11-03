# DenteScope AI - Examples

Collection of example scripts and notebooks for using DenteScope AI.

## 📝 Scripts

### 1. Batch Processing

**Script:** `batch_process.py`

Process multiple dental X-rays efficiently with CSV/Excel/JSON output.

```bash
# Basic usage
python examples/batch_process.py --input data/valid/images

# Custom model and output
python examples/batch_process.py \
  --model runs/train/tooth_detection3/weights/best.pt \
  --input data/test/images \
  --output results/batch_nov3

# Adjust confidence threshold
python examples/batch_process.py \
  --input data/images \
  --conf 0.5

# Skip saving annotated images (faster)
python examples/batch_process.py \
  --input data/images \
  --no-save-images
```

**Output:**
- `batch_results.csv` - Raw measurements
- `batch_results.xlsx` - Excel with statistics
- `batch_results.json` - JSON format
- `images/annotated_*.jpg` - Annotated images

---

### 2. Model Comparison

**Script:** `compare_models.py`

Compare performance of different model versions on the same test set.

```bash
# Compare two models
python examples/compare_models.py \
  --models \
    runs/train/tooth_detection3/weights/best.pt \
    runs/train/tooth_detection7/weights/best.pt \
  --test-images data/valid/images

# Custom output directory
python examples/compare_models.py \
  --models model1.pt model2.pt model3.pt \
  --test-images data/test \
  --output results/comparison_nov3
```

**Output:**
- `model_comparison.csv` - Detailed comparison data
- `model_comparison.png` - Comparison plots
- Console output with summary statistics

---

## 📓 Jupyter Notebooks

### Coming Soon

- `width_analysis_demo.ipynb` - Interactive width analysis
- `pathology_detection_demo.ipynb` - Pathology detection (when available)
- `model_training_tutorial.ipynb` - Step-by-step training guide
- `data_augmentation.ipynb` - Data augmentation techniques

---

## 🛠️ Utility Scripts

### Image Preprocessing

```python
# Resize images
from PIL import Image
from pathlib import Path

def resize_images(input_dir, output_dir, size=(640, 640)):
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    for img_path in Path(input_dir).glob("*.jpg"):
        img = Image.open(img_path)
        img_resized = img.resize(size)
        img_resized.save(Path(output_dir) / img_path.name)

resize_images("data/raw", "data/processed")
```

### Extract Patient Info

```python
# Extract patient info from filename
import re

def parse_filename(filename):
    # Example: "JOHN_DOE_10_YRS_MALE_DR_SMITH_2025_01_15.jpg"
    match = re.match(
        r"([A-Z_]+)_(\d+)_YRS_([A-Z]+)_DR_([A-Z_]+)_(\d{4})_(\d{2})_(\d{2})",
        filename
    )
    
    if match:
        return {
            "patient": match.group(1).replace("_", " "),
            "age": int(match.group(2)),
            "gender": match.group(3),
            "doctor": match.group(4).replace("_", " "),
            "date": f"{match.group(5)}-{match.group(6)}-{match.group(7)}"
        }
    return None

info = parse_filename("JOHN_DOE_10_YRS_MALE_DR_SMITH_2025_01_15.jpg")
print(info)
# {'patient': 'JOHN DOE', 'age': 10, 'gender': 'MALE', ...}
```

---

## 📊 Analysis Examples

### Statistical Analysis

```python
import pandas as pd
import numpy as np

# Load results
df = pd.read_csv("results/batch_results.csv")

# Summary statistics
print(df['width_mm'].describe())

# Calculate percentiles
percentiles = np.percentile(df['width_mm'], [25, 50, 75])
print(f"25th percentile: {percentiles[0]:.1f}mm")
print(f"Median: {percentiles[1]:.1f}mm")
print(f"75th percentile: {percentiles[2]:.1f}mm")

# Group by patient
by_patient = df.groupby('patient')['width_mm'].agg(['mean', 'std', 'count'])
print(by_patient)
```

### Visualization

```python
import matplotlib.pyplot as plt
import seaborn as sns

# Load results
df = pd.read_csv("results/batch_results.csv")

# Create plots
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Histogram
axes[0, 0].hist(df['width_mm'], bins=20, edgecolor='black')
axes[0, 0].set_title('Width Distribution')
axes[0, 0].set_xlabel('Width (mm)')

# Box plot
axes[0, 1].boxplot(df['width_mm'])
axes[0, 1].set_title('Width Box Plot')
axes[0, 1].set_ylabel('Width (mm)')

# Confidence scatter
axes[1, 0].scatter(df['width_mm'], df['confidence'])
axes[1, 0].set_title('Width vs Confidence')
axes[1, 0].set_xlabel('Width (mm)')
axes[1, 0].set_ylabel('Confidence')

# By patient
by_patient = df.groupby('patient')['width_mm'].mean().sort_values()
axes[1, 1].barh(range(len(by_patient)), by_patient.values)
axes[1, 1].set_yticks(range(len(by_patient)))
axes[1, 1].set_yticklabels(by_patient.index)
axes[1, 1].set_title('Average Width by Patient')
axes[1, 1].set_xlabel('Width (mm)')

plt.tight_layout()
plt.savefig('width_analysis.png', dpi=300)
plt.show()
```

---

## 🚀 Quick Start

1. **Install dependencies:**
```bash
pip install ultralytics pandas matplotlib seaborn openpyxl tqdm
```

2. **Run batch processing:**
```bash
python examples/batch_process.py --input data/valid/images
```

3. **Compare models:**
```bash
python examples/compare_models.py \
  --models runs/train/*/weights/best.pt \
  --test-images data/test/images
```

---

## 📚 Additional Resources

- [Main README](../README.md)
- [Training Guide](../TRAINING_GUIDE.md)
- [Width Analysis Guide](../docs/WIDTH_ANALYSIS_GUIDE.md)
- [API Documentation](../docs/API_DOCUMENTATION.md) (coming soon)

---

**Need Help?**
- GitHub Issues: [Report a bug](https://github.com/ajeetraina/dentescope-ai-complete/issues)
- Email: ajeet.raina@docker.com
