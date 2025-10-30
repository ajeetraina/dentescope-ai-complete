#!/bin/bash

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
        cat >> "$REPO_DIR/README.md" << 'EOF'

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

cat > "$WORKFLOWS_DIR/test.yml" << 'EOF'
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
        python-version: '3.9'
    
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
        cat >> "$REPO_DIR/.gitignore" << 'EOF'

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

