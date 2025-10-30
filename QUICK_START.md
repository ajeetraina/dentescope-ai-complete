# DenteScope AI - Quick Start Guide

## 🚀 Deploy in 5 Minutes

### Step 1: Clone Repository
```bash
git clone https://github.com/ajeetraina/dentescope-ai-complete.git
cd dentescope-ai-complete
```

### Step 2: Configure
```bash
cp .env.example .env
# Edit .env and add your ANTHROPIC_API_KEY
```

### Step 3: Deploy
```bash
docker-compose -f docker-compose.jetson.yml up -d
```

### Step 4: Access
- UI: http://localhost:3000
- API: http://localhost:8000

## 🧪 Test

Upload a sample X-ray and see results in <1 second!

## 📖 Full Documentation

See [DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md) for detailed instructions.
