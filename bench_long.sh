#!/bin/bash
echo "🔥 Uruchamiam DŁUGI benchmark (2048 tokenów) dla stabilnego obciążenia..."

curl -s -X POST http://localhost:8081/completion \
-H "Content-Type: application/json" \
-d '{
  "prompt": "Write an incredibly long, detailed technical manual about terraforming Mars, including geological, atmospheric, and biological aspects. Be as verbose as possible.",
  "n_predict": 2048
}' > /dev/null

echo -e "\n✅ Test zakończony."
