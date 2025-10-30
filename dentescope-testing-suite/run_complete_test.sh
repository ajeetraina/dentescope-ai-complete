#!/bin/bash

# DenteScope AI - Complete Batch Test Workflow
# This script sets up and runs the complete testing pipeline

set -e  # Exit on error

echo "=================================================================="
echo "🦷 DenteScope AI - Complete Batch Testing Workflow"
echo "=================================================================="

# Colors for output
RED='[0;31m'
GREEN='[0;32m'
YELLOW='[1;33m'
NC='[0m' # No Color

# Configuration
API_URL="${DENTESCOPE_API_URL:-http://localhost:8000}"
COMPLETE_REPO_DIR="./dentescope-ai-complete"

# Step 1: Check prerequisites
echo -e "
${YELLOW}Step 1: Checking prerequisites...${NC}"

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
echo -e "
${YELLOW}Step 2: Setting up DenteScope AI Complete...${NC}"

if [ ! -d "$COMPLETE_REPO_DIR" ]; then
    echo "⬇️  Cloning repository..."
    git clone https://github.com/ajeetraina/dentescope-ai-complete.git
else
    echo "✅ Repository already exists"
fi

cd "$COMPLETE_REPO_DIR"

# Step 3: Check if Docker Compose services are running
echo -e "
${YELLOW}Step 3: Checking DenteScope AI services...${NC}"

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
echo -e "
${YELLOW}Step 4: Running batch tests...${NC}"

cd ..
python3 batch_test_dentescope.py "$API_URL"

# Step 5: Analyze results
echo -e "
${YELLOW}Step 5: Analyzing results...${NC}"

# Find the most recent results file
LATEST_RESULTS=$(ls -t test_results/results/batch_test_results_*.json 2>/dev/null | head -1)

if [ -z "$LATEST_RESULTS" ]; then
    echo -e "${RED}❌ No results file found${NC}"
    exit 1
fi

echo "📊 Analyzing: $LATEST_RESULTS"
python3 analyze_results.py "$LATEST_RESULTS"

# Step 6: Summary
echo -e "
${GREEN}=================================================================="
echo "✅ Batch Testing Complete!"
echo "==================================================================${NC}"

echo -e "
📁 Results Location:"
echo "   - Raw Results: $LATEST_RESULTS"
echo "   - Report: ${LATEST_RESULTS%.json}_report.md"
echo "   - Images: test_results/images/"

echo -e "
💡 Next Steps:"
echo "   1. Review the generated report"
echo "   2. Check failed images (if any)"
echo "   3. Analyze performance metrics"
echo "   4. View detailed results: cat ${LATEST_RESULTS%.json}_report.md"

echo -e "
${GREEN}All done! 🎉${NC}
"

