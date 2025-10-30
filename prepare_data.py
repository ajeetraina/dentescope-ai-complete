#!/usr/bin/env python3
"""
Prepare dataset for YOLO training
Organize images and create data.yaml
"""

import os
import shutil
from pathlib import Path
import random

def prepare_dataset(
    images_dir='./images',
    output_dir='./dataset',
    train_split=0.8,
    val_split=0.1,
    test_split=0.1
):
    """
    Organize images into YOLO format:
    dataset/
      ├── images/
      │   ├── train/
      │   ├── val/
      │   └── test/
      └── labels/
          ├── train/
          ├── val/
          └── test/
    """
    
    # Create directories
    for split in ['train', 'val', 'test']:
        Path(f'{output_dir}/images/{split}').mkdir(parents=True, exist_ok=True)
        Path(f'{output_dir}/labels/{split}').mkdir(parents=True, exist_ok=True)
    
    # Get all images
    image_files = []
    for ext in ['*.jpg', '*.jpeg', '*.png', '*.JPG', '*.JPEG', '*.PNG']:
        image_files.extend(list(Path(images_dir).glob(ext)))
    
    print(f"Found {len(image_files)} images")
    
    # Shuffle
    random.shuffle(image_files)
    
    # Split
    n_train = int(len(image_files) * train_split)
    n_val = int(len(image_files) * val_split)
    
    train_files = image_files[:n_train]
    val_files = image_files[n_train:n_train+n_val]
    test_files = image_files[n_train+n_val:]
    
    print(f"Train: {len(train_files)}, Val: {len(val_files)}, Test: {len(test_files)}")
    
    # Copy files
    for files, split in [(train_files, 'train'), (val_files, 'val'), (test_files, 'test')]:
        for img_file in files:
            # Copy image
            dst_img = f'{output_dir}/images/{split}/{img_file.name}'
            shutil.copy(img_file, dst_img)
            
            # Copy label if exists
            label_file = img_file.with_suffix('.txt')
            if label_file.exists():
                dst_label = f'{output_dir}/labels/{split}/{label_file.name}'
                shutil.copy(label_file, dst_label)
    
    # Create data.yaml
    yaml_content = f"""# Dataset configuration
path: {os.path.abspath(output_dir)}
train: images/train
val: images/val
test: images/test

# Classes
nc: 1
names: ['tooth']
"""
    
    with open(f'{output_dir}/data.yaml', 'w') as f:
        f.write(yaml_content)
    
    print(f"\n✅ Dataset prepared in: {output_dir}")
    print(f"✅ Configuration: {output_dir}/data.yaml")
    
    return output_dir

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser()
    parser.add_argument('--images', default='./images', help='Images directory')
    parser.add_argument('--output', default='./dataset', help='Output directory')
    parser.add_argument('--train', type=float, default=0.8, help='Train split ratio')
    parser.add_argument('--val', type=float, default=0.1, help='Val split ratio')
    
    args = parser.parse_args()
    
    prepare_dataset(
        images_dir=args.images,
        output_dir=args.output,
        train_split=args.train,
        val_split=args.val,
        test_split=1.0 - args.train - args.val
    )