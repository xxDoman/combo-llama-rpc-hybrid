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

> **Tech Analysis:** Thermal throttling is **non-existent** due to custom active cooling. Performance is capped by the **PCIe Gen 4 x4 bridge bandwidth**, which is the hardware throughput limit for this specific interconnect.

## 🧠 VRAM & Context Management
This setup is strictly optimized for **Single User Performance** to maximize speed and memory capacity.

| Feature | Optimized (Current) | Default (Llama.cpp) | Difference |
| :--- | :--- | :--- | :--- |
| **Parallel Users** | **1 User** | 4 Users | -3 Slots |
| **Context Window** | **32,768 tokens** | 32,768 tokens | - |
| **VRAM Usage** | **~25 GB** | **~40+ GB** | **~15 GB Saved** |

**Key Advantage:** By setting `--parallel 1`, we save **15GB of VRAM** that would otherwise be wasted on idle conversation slots. This allows a **30B model** to run with a massive **32k context window** (approx. 50-60 pages of "memory") entirely within the GPU VRAM.

### 📈 Comparative Analysis
| Hardware Configuration | Model Size | Generation Speed | VRAM Status |
| :--- | :--- | :--- | :--- |
| **Single RTX 4070 (12GB)** | 30B (Q5) | **OOM** | Failed |
| **Single MI50 (32GB)** | 30B (Q5) | ~18-22 tokens/s | 100% Used |
| **Hybrid (4070 + MI50) RPC** | **30B (Q5)** | **55.64 tokens/s** | **Optimal** |

## 🛠️ Hardware Compatibility Matrix

### NVIDIA (Master Node)
Pre-compiled for **sm_89** (RTX 40-series). To use a different generation, edit `Dockerfile.nvidia_master` line `-DCMAKE_CUDA_ARCHITECTURES=89`.

| Generation | Architecture Code | Status |
| :--- | :--- | :--- |
| **RTX 50-series (Blackwell)** | `100` | Manual Rebuild |
| **RTX 40-series (Ada Lovelace)** | `89` | **Ready (Default)** |
| **RTX 30-series (Ampere)** | `86` | Manual Rebuild |
| **RTX 20-series (Turing)** | `75` | Manual Rebuild |
| **GTX 10-series (Pascal)** | `61` | Manual Rebuild |

### AMD (Worker Node)
- **Target:** `gfx906` (Instinct MI50, MI60, Radeon VII).
- **Optimization:** Includes pre-compiled **Tensile kernels** for GFX906.
- **Cooling:** Active cooling mod is mandatory. [Check Wiki for Hardware Mods](https://github.com/xxDoman/ollama-amd-rocm71-vl/wiki).

## 🚀 Quick Start Guide
1. Place your `.gguf` model in the `./guff/` directory.
2. Run: `docker compose up -d`.
3. Verify performance: `./bench.sh`.

## ⚙️ Key Optimizations
- **--parallel 1**: Single user optimization (Saves 15GB VRAM).
- **--ctx-size 32768**: Massive 32k context for long-form conversations.
- **--n-gpu-layers 100**: 100% GPU offloading (Zero CPU usage).
- **PCIe Gen 4 x4**: Utilizing maximum bridge bandwidth.

---
Developed by **xxdoman** | Optimized for Hybrid Compute Performance
