# 🚀 Combo-Llama: Hybrid NVIDIA + AMD (MI50) VRAM Cluster
### Performance-Optimized Distributed Inference (RTX 40-Series & GFX906)

**Combo-Llama** is a professional-grade LLM cluster designed to bridge the gap between NVIDIA and AMD ecosystems. By utilizing the **llama.cpp RPC protocol**, this project aggregates the VRAM of an **NVIDIA RTX 4070 (12GB)** and an **AMD Instinct MI50 (32GB)** into a single, cohesive compute unit with **44GB of total usable VRAM**.

## 📂 Model Management (.GGUF)
To run your own models, follow these steps:

1. **Placement:** Put your `.gguf` files into the `./guff/` folder.
2. **Configuration:** Open `docker-compose.yml` and find the `command:` line in the `nvidia-master` section.
3. **Change Name:** Update the filename after the `-m /models/` flag:
   ```yaml
   command: "/app/llama-server -m /models/YOUR_MODEL_NAME.gguf --host 0.0.0.0 ..."
   ```

## 📊 Performance Benchmarks (The Proof)
Measurements taken using **Qwen3-VL-30B-A3B-Instruct (Q5_K_M)**.

### 🧪 Power Limit vs Speed (Efficiency Test)
| Setting | Power Limit | Generation Speed | Thermal Status |
| :--- | :--- | :--- | :--- |
| **Power Overdrive** | **160W** | **55.35 tokens/s** | **Stable & Cool** |
| **Stock/Reset** | **225W** | **55.42 tokens/s** | **Stable & Cool** |

## 🧠 VRAM & Context Management (Single User Optimization)
| Feature | Optimized (Current) | Default (Llama.cpp) | Difference |
| :--- | :--- | :--- | :--- |
| **Parallel Users** | **1 User** | 4 Users | -3 Slots |
| **Context Window** | **32,768 tokens** | 32,768 tokens | - |
| **VRAM Usage** | **~25 GB** | **~40+ GB** | **~15 GB Saved** |

**Key Advantage:** Setting `--parallel 1` saves **15GB of VRAM**, allowing a **30B model** with a **32k context** to fit entirely within the 44GB hybrid buffer.

## 🛠️ Hardware Compatibility Matrix
### NVIDIA (Master Node)
Pre-compiled for **sm_89** (RTX 40-series). 
- **To change:** Edit `Dockerfile.nvidia_master` line `-DCMAKE_CUDA_ARCHITECTURES=89`.

| Generation | Architecture Code | Status |
| :--- | :--- | :--- |
| **RTX 50-series** | `100` | Rebuild |
| **RTX 40-series** | `89` | **Ready** |
| **RTX 30-series** | `86` | Rebuild |

### AMD (Worker Node)
- **Target:** `gfx906` (Instinct MI50).
- **Cooling:** Active cooling mod is mandatory. [Check Wiki for Hardware Mods](https://github.com/xxDoman/ollama-amd-rocm71-vl/wiki).

## 🚀 Quick Start
1. Place your model in `./guff/`.
2. Update filename in `docker-compose.yml`.
3. Run: `docker compose up -d`.

---
Developed by **xxdoman** | Optimized for Hybrid Compute Performance
