#!/usr/bin/env python3
import http.server
import json
import subprocess
import os

class Handler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path != '/update-session':
            self.send_response(404); self.end_headers(); return
        length = int(self.headers['Content-Length'])
        body = json.loads(self.rfile.read(length))
        session_id = body.get('sessionId', '')
        cams = body.get('cams', 1)
        intervalo = body.get('intervalo', 30)

        # Ler stream.json atual
        with open('/home/admin/camera/stream.json', 'r') as f:
            data = json.load(f)

        data['sessionId'] = session_id
        data['cams'] = cams
        data['intervalo'] = intervalo

        with open('/home/admin/camera/stream.json', 'w') as f:
            json.dump(data, f)

        # Push para GitHub
        token = open('/home/admin/.github_token').read().strip()
        result = subprocess.run([
            'git', '-C', '/home/admin/camera', 'add', 'stream.json'
        ])
        subprocess.run(['git', '-C', '/home/admin/camera', 'commit', '-m', 'Atualizar sessao'])
        subprocess.run([
            'git', '-C', '/home/admin/camera', 'push',
            f'https://fnlceuazulpr:{token}@github.com/fnlceuazulpr/camera.git', 'main'
        ])

        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(b'{"ok": true}')

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def log_message(self, format, *args): pass

print("Session server rodando na porta 8765...")
http.server.HTTPServer(('0.0.0.0', 8765), Handler).serve_forever()
