#!/bin/bash
GITHUB_TOKEN=$(cat ~/.github_token)
GITHUB_USER="fnlceuazulpr"
REPO="camera"

TUNNEL_URL=$(sudo cat /var/log/cloudflared.log | strings | grep 'trycloudflare.com' | grep -v 'Requesting\|URL encontrada' | grep 'https://' | tail -1 | grep -oP 'https://[^\s]+\.trycloudflare\.com')

if [ -z "$TUNNEL_URL" ]; then
  echo "URL do túnel não encontrada"
  exit 1
fi

echo "URL encontrada: $TUNNEL_URL"

cd /home/admin/camera

cat > stream.json << JSONEOF
{"url": "${TUNNEL_URL}/camera/index.m3u8", "url2": "${TUNNEL_URL}/camera2/index.m3u8", "sessionId": "", "cams": 2, "intervalo": 30}
JSONEOF

git add stream.json
git commit -m "update tunnel url"
git push https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO}.git main
echo "GitHub Pages atualizado com sucesso!"
