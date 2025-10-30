#!/usr/bin/env python3
"""
Download sample dental images from dentescope-ai repository
"""

import os
import requests
from pathlib import Path
from tqdm import tqdm

# GitHub repository information
REPO_OWNER = "ajeetraina"
REPO_NAME = "dentescope-ai"
SAMPLES_PATH = "data/samples"
API_URL = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/contents/{SAMPLES_PATH}"

def download_samples(output_dir="./data/raw"):
    """
    Download all sample dental images from the repository
    """
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)
    
    print("=" * 60)
    print("Downloading Sample Dental Images")
    print("=" * 60)
    
    # Get list of files from GitHub API
    print(f"\n📡 Fetching file list from {REPO_NAME}...")
    response = requests.get(API_URL)
    response.raise_for_status()
    
    files = response.json()
    
    # Filter only image files
    image_extensions = {'.jpg', '.jpeg', '.png', '.tif', '.tiff'}
    image_files = [f for f in files if Path(f['name']).suffix.lower() in image_extensions]
    
    print(f"✓ Found {len(image_files)} dental images")
    
    # Download each file
    print(f"\n📥 Downloading images to {output_path}...")
    for file_info in tqdm(image_files, desc="Downloading"):
        file_name = file_info['name']
        download_url = file_info['download_url']
        
        file_path = output_path / file_name
        
        # Skip if already downloaded
        if file_path.exists():
            continue
        
        # Download file
        try:
            response = requests.get(download_url)
            response.raise_for_status()
            
            with open(file_path, 'wb') as f:
                f.write(response.content)
        except Exception as e:
            print(f"⚠️  Error downloading {file_name}: {e}")
    
    print(f"\n✅ Download complete!")
    print(f"   Downloaded {len(image_files)} images to {output_path}")
    print(f"   Total patients: 79")
    
    return output_path

if __name__ == "__main__":
    download_samples()
