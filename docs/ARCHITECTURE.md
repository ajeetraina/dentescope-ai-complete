# DenteScope AI - Architecture

## System Overview

DenteScope AI uses a multi-agent architecture optimized for edge deployment on NVIDIA Jetson Thor.

## Components

### Frontend (React + TypeScript)
- Modern UI with real-time updates
- WebSocket communication
- Interactive visualization

### Backend (FastAPI + Python)
- Multi-agent orchestration
- YOLOv8 + TensorRT for detection
- LangChain for agent coordination

### Agents
1. **Supervisor Agent**: Orchestrates workflow
2. **Detection Agent**: YOLOv8 tooth detection
3. **Measurement Agent**: Precise measurements
4. **Clinical Agent**: Clinical analysis
5. **Report Agent**: Report generation

## Data Flow

1. User uploads X-ray
2. Supervisor coordinates agents
3. Detection agent finds teeth
4. Measurement agent calculates widths
5. Clinical agent provides insights
6. Report agent generates summary
7. Results displayed to user

## Resource Allocation

- YOLOv8: 800 TOPS (40%)
- LLM Agents: 1000 TOPS (50%)
- Image Processing: 200 TOPS (10%)

Total: 2000 TOPS (100% utilization)

## Performance

- Detection: <50ms
- Total pipeline: <1s
- GPU utilization: 60-80%
