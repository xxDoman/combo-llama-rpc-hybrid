# 🚀 Combo-Llama: Hybrid NVIDIA + AMD (MI50) VRAM Cluster
### Performance-Optimized Distributed Inference (RTX 40-Series & GFX906)

**Combo-Llama** to profesjonalny klaster LLM, który agreguje **44GB VRAM** z kart **NVIDIA RTX 4070 (12GB)** oraz **AMD Instinct MI50 (32GB)**.

## 📊 Dowód Wydajności (55.83 tokens/s)
![Cluster Performance Dashboard](dashboard.png)
*Powyższy zrzut ekranu przedstawia system podczas generowania 2048 tokenów.*

### 📈 Analiza Obciążenia (Snapshot z testu):
| Podzespół | Wykorzystanie GPU | VRAM | Rola w systemie |
| :--- | :--- | :--- | :--- |
| **AMD MI50** | **89%** | **~18 GB** | Główna moc obliczeniowa (Compute) |
| **NVIDIA 4070** | **12%** | **~6.7 GB** | Master Node / KV Cache / API |

> **Werdykt Techniczny:** Niskie obciążenie karty NVIDIA (12%) przy jednoczesnym wysokim obciążeniu AMD (89%) ostatecznie potwierdza **bottleneck na szynie PCIe Gen 4 x4**. System generuje tokeny tak szybko, jak pozwala na to interfejs komunikacyjny, a nie same rdzenie GPU.

## 🧠 Optymalizacja VRAM i Kontekstu
Dzięki flagom `--parallel 1` oraz `--ctx-size 32768`, klaster oszczędza **15GB VRAM**, pozwalając na pracę z modelami **30B (Q5)** przy zachowaniu "pamięci" o długości ok. 60 stron tekstu.

## 🛠️ Hardware & Cooling
- **RTX 4070:** Pracuje w trybie niskiego poboru mocy (~50W).
- **MI50:** Dzięki autorskiemu chłodzeniu aktywnemu, karta utrzymuje **~51°C** przy pełnym obciążeniu (1725MHz SCLK). [Wiki Chłodzenia](https://github.com/xxDoman/ollama-amd-rocm71-vl/wiki).

## 🚀 Szybki Start
1. Wrzuć model do `./guff/`.
2. Uruchom: `docker compose up -d`.
3. Testuj: `./bench_long.sh`.

---
Developed by **xxdoman** | AI Master of Disaster | 2026-01-15
