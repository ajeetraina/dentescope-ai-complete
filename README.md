# 🦷 DenteScope AI - Complete Implementation for NVIDIA Jetson Thor

<div align="center">

![DenteScope AI](https://img.shields.io/badge/DenteScope-AI-blue?style=for-the-badge)
![NVIDIA Jetson Thor](https://img.shields.io/badge/NVIDIA-Jetson%20Thor-76B900?style=for-the-badge&logo=nvidia)
![YOLOv8](https://img.shields.io/badge/YOLOv8-Detection-orange?style=for-the-badge)

**Production-Ready Dental AI Analysis System**  
Optimized for NVIDIA Jetson Thor | <50ms Detection | <1s Complete Analysis

</div>

## 🎯 Overview

DenteScope AI is a **production-ready medical AI system** for dental panoramic X-ray analysis, specifically optimized for **NVIDIA Jetson Thor** edge deployment.

### Features

- **YOLOv8 + TensorRT** for ultra-fast tooth detection (<50ms)
- **Multi-Agent LLM System** for clinical analysis
- **Real-time WebSocket** updates with React UI
- **Edge Processing** for HIPAA compliance

## 🚀 Quick Start

### Prerequisites
- NVIDIA Jetson Thor with JetPack 6.0+
- Docker with NVIDIA Container Runtime
- 16GB RAM, 64GB storage

### Deploy
```bash
# Clone repository
git clone https://github.com/ajeetraina/dentescope-ai-complete.git
cd dentescope-ai-complete

# Configure
cp .env.example .env
# Edit .env with your API keys

# Start
docker-compose -f docker-compose.jetson.yml up -d
```

### Access
- **UI**: http://localhost:3000
- **API**: http://localhost:8000
- **Docs**: http://localhost:8000/docs

## 📊 Performance

- **Detection**: 45ms (YOLOv8 + TensorRT)
- **Total Pipeline**: <1s
- **GPU Utilization**: 68%
- **Accuracy**: mAP50 0.87

## 🏗️ Architecture

Multi-agent system with:
- Supervisor Agent (orchestrator)
- Detection Agent (YOLOv8)
- Measurement Agent (CV + LLM)
- Clinical Agent (LLM)
- Report Agent (LLM)

## 📚 Documentation

- [Quick Start](QUICK_START.md)
- [Deployment Guide](docs/DEPLOYMENT_GUIDE.md)
- [Architecture](docs/ARCHITECTURE.md)

## 🤝 Contributing

Contributions welcome! See issues page.

## 📄 License

MIT License

## 📞 Contact

- GitHub: [@ajeetraina](https://github.com/ajeetraina)
- Twitter: [@ajeetsraina](https://twitter.com/ajeetsraina)
- Email: ajeet.raina@gmail.com
