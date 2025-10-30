#!/usr/bin/env python3
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
        report.append("# 🦷 DenteScope AI - Batch Test Report
")
        report.append(f"**Generated:** {datetime.now().strftime(\"%Y-%m-%d %H:%M:%S\")}
")
        report.append(f"**Test Started:** {self.data[\"test_info\"][\"start_time\"]}
")
        report.append(f"**Dataset Source:** {self.data[\"test_info\"][\"dataset_source\"]}
")
        report.append("
---
")
        
        # Executive Summary
        summary = self.data["summary"]
        report.append("## 📊 Executive Summary
")
        report.append(f"- **Total Images Tested:** {summary[\"total\"]}")
        report.append(f"- **Successful Analyses:** {summary[\"success\"]} ({summary[\"success\"]/summary[\"total\"]*100:.1f}%)")
        report.append(f"- **Failed Analyses:** {summary[\"failed\"]} ({summary[\"failed\"]/summary[\"total\"]*100:.1f}%)")
        report.append(f"- **Total Processing Time:** {summary[\"total_time\"]:.2f}s")
        report.append(f"- **Average Time per Image:** {summary[\"avg_time_per_image\"]:.2f}s
")
        
        # Performance Metrics
        successful_results = [r for r in self.data["images"] if r["status"] == "success"]
        if successful_results:
            times = [r["processing_time"] for r in successful_results]
            report.append("## ⏱️ Performance Metrics
")
            report.append(f"- **Fastest Analysis:** {min(times):.2f}s")
            report.append(f"- **Slowest Analysis:** {max(times):.2f}s")
            report.append(f"- **Median Time:** {sorted(times)[len(times)//2]:.2f}s
")
        
        # Aggregate Analysis Statistics
        report.append("## 🔍 Clinical Analysis Summary
")
        
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
            report.append(f"- **Average Teeth per Image:** {total_teeth_detected/len(successful_results):.1f}
")
        
        if conditions_count:
            report.append("### Most Common Findings:
")
            sorted_conditions = sorted(conditions_count.items(), key=lambda x: x[1], reverse=True)
            for condition, count in sorted_conditions[:10]:
                report.append(f"- **{condition}:** {count} occurrences")
            report.append("")
        
        # Failed Images Analysis
        failed_results = [r for r in self.data["images"] if r["status"] == "failed"]
        if failed_results:
            report.append("## ❌ Failed Analyses
")
            report.append(f"Total failed: {len(failed_results)}
")
            
            # Group by error type
            error_types = defaultdict(list)
            for result in failed_results:
                error_msg = result.get("error", "Unknown error")
                error_types[error_msg].append(result["filename"])
            
            report.append("### Failure Breakdown:
")
            for error, files in error_types.items():
                report.append(f"**{error}** ({len(files)} images)")
                for filename in files[:5]:  # Show first 5
                    report.append(f"  - {filename}")
                if len(files) > 5:
                    report.append(f"  - ... and {len(files)-5} more")
                report.append("")
        
        # Individual Results Table
        report.append("## 📋 Individual Results
")
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
        report.append("## 💡 Recommendations
")
        
        if summary["failed"] > 0:
            failure_rate = summary["failed"] / summary["total"] * 100
            if failure_rate > 10:
                report.append("- ⚠️ High failure rate detected. Review failed images and error messages.")
        
        if summary["avg_time_per_image"] > 5.0:
            report.append("- ⚠️ Average processing time is high. Consider optimization or hardware upgrades.")
        
        if summary["success"] == summary["total"]:
            report.append("- ✅ Perfect success rate! All images processed successfully.")
        
        report.append("
---")
        report.append("
*Report generated by DenteScope AI Results Analyzer*")
        
        return "
".join(report)
    
    def save_report(self, output_path: Path):
        """Save the markdown report to a file"""
        report = self.generate_markdown_report()
        with open(output_path, "w") as f:
            f.write(report)
        print(f"✅ Report saved to: {output_path}")
    
    def print_summary(self):
        """Print a brief summary to console"""
        summary = self.data["summary"]
        
        print("
" + "="*80)
        print("📊 ANALYSIS SUMMARY")
        print("="*80)
        print(f"
✅ Success Rate: {summary[\"success\"]}/{summary[\"total\"]} ({summary[\"success\"]/summary[\"total\"]*100:.1f}%)")
        print(f"⏱️  Average Time: {summary[\"avg_time_per_image\"]:.2f}s per image")
        
        if summary["failed"] > 0:
            print(f"
❌ {summary[\"failed\"]} images failed processing")
        
        print("
" + "="*80)

def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("Usage: python3 analyze_results.py <results_file.json>")
        print("
Example:")
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
    
    print(f"
📄 Full report available at: {report_path}")

if __name__ == "__main__":
    main()

