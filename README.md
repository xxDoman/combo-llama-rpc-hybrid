# 🚀 Combo-Llama: Hybrid NVIDIA + AMD (MI50) VRAM Cluster
### Performance-Optimized Distributed Inference (RTX 40-Series & GFX906)

**Combo-Llama** is a high-performance LLM cluster designed to bridge the gap between NVIDIA and AMD ecosystems. By utilizing the **llama.cpp RPC protocol**, this project aggregates the VRAM of an **NVIDIA RTX 4070 (12GB)** and an **AMD Instinct MI50 (32GB)** into a single, cohesive compute unit with **44GB of total usable VRAM**.

## ⚙️ Point 0: Host & Hardware Prerequisites
Before deploying the containers, your host system must be configured according to the **ROCm 7.1** specifications. This is the foundation for stable communication between the hardware and Docker.

* **Host Driver Stack:** Ensure the **Linux Kernel KFD drivers** are correctly installed on the host.
* **ROCm Version:** This setup is optimized and tested for **ROCm 7.1**. Follow the driver/firmware matrix in the [Project Wiki](https://github.com/xxDoman/ollama-amd-rocm71-vl/wiki).
* **MI50 Firmware:** Specific firmware is required to unlock the full **1725MHz SCLK** potential.
* **Cooling:** Active cooling modification is **MANDATORY**. Sustained high-speed inference (1725MHz) will overheat a stock MI50 without a custom fan mod.
* **Docker Access:** Ensure the user is in the `video` and `render` groups to allow Docker access to `/dev/kfd` and `/dev/dri`.

## 🏗️ System Architecture
The system operates in a Master-Worker configuration via RPC:
- **Master (NVIDIA):** Runs the HTTP API, manages the KV Cache, and executes layers optimized for CUDA.
- **Worker (AMD):** Offloads heavy matrix multiplications via RPC, utilizing the 32GB HBM2 memory of the Instinct MI50.

## 📊 Performance Benchmarks (Certified Results)
Measurements taken using **Qwen3-VL-30B-A3B-Instruct (Q5_K_M)** on the Hybrid RPC Setup.

### 🧪 Power Limit vs Speed (The PCIe Bottleneck)
| Setting | Power Limit | Generation Speed | Thermal Status |
| :--- | :--- | :--- | :--- |
| **Reset/Stock** | **225W** | **55.83 tokens/s** | **~51°C (Active Mod)** |
| **Power Overdrive**| **160W** | **55.35 tokens/s** | **~43°C (Active Mod)** |

> **⚠️ Performance Bottleneck Analysis:**
> The marginal difference between 160W and 225W proves the system is bottlenecked by the **PCIe Gen 4 x4 interface**. The GPU core has unused headroom, and temperatures remain exceptionally low due to the custom active cooling mod.

## 🖥️ Live Hardware Utilization (Snapshot)
![Cluster Performance Dashboard](dashboard.png)
*Typical load during 2048 token generation:*
- **AMD MI50 (Worker):** **~89% GPU Load** | ~18GB VRAM | SCLK 1725MHz.
- **NVIDIA 4070 (Master):** **~12% GPU Load** | ~6.7GB VRAM | Low Power (~50W).

## 🧠 VRAM & Context Management
| Feature | Optimized (Current) | Default (Llama.cpp) | Difference |
| :--- | :--- | :--- | :--- |
| **Parallel Users** | **1 User** | 4 Users | -3 Slots |
| **VRAM Usage** | **~25 GB** | **~40+ GB** | **~15 GB Saved** |
| **Context Window** | **32,768 tokens** | - | **~60 Pages of Memory** |

**Key Advantage:** Setting `--parallel 1` saves **15GB of VRAM**, allowing a **30B model** with a massive **32k context window** to fit entirely within the 44GB hybrid buffer.

## 👁️ Vision-Language Capabilities (VL)
Tested with **Qwen-VL**, this cluster supports multimodal tasks:
- **Image Analysis:** Detailed descriptions of visual input.
- **OCR:** High-speed text extraction from documents.
- **Visual Reasoning:** Complex logic involving images.

## 📂 Model Management (.GGUF)
1. **Placement:** Put your `.gguf` files into the `./guff/` folder.
2. **Configuration:** Open `docker-compose.yml` and update the filename after the `-m /models/` flag.

## 🛠️ Hardware Compatibility Matrix

### NVIDIA (Master Node)
Pre-compiled for **sm_89** (RTX 40-series). To change architectures, edit `Dockerfile.nvidia_master` line `-DCMAKE_CUDA_ARCHITECTURES=89`.
| Generation | Architecture Code | Status |
| :--- | :--- | :--- |
| **RTX 50-series** | `100` | Manual Rebuild |
| **RTX 40-series** | `89` | **Ready (Default)** |
| **RTX 30-series** | `86` | Manual Rebuild |
| **RTX 20-series** | `75` | Manual Rebuild |

### AMD (Worker Node)
- **Target Arch:** `gfx906` (Instinct MI50, MI60, Radeon VII).
- **Software Stack:** **ROCm 7.1** (Latest Tested).
- **Cooling:** Active cooling mod is **mandatory** for sustained performance. [Check Wiki for Hardware Mods](https://github.com/xxDoman/ollama-amd-rocm71-vl/wiki).

## 🚀 Quick Start Guide
1. **Clone & Setup:**
   ```bash
   git clone https://github.com/xxDoman/combo-llama-rpc-hybrid.git
   cd combo-llama-rpc-hybrid
   mkdir guff
   mv /path/to/model.gguf ./guff/
   ```
2. **Deploy:** `docker compose up -d`
3. **Benchmark:** `./bench_long.sh`

## ❓ Troubleshooting (FAQ)
- **"Failed to load model":** Verify the filename in `docker-compose.yml` matches the file in `./guff/` exactly.
- **"Disk space errors":** Large models require ~30GB+ of free space. Use `mv` instead of `cp`.
- **"Permission denied":** If the model won't load, run `chmod 644 ./guff/*.gguf`.

---
Developed by **xxdoman** | AI Master of Disaster | Optimized Hybrid Performance
