#!/bin/bash

GITHUB_TOKEN=$(cat ~/.github_token)
GITHUB_USER="fnlceuazulpr"
REPO="camera"

TUNNEL_URL=$(journalctl -u cloudflared --no-pager -n 50 | grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' | tail -1)

if [ -z "$TUNNEL_URL" ]; then
  echo "URL do túnel não encontrada"
  exit 1
fi

echo "URL encontrada: $TUNNEL_URL"

# Ler sessionId ativo (se existir)
SESSION_ID=""
if [ -f ~/.active_session ]; then
  SESSION_ID=$(cat ~/.active_session)
fi

# Atualizar stream.json
echo "{\"url\": \"$TUNNEL_URL/camera/index.m3u8\", \"url2\": \"$TUNNEL_URL/camera2/index.m3u8\", \"sessionId\": \"\", \"cams\": 2, \"intervalo\": 30}" > /home/admin/camera/stream.json

cp /home/admin/camera/watch.html /home/admin/camera/watch/index.html

cd /home/admin/camera
git add stream.json watch/index.html
git commit -m "Atualizar URL do stream"
git push https://$GITHUB_USER:$GITHUB_TOKEN@github.com/$GITHUB_USER/$REPO.git main

echo "GitHub Pages atualizado com sucesso!"
