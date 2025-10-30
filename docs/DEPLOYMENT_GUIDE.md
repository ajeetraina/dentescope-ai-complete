# DenteScope AI - Deployment Guide

## Prerequisites

- NVIDIA Jetson Thor with JetPack 6.0+
- Docker with NVIDIA Container Runtime
- 16GB RAM minimum
- 64GB storage

## Installation Steps

### 1. Clone Repository
```bash
git clone https://github.com/ajeetraina/dentescope-ai-complete.git
cd dentescope-ai-complete
```

### 2. Configure Environment
```bash
cp .env.example .env
nano .env  # Add your API keys
```

### 3. Deploy with Docker
```bash
docker-compose -f docker-compose.jetson.yml up -d
```

### 4. Verify Deployment
```bash
# Check services
docker-compose ps

# Check logs
docker-compose logs -f
```

## Accessing the Application

- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Documentation: http://localhost:8000/docs

## Troubleshooting

### Issue: Port already in use
Change ports in docker-compose.jetson.yml

### Issue: GPU not detected
Ensure NVIDIA Container Runtime is installed

### Issue: Out of memory
Reduce batch size in configuration

## Performance Tuning

Set Jetson to maximum performance:
```bash
sudo nvpmodel -m 0
sudo jetson_clocks
```

## Security

- Change default SECRET_KEY in .env
- Enable HTTPS in production
- Restrict API access as needed

## Support

For issues, see: https://github.com/ajeetraina/dentescope-ai-complete/issues
