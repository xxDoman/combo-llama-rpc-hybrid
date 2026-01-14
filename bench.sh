#!/bin/bash
echo "🚀 Uruchamiam benchmark (512 tokenów)..."

# Wysyłanie zapytania do API
curl -s -X POST http://localhost:8081/completion \
-H "Content-Type: application/json" \
-d '{
  "prompt": "Write a very long, detailed story about a space explorer discovering a new galaxy. Use at least 500 words.",
  "n_predict": 512
}' > /dev/null

echo -e "\n✅ Test zakończony. Statystyki z kontenera:\n"

# Pobieranie ostatnich statystyk z logów Mastera (NVIDIA)
docker logs combo-nvidia-master 2>&1 | grep "eval time" | tail -n 1
