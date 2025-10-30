#!/usr/bin/env python3
"""
DenteScope AI - Batch Testing Script
Tests all dental X-ray images from the dataset repository
"""

import os
import sys
import json
import time
import requests
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any
import subprocess
import urllib.request

class DenteScopeBatchTester:
    """Batch testing for DenteScope AI system"""
    
    def __init__(self, api_url="http://localhost:8000"):
        self.api_url = api_url
        self.dataset_repo = "https://github.com/ajeetraina/dentescope-ai"
        self.samples_path = "data/samples"
        self.test_dir = Path("./test_results")
        self.images_dir = self.test_dir / "images"
        self.results_dir = self.test_dir / "results"
        
        # Create directories
        self.test_dir.mkdir(exist_ok=True)
        self.images_dir.mkdir(exist_ok=True)
        self.results_dir.mkdir(exist_ok=True)
        
        self.results = {
            "test_info": {
                "start_time": datetime.now().isoformat(),
                "api_url": self.api_url,
                "dataset_source": self.dataset_repo
            },
            "images": [],
            "summary": {
                "total": 0,
                "success": 0,
                "failed": 0,
                "total_time": 0,
                "avg_time_per_image": 0
            }
        }
    
    def download_dataset(self):
        """Download sample images from GitHub repository"""
        print("🔽 Downloading dataset from GitHub...")
        print(f"   Repository: {self.dataset_repo}")
        
        # GitHub API URL for the samples directory
        api_url = "https://api.github.com/repos/ajeetraina/dentescope-ai/contents/data/samples"
        
        try:
            response = requests.get(api_url)
            response.raise_for_status()
            files = response.json()
            
            # Filter only image files
            image_files = [
                f for f in files 
                if f["type"] == "file" and 
                f["name"].lower().endswith((".jpg", ".jpeg", ".png", ".tif", ".tiff"))
            ]
            
            print(f"   Found {len(image_files)} images to download")
            
            downloaded = 0
            for file_info in image_files:
                filename = file_info["name"]
                download_url = file_info["download_url"]
                local_path = self.images_dir / filename
                
                # Skip if already downloaded
                if local_path.exists():
                    print(f"   ⏭️  Skipping (already exists): {filename}")
                    downloaded += 1
                    continue
                
                try:
                    print(f"   ⬇️  Downloading: {filename}... ", end="", flush=True)
                    urllib.request.urlretrieve(download_url, local_path)
                    print("✅")
                    downloaded += 1
                except Exception as e:
                    print(f"❌ Error: {e}")
            
            print(f"
✅ Downloaded {downloaded}/{len(image_files)} images")
            return downloaded
            
        except Exception as e:
            print(f"❌ Error downloading dataset: {e}")
            return 0
    
    def check_api_health(self) -> bool:
        """Check if the DenteScope API is available"""
        try:
            response = requests.get(f"{self.api_url}/health", timeout=5)
            return response.status_code == 200
        except:
            return False
    
    def process_image(self, image_path: Path) -> Dict[str, Any]:
        """Process a single image through the DenteScope API"""
        start_time = time.time()
        
        result = {
            "filename": image_path.name,
            "path": str(image_path),
            "status": "pending",
            "start_time": datetime.now().isoformat(),
            "processing_time": 0,
            "error": None,
            "analysis": None
        }
        
        try:
            # Prepare the image file for upload
            with open(image_path, "rb") as f:
                files = {"file": (image_path.name, f, "image/jpeg")}
                
                # Call the DenteScope API
                response = requests.post(
                    f"{self.api_url}/analyze",
                    files=files,
                    timeout=120  # 2 minute timeout for complex processing
                )
                
                if response.status_code == 200:
                    result["status"] = "success"
                    result["analysis"] = response.json()
                else:
                    result["status"] = "failed"
                    result["error"] = f"API returned status {response.status_code}"
                    
        except Exception as e:
            result["status"] = "failed"
            result["error"] = str(e)
        
        result["processing_time"] = time.time() - start_time
        result["end_time"] = datetime.now().isoformat()
        
        return result
    
    def run_batch_test(self):
        """Run batch processing on all images"""
        print("
" + "="*80)
        print("🦷 DenteScope AI - Batch Testing")
        print("="*80)
        
        # Check API health
        print("
1️⃣  Checking API availability...")
        if not self.check_api_health():
            print("❌ DenteScope API is not available at", self.api_url)
            print("   Please ensure the backend is running:")
            print("   docker-compose -f docker-compose.jetson.yml up -d")
            return
        print("✅ API is available")
        
        # Download dataset
        print("
2️⃣  Preparing dataset...")
        num_downloaded = self.download_dataset()
        
        if num_downloaded == 0:
            print("❌ No images available for testing")
            return
        
        # Get all image files
        image_files = sorted([
            f for f in self.images_dir.iterdir()
            if f.suffix.lower() in [".jpg", ".jpeg", ".png", ".tif", ".tiff"]
        ])
        
        total_images = len(image_files)
        self.results["summary"]["total"] = total_images
        
        print(f"
3️⃣  Processing {total_images} images...")
        print("="*80)
        
        # Process each image
        for idx, image_path in enumerate(image_files, 1):
            print(f"
[{idx}/{total_images}] Processing: {image_path.name}")
            print("-" * 80)
            
            result = self.process_image(image_path)
            self.results["images"].append(result)
            
            if result["status"] == "success":
                self.results["summary"]["success"] += 1
                print(f"✅ Success - {result[\"processing_time\"]:.2f}s")
                
                # Print brief analysis summary if available
                if result["analysis"]:
                    analysis = result["analysis"]
                    if "tooth_count" in analysis:
                        print(f"   Teeth detected: {analysis[\"tooth_count\"]}")
                    if "conditions" in analysis:
                        print(f"   Conditions: {\", \".join(analysis[\"conditions\"][:3])}")
            else:
                self.results["summary"]["failed"] += 1
                print(f"❌ Failed - {result[\"error\"]}")
            
            # Save intermediate results
            self.save_results()
        
        # Calculate final statistics
        total_time = sum(r["processing_time"] for r in self.results["images"])
        self.results["summary"]["total_time"] = total_time
        self.results["summary"]["avg_time_per_image"] = (
            total_time / total_images if total_images > 0 else 0
        )
        self.results["test_info"]["end_time"] = datetime.now().isoformat()
        
        # Final save
        self.save_results()
        self.print_summary()
    
    def save_results(self):
        """Save test results to JSON file"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        results_file = self.results_dir / f"batch_test_results_{timestamp}.json"
        
        with open(results_file, "w") as f:
            json.dump(self.results, f, indent=2)
    
    def print_summary(self):
        """Print test summary"""
        print("
" + "="*80)
        print("📊 TEST SUMMARY")
        print("="*80)
        
        summary = self.results["summary"]
        
        print(f"
📈 Overall Statistics:")
        print(f"   Total Images:    {summary[\"total\"]}")
        print(f"   ✅ Successful:   {summary[\"success\"]}")
        print(f"   ❌ Failed:       {summary[\"failed\"]}")
        print(f"   Success Rate:    {(summary[\"success\"]/summary[\"total\"]*100):.1f}%")
        
        print(f"
⏱️  Performance Metrics:")
        print(f"   Total Time:      {summary[\"total_time\"]:.2f}s")
        print(f"   Avg Time/Image:  {summary[\"avg_time_per_image\"]:.2f}s")
        
        if summary["success"] > 0:
            successful_times = [
                r["processing_time"] for r in self.results["images"]
                if r["status"] == "success"
            ]
            print(f"   Fastest:         {min(successful_times):.2f}s")
            print(f"   Slowest:         {max(successful_times):.2f}s")
        
        print(f"
📁 Results saved to:")
        print(f"   {self.results_dir}/")
        
        print("
" + "="*80)

def main():
    """Main entry point"""
    # Parse command line arguments
    api_url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8000"
    
    # Create tester and run
    tester = DenteScopeBatchTester(api_url=api_url)
    tester.run_batch_test()

if __name__ == "__main__":
    main()

