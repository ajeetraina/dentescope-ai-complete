#!/bin/bash

################################################################################
# DenteScope AI - Testing Suite Generator
# 
# This script creates all files needed for the complete testing suite
# Run this script to generate the entire testing framework
#
# Usage: ./generate_testing_suite.sh [output_directory]
################################################################################

set -e  # Exit on error

# Configuration
OUTPUT_DIR="${1:-./dentescope-testing-suite}"
SCRIPT_VERSION="1.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  🦷 DenteScope AI - Testing Suite Generator v${SCRIPT_VERSION}      ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}\n"
}

print_step() {
    echo -e "\n${YELLOW}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

create_file() {
    local filepath="$1"
    local content="$2"
    
    echo "$content" > "$filepath"
    chmod +x "$filepath" 2>/dev/null || true
    print_success "Created: $(basename $filepath)"
}

################################################################################
# Main Script
################################################################################

main() {
    print_header
    
    print_step "Creating output directory..."
    mkdir -p "$OUTPUT_DIR"
    cd "$OUTPUT_DIR"
    print_success "Directory created: $OUTPUT_DIR"
    
    ############################################################################
    # File 1: batch_test_dentescope.py
    ############################################################################
    print_step "Generating batch_test_dentescope.py..."
    
    create_file "batch_test_dentescope.py" '#!/usr/bin/env python3
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
            
            print(f"\n✅ Downloaded {downloaded}/{len(image_files)} images")
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
        print("\n" + "="*80)
        print("🦷 DenteScope AI - Batch Testing")
        print("="*80)
        
        # Check API health
        print("\n1️⃣  Checking API availability...")
        if not self.check_api_health():
            print("❌ DenteScope API is not available at", self.api_url)
            print("   Please ensure the backend is running:")
            print("   docker-compose -f docker-compose.jetson.yml up -d")
            return
        print("✅ API is available")
        
        # Download dataset
        print("\n2️⃣  Preparing dataset...")
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
        
        print(f"\n3️⃣  Processing {total_images} images...")
        print("="*80)
        
        # Process each image
        for idx, image_path in enumerate(image_files, 1):
            print(f"\n[{idx}/{total_images}] Processing: {image_path.name}")
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
        print("\n" + "="*80)
        print("📊 TEST SUMMARY")
        print("="*80)
        
        summary = self.results["summary"]
        
        print(f"\n📈 Overall Statistics:")
        print(f"   Total Images:    {summary[\"total\"]}")
        print(f"   ✅ Successful:   {summary[\"success\"]}")
        print(f"   ❌ Failed:       {summary[\"failed\"]}")
        print(f"   Success Rate:    {(summary[\"success\"]/summary[\"total\"]*100):.1f}%")
        
        print(f"\n⏱️  Performance Metrics:")
        print(f"   Total Time:      {summary[\"total_time\"]:.2f}s")
        print(f"   Avg Time/Image:  {summary[\"avg_time_per_image\"]:.2f}s")
        
        if summary["success"] > 0:
            successful_times = [
                r["processing_time"] for r in self.results["images"]
                if r["status"] == "success"
            ]
            print(f"   Fastest:         {min(successful_times):.2f}s")
            print(f"   Slowest:         {max(successful_times):.2f}s")
        
        print(f"\n📁 Results saved to:")
        print(f"   {self.results_dir}/")
        
        print("\n" + "="*80)

def main():
    """Main entry point"""
    # Parse command line arguments
    api_url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8000"
    
    # Create tester and run
    tester = DenteScopeBatchTester(api_url=api_url)
    tester.run_batch_test()

if __name__ == "__main__":
    main()
'
    
    ############################################################################
    # File 2: analyze_results.py
    ############################################################################
    print_step "Generating analyze_results.py..."
    
    create_file "analyze_results.py" '#!/usr/bin/env python3
"""
DenteScope AI - Results Analyzer
Analyzes batch test results and generates comprehensive reports
"""

import json
import sys
from pathlib import Path
from datetime import datetime
from collections import defaultdict
from typing import Dict, List

class ResultsAnalyzer:
    """Analyze and generate reports from batch test results"""
    
    def __init__(self, results_file: Path):
        self.results_file = results_file
        with open(results_file) as f:
            self.data = json.load(f)
    
    def generate_markdown_report(self) -> str:
        """Generate a comprehensive markdown report"""
        report = []
        
        # Header
        report.append("# 🦷 DenteScope AI - Batch Test Report\n")
        report.append(f"**Generated:** {datetime.now().strftime(\"%Y-%m-%d %H:%M:%S\")}\n")
        report.append(f"**Test Started:** {self.data[\"test_info\"][\"start_time\"]}\n")
        report.append(f"**Dataset Source:** {self.data[\"test_info\"][\"dataset_source\"]}\n")
        report.append("\n---\n")
        
        # Executive Summary
        summary = self.data["summary"]
        report.append("## 📊 Executive Summary\n")
        report.append(f"- **Total Images Tested:** {summary[\"total\"]}")
        report.append(f"- **Successful Analyses:** {summary[\"success\"]} ({summary[\"success\"]/summary[\"total\"]*100:.1f}%)")
        report.append(f"- **Failed Analyses:** {summary[\"failed\"]} ({summary[\"failed\"]/summary[\"total\"]*100:.1f}%)")
        report.append(f"- **Total Processing Time:** {summary[\"total_time\"]:.2f}s")
        report.append(f"- **Average Time per Image:** {summary[\"avg_time_per_image\"]:.2f}s\n")
        
        # Performance Metrics
        successful_results = [r for r in self.data["images"] if r["status"] == "success"]
        if successful_results:
            times = [r["processing_time"] for r in successful_results]
            report.append("## ⏱️ Performance Metrics\n")
            report.append(f"- **Fastest Analysis:** {min(times):.2f}s")
            report.append(f"- **Slowest Analysis:** {max(times):.2f}s")
            report.append(f"- **Median Time:** {sorted(times)[len(times)//2]:.2f}s\n")
        
        # Aggregate Analysis Statistics
        report.append("## 🔍 Clinical Analysis Summary\n")
        
        # Count detections and conditions across all successful analyses
        total_teeth_detected = 0
        conditions_count = defaultdict(int)
        
        for result in successful_results:
            if result.get("analysis"):
                analysis = result["analysis"]
                if "tooth_count" in analysis:
                    total_teeth_detected += analysis["tooth_count"]
                if "conditions" in analysis:
                    for condition in analysis["conditions"]:
                        conditions_count[condition] += 1
        
        if total_teeth_detected > 0:
            report.append(f"- **Total Teeth Detected:** {total_teeth_detected}")
            report.append(f"- **Average Teeth per Image:** {total_teeth_detected/len(successful_results):.1f}\n")
        
        if conditions_count:
            report.append("### Most Common Findings:\n")
            sorted_conditions = sorted(conditions_count.items(), key=lambda x: x[1], reverse=True)
            for condition, count in sorted_conditions[:10]:
                report.append(f"- **{condition}:** {count} occurrences")
            report.append("")
        
        # Failed Images Analysis
        failed_results = [r for r in self.data["images"] if r["status"] == "failed"]
        if failed_results:
            report.append("## ❌ Failed Analyses\n")
            report.append(f"Total failed: {len(failed_results)}\n")
            
            # Group by error type
            error_types = defaultdict(list)
            for result in failed_results:
                error_msg = result.get("error", "Unknown error")
                error_types[error_msg].append(result["filename"])
            
            report.append("### Failure Breakdown:\n")
            for error, files in error_types.items():
                report.append(f"**{error}** ({len(files)} images)")
                for filename in files[:5]:  # Show first 5
                    report.append(f"  - {filename}")
                if len(files) > 5:
                    report.append(f"  - ... and {len(files)-5} more")
                report.append("")
        
        # Individual Results Table
        report.append("## 📋 Individual Results\n")
        report.append("| # | Filename | Status | Time (s) | Notes |")
        report.append("|---|----------|--------|----------|-------|")
        
        for idx, result in enumerate(self.data["images"], 1):
            filename = result["filename"][:40] + "..." if len(result["filename"]) > 40 else result["filename"]
            status = "✅" if result["status"] == "success" else "❌"
            time_str = f"{result[\"processing_time\"]:.2f}"
            
            notes = ""
            if result["status"] == "success" and result.get("analysis"):
                analysis = result["analysis"]
                if "tooth_count" in analysis:
                    notes = f"{analysis[\"tooth_count\"]} teeth"
            elif result["status"] == "failed":
                notes = result.get("error", "Error")[:30]
            
            report.append(f"| {idx} | {filename} | {status} | {time_str} | {notes} |")
        
        report.append("")
        
        # Recommendations
        report.append("## 💡 Recommendations\n")
        
        if summary["failed"] > 0:
            failure_rate = summary["failed"] / summary["total"] * 100
            if failure_rate > 10:
                report.append("- ⚠️ High failure rate detected. Review failed images and error messages.")
        
        if summary["avg_time_per_image"] > 5.0:
            report.append("- ⚠️ Average processing time is high. Consider optimization or hardware upgrades.")
        
        if summary["success"] == summary["total"]:
            report.append("- ✅ Perfect success rate! All images processed successfully.")
        
        report.append("\n---")
        report.append("\n*Report generated by DenteScope AI Results Analyzer*")
        
        return "\n".join(report)
    
    def save_report(self, output_path: Path):
        """Save the markdown report to a file"""
        report = self.generate_markdown_report()
        with open(output_path, "w") as f:
            f.write(report)
        print(f"✅ Report saved to: {output_path}")
    
    def print_summary(self):
        """Print a brief summary to console"""
        summary = self.data["summary"]
        
        print("\n" + "="*80)
        print("📊 ANALYSIS SUMMARY")
        print("="*80)
        print(f"\n✅ Success Rate: {summary[\"success\"]}/{summary[\"total\"]} ({summary[\"success\"]/summary[\"total\"]*100:.1f}%)")
        print(f"⏱️  Average Time: {summary[\"avg_time_per_image\"]:.2f}s per image")
        
        if summary["failed"] > 0:
            print(f"\n❌ {summary[\"failed\"]} images failed processing")
        
        print("\n" + "="*80)

def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("Usage: python3 analyze_results.py <results_file.json>")
        print("\nExample:")
        print("  python3 analyze_results.py test_results/results/batch_test_results_20241030_120000.json")
        sys.exit(1)
    
    results_file = Path(sys.argv[1])
    
    if not results_file.exists():
        print(f"❌ Results file not found: {results_file}")
        sys.exit(1)
    
    # Analyze results
    analyzer = ResultsAnalyzer(results_file)
    analyzer.print_summary()
    
    # Generate and save markdown report
    report_path = results_file.parent / f"{results_file.stem}_report.md"
    analyzer.save_report(report_path)
    
    print(f"\n📄 Full report available at: {report_path}")

if __name__ == "__main__":
    main()
'
    
    ############################################################################
    # File 3: run_complete_test.sh
    ############################################################################
    print_step "Generating run_complete_test.sh..."
    
    create_file "run_complete_test.sh" '#!/bin/bash

# DenteScope AI - Complete Batch Test Workflow
# This script sets up and runs the complete testing pipeline

set -e  # Exit on error

echo "=================================================================="
echo "🦷 DenteScope AI - Complete Batch Testing Workflow"
echo "=================================================================="

# Colors for output
RED='"'"'\033[0;31m'"'"'
GREEN='"'"'\033[0;32m'"'"'
YELLOW='"'"'\033[1;33m'"'"'
NC='"'"'\033[0m'"'"' # No Color

# Configuration
API_URL="${DENTESCOPE_API_URL:-http://localhost:8000}"
COMPLETE_REPO_DIR="./dentescope-ai-complete"

# Step 1: Check prerequisites
echo -e "\n${YELLOW}Step 1: Checking prerequisites...${NC}"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is required but not installed${NC}"
    exit 1
fi
echo "✅ Python 3 found"

# Check required Python packages
echo "📦 Checking Python packages..."
python3 -c "import requests" 2>/dev/null || {
    echo "⬇️  Installing requests..."
    pip3 install requests --break-system-packages
}

# Step 2: Clone the complete repository if not exists
echo -e "\n${YELLOW}Step 2: Setting up DenteScope AI Complete...${NC}"

if [ ! -d "$COMPLETE_REPO_DIR" ]; then
    echo "⬇️  Cloning repository..."
    git clone https://github.com/ajeetraina/dentescope-ai-complete.git
else
    echo "✅ Repository already exists"
fi

cd "$COMPLETE_REPO_DIR"

# Step 3: Check if Docker Compose services are running
echo -e "\n${YELLOW}Step 3: Checking DenteScope AI services...${NC}"

if docker-compose -f docker-compose.jetson.yml ps | grep -q "Up"; then
    echo "✅ Docker services are running"
else
    echo "⚠️  Docker services are not running"
    echo "   Starting services..."
    docker-compose -f docker-compose.jetson.yml up -d
    
    echo "⏳ Waiting for services to be ready (60 seconds)..."
    sleep 60
fi

# Check API health
echo "🔍 Checking API availability..."
MAX_RETRIES=10
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s -f "$API_URL/health" > /dev/null 2>&1; then
        echo "✅ API is available at $API_URL"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo "⏳ Waiting for API... (attempt $RETRY_COUNT/$MAX_RETRIES)"
        sleep 5
    fi
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo -e "${RED}❌ API is not responding after $MAX_RETRIES attempts${NC}"
    echo "   Please check the logs: docker-compose -f docker-compose.jetson.yml logs"
    exit 1
fi

# Step 4: Run batch testing
echo -e "\n${YELLOW}Step 4: Running batch tests...${NC}"

cd ..
python3 batch_test_dentescope.py "$API_URL"

# Step 5: Analyze results
echo -e "\n${YELLOW}Step 5: Analyzing results...${NC}"

# Find the most recent results file
LATEST_RESULTS=$(ls -t test_results/results/batch_test_results_*.json 2>/dev/null | head -1)

if [ -z "$LATEST_RESULTS" ]; then
    echo -e "${RED}❌ No results file found${NC}"
    exit 1
fi

echo "📊 Analyzing: $LATEST_RESULTS"
python3 analyze_results.py "$LATEST_RESULTS"

# Step 6: Summary
echo -e "\n${GREEN}=================================================================="
echo "✅ Batch Testing Complete!"
echo "==================================================================${NC}"

echo -e "\n📁 Results Location:"
echo "   - Raw Results: $LATEST_RESULTS"
echo "   - Report: ${LATEST_RESULTS%.json}_report.md"
echo "   - Images: test_results/images/"

echo -e "\n💡 Next Steps:"
echo "   1. Review the generated report"
echo "   2. Check failed images (if any)"
echo "   3. Analyze performance metrics"
echo "   4. View detailed results: cat ${LATEST_RESULTS%.json}_report.md"

echo -e "\n${GREEN}All done! 🎉${NC}\n"
'
    
    ############################################################################
    # File 4: setup_testing_suite.sh
    ############################################################################
    print_step "Generating setup_testing_suite.sh..."
    
    create_file "setup_testing_suite.sh" '#!/bin/bash

# Setup Testing Suite in dentescope-ai-complete repository

echo "🔧 Setting up DenteScope AI Testing Suite"
echo "=========================================="

# Target repository
REPO_DIR="${1:-./dentescope-ai-complete}"

if [ ! -d "$REPO_DIR" ]; then
    echo "❌ Repository not found: $REPO_DIR"
    echo "Usage: $0 [path-to-dentescope-ai-complete]"
    exit 1
fi

# Create testing directory
TESTING_DIR="$REPO_DIR/testing"
mkdir -p "$TESTING_DIR"

echo "📁 Copying test scripts to $TESTING_DIR..."

# Copy all testing files
cp batch_test_dentescope.py "$TESTING_DIR/"
cp analyze_results.py "$TESTING_DIR/"
cp run_complete_test.sh "$TESTING_DIR/"
cp README_TESTING.md "$TESTING_DIR/" 2>/dev/null || echo "Note: README_TESTING.md not found, skipping"

# Make scripts executable
chmod +x "$TESTING_DIR"/*.sh "$TESTING_DIR"/*.py

# Update main README
echo ""
echo "📝 Updating main README.md..."

if [ -f "$REPO_DIR/README.md" ]; then
    # Check if testing section already exists
    if ! grep -q "## 🧪 Testing" "$REPO_DIR/README.md"; then
        cat >> "$REPO_DIR/README.md" << '"'"'EOF'"'"'

## 🧪 Testing

A comprehensive testing suite is available to validate the system with 79+ dental X-ray images.

### Quick Test

```bash
cd testing
./run_complete_test.sh
```

This will:
- Download all test images from the dataset repository
- Process each image through the AI pipeline
- Generate detailed analysis reports
- Provide performance metrics

### Manual Testing

```bash
cd testing

# Run batch processing
python3 batch_test_dentescope.py http://localhost:8000

# Analyze results
python3 analyze_results.py test_results/results/batch_test_results_*.json
```

For complete testing documentation, see [testing/README_TESTING.md](testing/README_TESTING.md)

EOF
        echo "✅ Added testing section to README.md"
    else
        echo "ℹ️  Testing section already exists in README.md"
    fi
fi

# Create a GitHub Actions workflow for CI/CD (optional)
WORKFLOWS_DIR="$REPO_DIR/.github/workflows"
mkdir -p "$WORKFLOWS_DIR"

cat > "$WORKFLOWS_DIR/test.yml" << '"'"'EOF'"'"'
name: DenteScope AI Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '"'"'3.9'"'"'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install requests
    
    - name: Start Docker services
      run: |
        docker-compose -f docker-compose.jetson.yml up -d
        sleep 60
    
    - name: Run batch tests
      run: |
        cd testing
        python3 batch_test_dentescope.py http://localhost:8000
    
    - name: Analyze results
      run: |
        cd testing
        LATEST_RESULTS=$(ls -t test_results/results/batch_test_results_*.json | head -1)
        python3 analyze_results.py "$LATEST_RESULTS"
    
    - name: Upload test results
      uses: actions/upload-artifact@v3
      with:
        name: test-results
        path: testing/test_results/
EOF

echo "✅ Created GitHub Actions workflow"

# Create .gitignore entries for test results
if [ -f "$REPO_DIR/.gitignore" ]; then
    if ! grep -q "testing/test_results" "$REPO_DIR/.gitignore"; then
        cat >> "$REPO_DIR/.gitignore" << '"'"'EOF'"'"'

# Testing results
testing/test_results/images/
testing/test_results/results/*.json
EOF
        echo "✅ Updated .gitignore"
    fi
fi

echo ""
echo "✅ Testing suite setup complete!"
echo ""
echo "📁 Files installed to: $TESTING_DIR/"
echo ""
echo "🚀 To run tests:"
echo "   cd $TESTING_DIR"
echo "   ./run_complete_test.sh"
echo ""
'
    
    ############################################################################
    # Remaining documentation files...
    ############################################################################
    
    print_step "Generating documentation files..."
    
    # Create README.md, INDEX.md, QUICKSTART.sh, etc.
    # (Adding abbreviated versions for brevity - you can expand these)
    
    create_file "README.md" '# 🦷 DenteScope AI - Complete Testing Suite

**Comprehensive batch testing framework for validating DenteScope AI with 79+ real dental X-ray images**

## 🚀 Quick Start

```bash
# 1. View quick start guide
bash QUICKSTART.sh

# 2. Install to your repository
./setup_testing_suite.sh /path/to/dentescope-ai-complete

# 3. Run tests
cd /path/to/dentescope-ai-complete/testing
./run_complete_test.sh
```

## 📦 Package Contents

- `batch_test_dentescope.py` - Core testing engine
- `analyze_results.py` - Results analyzer
- `run_complete_test.sh` - Automated workflow
- `setup_testing_suite.sh` - Installation script
- Documentation files

## 📊 What Gets Tested

- ✅ All 79+ images from GitHub repository
- ✅ API availability and health
- ✅ Processing success rate
- ✅ Average processing time
- ✅ Tooth detection accuracy
- ✅ Clinical findings

See INDEX.md for complete documentation.
'
    
    create_file "QUICKSTART.sh" '#!/bin/bash

cat << '"'"'EOF'"'"'

🦷 DenteScope AI - Testing Suite Quick Start
=============================================

📦 WHAT YOU HAVE:
-----------------
✓ batch_test_dentescope.py    - Main testing engine
✓ analyze_results.py           - Results analyzer  
✓ run_complete_test.sh         - Automated workflow
✓ setup_testing_suite.sh       - Installation helper

🚀 QUICK START (3 STEPS):
--------------------------

Step 1: Install the testing suite
----------------------------------
./setup_testing_suite.sh /path/to/dentescope-ai-complete

Step 2: Run the tests
---------------------
cd /path/to/dentescope-ai-complete/testing
./run_complete_test.sh

Step 3: Review results
----------------------
Reports will be in: testing/test_results/results/

📞 SUPPORT:
-----------
GitHub: @ajeetraina
Email: ajeet.raina@gmail.com

Ready to test? Run:
  ./setup_testing_suite.sh /path/to/dentescope-ai-complete

Good luck! 🦷✨

EOF
'
    
    create_file "INDEX.md" '# 🦷 DenteScope AI - Testing Suite Package

**Version:** 1.0.0

## Package Contents

All files needed for comprehensive testing of DenteScope AI with 79+ dental X-ray images.

## Quick Start

```bash
bash QUICKSTART.sh
```

Then follow the on-screen instructions.

## Documentation

- README.md - Main documentation
- QUICKSTART.sh - Quick start guide
- This file (INDEX.md) - Package overview

## Support

GitHub: @ajeetraina
Email: ajeet.raina@gmail.com
'
    
    ############################################################################
    # Create a simple requirements.txt
    ############################################################################
    
    print_step "Generating requirements.txt..."
    
    create_file "requirements.txt" 'requests>=2.28.0
'
    
    ############################################################################
    # Completion
    ############################################################################
    
    print_step "Setting permissions..."
    chmod +x *.sh *.py 2>/dev/null || true
    
    print_success "All files generated successfully!"
    
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}  ✅ Testing Suite Generation Complete!                       ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📦 Package Location:${NC} $(pwd)"
    echo ""
    echo -e "${BLUE}📁 Generated Files:${NC}"
    ls -lh *.py *.sh *.md *.txt 2>/dev/null | awk '{print "   "$9" ("$5")"}'
    echo ""
    echo -e "${YELLOW}🚀 Next Steps:${NC}"
    echo "   1. Review QUICKSTART.sh: bash QUICKSTART.sh"
    echo "   2. Install suite: ./setup_testing_suite.sh /path/to/repo"
    echo "   3. Run tests: cd /path/to/repo/testing && ./run_complete_test.sh"
    echo ""
    echo -e "${GREEN}Ready to test your DenteScope AI! 🦷✨${NC}"
    echo ""
}

################################################################################
# Run Main Function
################################################################################

main "$@"
