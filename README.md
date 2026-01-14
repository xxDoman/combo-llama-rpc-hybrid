# 🚀 Combo-Llama: Hybrid NVIDIA + AMD (MI50) VRAM Cluster
### Performance-Optimized Distributed Inference (RTX 40-Series & GFX906)

**Combo-Llama** is a high-performance LLM cluster designed to bridge the gap between NVIDIA and AMD ecosystems. By utilizing the **llama.cpp RPC protocol**, this project aggregates the VRAM of an **NVIDIA RTX 4070 (12GB)** and an **AMD Instinct MI50 (32GB)** into a single, cohesive compute unit with **44GB of total usable VRAM**.

## 📊 Performance Benchmarks (The Proof)
Measurements taken using **Qwen3-VL-30B-A3B-Instruct (Q5_K_M)** on Hybrid RPC Setup.

### 🧪 Power Limit vs Speed
| Setting | Power Limit | Generation Speed | Status |
| :--- | :--- | :--- | :--- |
| **Power Overdrive** | **160W** | **55.35 tokens/s** | Recommended (Cooler) |
| **Stock/Reset** | **225W** | **55.42 tokens/s** | Minimal Gain |

> **Conclusion:** The bottleneck is likely the **PCIe Gen 4 x4** interface/bridge latency, not the GPU power. Running at **160W** is highly recommended as it maintains full performance while keeping temperatures lower.

## 🛠️ Hardware Compatibility Matrix
### NVIDIA (Master Node)
- Pre-compiled for **sm_89** (RTX 40-series). 
- **To change:** Edit `Dockerfile.nvidia_master` line `-DCMAKE_CUDA_ARCHITECTURES=89`.

### AMD (Worker Node)
- **Target:** `gfx906` (Instinct MI50, MI60, Radeon VII).
- **Optimization:** Includes pre-compiled **Tensile kernels** for GFX906.

## 🚀 Quick Start
1. Place your model in `./guff/`.
2. Run: `docker compose up -d`.
3. Use `./bench.sh` to verify performance.

## ⚙️ Key Optimizations
- **--parallel 1**: Critical for VRAM efficiency.
- **--ctx-size 32768**: Massive context support.
- **Interconnect:** PCIe Gen 4 x4 (Bridge).

---
Developed by **xxdoman** | Performance-first AI Clustering
