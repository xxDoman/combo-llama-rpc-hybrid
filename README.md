# 🚀 Combo-Llama: Hybrid NVIDIA + AMD (MI50) VRAM Cluster
### Performance-Optimized Distributed Inference (RTX 40-Series & GFX906)

**Combo-Llama** is a professional-grade LLM cluster designed to bridge the gap between NVIDIA and AMD ecosystems. By utilizing the **llama.cpp RPC protocol**, this project aggregates the VRAM of an **NVIDIA RTX 4070 (12GB)** and an **AMD Instinct MI50 (32GB)** into a single, cohesive compute unit with **44GB of total usable VRAM**.

## 📊 Performance Benchmarks (The Proof)
Measurements taken using **Qwen3-VL-30B-A3B-Instruct (Q5_K_M)** on Hybrid RPC Setup.

### 🧪 Power Limit vs Speed (Efficiency Test)
| Setting | Power Limit | Generation Speed | Thermal Status |
| :--- | :--- | :--- | :--- |
| **Power Overdrive** | **160W** | **55.35 tokens/s** | **Stable & Cool** |
| **Stock/Reset** | **225W** | **55.42 tokens/s** | **Stable & Cool** |

> **Tech Analysis:** Thermal throttling is **non-existent** in this setup due to custom active cooling (see Wiki). Performance is currently capped by the **PCIe Gen 4 x4 bridge bandwidth**, which is the hardware throughput limit for this specific interconnect.

### 📈 Comparative Analysis
| Hardware Configuration | Model Size | Generation Speed | VRAM Status |
| :--- | :--- | :--- | :--- |
| **Single RTX 4070 (12GB)** | 30B (Q5) | **OOM** | Failed |
| **Single MI50 (32GB)** | 30B (Q5) | ~18-22 tokens/s | 100% Used |
| **Hybrid (4070 + MI50) RPC** | **30B (Q5)** | **55.64 tokens/s** | **Optimal (~25GB used)** |

## 🛠️ Hardware Compatibility Matrix

### NVIDIA (Master Node)
The default Docker Hub image is pre-compiled for **sm_89** (RTX 40-series). 

**To use a different generation:** 1. Open `Dockerfile.nvidia_master`.
2. Change `-DCMAKE_CUDA_ARCHITECTURES=89` to your specific code.
3. Rebuild: `docker compose build --no-cache nvidia-master`.

| Generation | Architecture Code | Status |
| :--- | :--- | :--- |
| **RTX 50-series (Blackwell)** | `100` | Manual Rebuild |
| **RTX 40-series (Ada Lovelace)** | `89` | **Ready (Default)** |
| **RTX 30-series (Ampere)** | `86` | Manual Rebuild |
| **RTX 20-series (Turing)** | `75` | Manual Rebuild |
| **GTX 10-series (Pascal)** | `61` | Manual Rebuild |

### AMD (Worker Node)
- **Target:** `gfx906` (Instinct MI50, MI60, Radeon VII).
- **Optimization:** Includes pre-compiled **Tensile kernels** for maximum matrix multiplication efficiency.
- **Cooling:** Active cooling mod is mandatory for these results. [Check Wiki for Hardware Mods](https://github.com/xxDoman/ollama-amd-rocm71-vl/wiki).

## 🚀 Quick Start Guide

### 1. Prerequisites
- Place your `.gguf` model in the `./guff/` directory.
- Ensure model names match in `docker-compose.yml`.

### 2. Deployment
```bash
docker compose up -d
```

### 3. Verification
Run the included benchmark script to verify your tokens/s:
```bash
./bench.sh
```

## ⚙️ Key Optimizations
- **--parallel 1**: Critical for eliminating multi-slot VRAM overhead (~15GB saved).
- **--ctx-size 32768**: High-capacity context window.
- **--n-gpu-layers 100**: Full GPU offloading (Zero CPU bottleneck).
- **HSA_OVERRIDE_GFX_VERSION=9.0.6**: Forced stability for ROCm.

---
Developed by **xxdoman** | Optimized for Hybrid Compute Performance
