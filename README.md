# 🚀 Combo-Llama: Hybrid NVIDIA + AMD (MI50) VRAM Cluster
### Performance-Optimized Distributed Inference (RTX 40-Series & GFX906)

**Combo-Llama** is a high-performance LLM cluster designed to bridge the gap between NVIDIA and AMD ecosystems. By utilizing the **llama.cpp RPC protocol**, this project aggregates the VRAM of an **NVIDIA RTX 4070 (12GB)** and an **AMD Instinct MI50 (32GB)** into a single, cohesive compute unit with **44GB of total usable VRAM**.

## ⚡ Performance Benchmarks
Tested on **Qwen3-VL-30B-A3B-Instruct (Q5_K_M)**:
- **Generation Speed:** ~55.6 tokens/sec 🚀
- **Prompt Processing:** ~144.8 tokens/sec
- **Latency:** ~3.2s for 180 tokens response
- **VRAM Footprint:** Optimized to ~25GB (allowing overhead for high context)

## 🛠️ Hardware Compatibility Matrix

### NVIDIA (Master Node)
The Docker Hub image is pre-compiled for **sm_89** (RTX 40-series). 

**To use a different generation:** 1. Open `Dockerfile.nvidia_master`
2. Change the value in `-DCMAKE_CUDA_ARCHITECTURES=89` to match your card.
3. Rebuild with `docker compose build --no-cache nvidia-master`.

| Generation | Architecture Code | Recommendation |
| :--- | :--- | :--- |
| **RTX 50-series (Blackwell)** | `100` | Update Dockerfile & Rebuild |
| **RTX 40-series (Ada Lovelace)** | `89` | **Supported (Default Image)** |
| **RTX 30-series (Ampere)** | `86` | Update Dockerfile & Rebuild |
| **RTX 20-series (Turing)** | `75` | Update Dockerfile & Rebuild |
| **GTX 10-series (Pascal)** | `61` | Update Dockerfile & Rebuild |

### AMD (Worker Node)
- **Target:** `gfx906` (Instinct MI50, MI60, Radeon VII).
- **Optimization:** Includes pre-compiled **Tensile kernels** for maximum matrix multiplication efficiency on GFX906.
- **Environment:** Hardcoded `HSA_OVERRIDE_GFX_VERSION=9.0.6` for system stability.

## 📦 Container Registry (Docker Hub)
No compilation required if you match the default hardware specs:
- **Worker:** `xxdoman/llama-rpc-mi50:latest`
- **Master:** `xxdoman/llama-rpc-nvidia:latest`

## 🚀 Quick Start Guide

### 1. Prerequisites
- Create a directory named `./guff/` and place your `.gguf` model inside.
- Ensure the model filename in `docker-compose.yml` matches your file.

### 2. Deployment
```bash
docker compose up -d
```
The API server will be accessible at `http://localhost:8081`.

## ⚙️ Configuration & Optimizations
This setup uses specific flags to maximize the MI50 + RTX 4070 potential:
- `--parallel 1`: Limits processing to a single request slot, saving ~15GB of VRAM previously wasted on idle buffers.
- `--ctx-size 32768`: Provides a massive 32k context window while maintaining stability.
- `--n-gpu-layers 100`: Ensures 100% of the model is offloaded to GPUs (0% CPU usage).

---
Developed by **xxdoman** | Optimized for Open-Source AI
