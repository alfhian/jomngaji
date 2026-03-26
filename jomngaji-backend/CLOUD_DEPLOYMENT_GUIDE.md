# Panduan Deploy Backend Python (FastAPI) ke Cloud Server

Panduan ini ditujukan untuk backend `jomngaji-backend` dengan stack **FastAPI + Uvicorn** di server **Ubuntu 22.04/24.04**.

## 1) Persiapan server

### Spesifikasi minimum (disarankan)
- CPU: 2 vCPU
- RAM: 2 GB (lebih besar bila pakai model ML)
- Disk: 20 GB SSD
- OS: Ubuntu LTS

### Install paket dasar
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-venv python3-pip git nginx ufw
```

### Buka firewall
```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
sudo ufw status
```

## 2) Clone project dan setup virtualenv

```bash
cd /opt
sudo git clone <URL_REPO_ANDA> jomngaji
sudo chown -R $USER:$USER /opt/jomngaji

cd /opt/jomngaji/jomngaji-backend
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

## 3) Set environment variable

Buat file `.env` di `jomngaji-backend` (sesuaikan dengan kebutuhan app):

```env
SECRET_KEY=replace_with_strong_secret
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=10080
DATABASE_URL=postgresql://user:password@127.0.0.1:5432/jomngaji
```

> Jika app Anda membaca env langsung dari shell/systemd, pastikan key yang dibutuhkan di-load sebelum service start.

## 4) Test manual sebelum dibuat service

```bash
cd /opt/jomngaji/jomngaji-backend
source .venv/bin/activate
uvicorn app.main:app --host 0.0.0.0 --port 4000
```

Cek dari server:
```bash
curl -I http://127.0.0.1:4000/docs
```

Jika sudah OK, hentikan proses (`Ctrl+C`) lalu lanjut ke systemd.

## 5) Jalankan sebagai systemd service

Buat file service:
```bash
sudo nano /etc/systemd/system/jomngaji-backend.service
```

Isi file:
```ini
[Unit]
Description=JomNgaji FastAPI Backend
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/opt/jomngaji/jomngaji-backend
Environment="PATH=/opt/jomngaji/jomngaji-backend/.venv/bin"
EnvironmentFile=/opt/jomngaji/jomngaji-backend/.env
ExecStart=/opt/jomngaji/jomngaji-backend/.venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 4000 --workers 2
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
```

Aktifkan service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable jomngaji-backend
sudo systemctl start jomngaji-backend
sudo systemctl status jomngaji-backend
```

Lihat log realtime:
```bash
sudo journalctl -u jomngaji-backend -f
```

## 6) Reverse proxy Nginx + domain

Buat config Nginx:
```bash
sudo nano /etc/nginx/sites-available/jomngaji-backend
```

Isi file:
```nginx
server {
    listen 80;
    server_name api.jomngaji.com;

    location / {
        proxy_pass http://127.0.0.1:4000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable site:
```bash
sudo ln -s /etc/nginx/sites-available/jomngaji-backend /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 7) HTTPS (wajib production)

Pastikan domain `api.jomngaji.com` sudah mengarah ke IP server, lalu:
```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d api.jomngaji.com
```

Cek auto-renew:
```bash
sudo systemctl status certbot.timer
```

## 8) Checklist pasca deploy

- Endpoint health/docs terbuka via HTTPS.
- Login/register dari app Flutter sukses ke domain backend.
- CORS hanya mengizinkan origin frontend yang valid.
- `SECRET_KEY` kuat dan tidak di-commit.
- Service restart otomatis saat crash (`Restart=always`).
- Monitoring log aktif (`journalctl`).

## 9) Update aplikasi (rolling sederhana)

```bash
cd /opt/jomngaji
git pull
cd jomngaji-backend
source .venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart jomngaji-backend
sudo systemctl status jomngaji-backend
```

## 10) Troubleshooting cepat

### `ModuleNotFoundError`
- Pastikan install dilakukan di virtualenv yang sama dengan service.
- Cek `Environment="PATH=.../.venv/bin"` di file systemd.

### `500 Internal Server Error`
- Buka log:
```bash
sudo journalctl -u jomngaji-backend -n 200 --no-pager
```
- Periksa env penting (`SECRET_KEY`, koneksi DB, dependency opsional).

### Tidak bisa diakses dari internet
- Pastikan DNS domain benar.
- Cek firewall `ufw status`.
- Pastikan Nginx jalan: `sudo systemctl status nginx`.

---

Kalau Anda mau, langkah berikutnya saya bisa bantu bikinkan **versi Docker + docker-compose** untuk deploy yang lebih repeatable (termasuk Postgres dan Nginx) agar proses release lebih rapi.
