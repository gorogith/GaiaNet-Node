# 🌍 GaiaNet Node Manager

Script manajemen untuk node Gaia yang memudahkan proses instalasi, konfigurasi, dan monitoring. Dilengkapi dengan fitur auto chat untuk interaksi otomatis dengan Gaia AI.

## ✨ Fitur Utama

- 🚀 **Instalasi Otomatis**
  - One-click installation
  - Konfigurasi otomatis environment
  - Pengecekan persyaratan sistem
  
- 🖥️ **Manajemen Node**
  - Start/stop node dengan mudah
  - Monitoring status node
  - Auto-restart saat node berhenti
  
- 📊 **Sistem Monitoring**
  - Log node terstruktur
  - Status node real-time
  - Informasi performa node
  
- 🤖 **Auto Chat**
  - Chat otomatis dengan Gaia AI
  - Konfigurasi interval chat
  - Log chat terstruktur
  
- 📝 **Logging System**
  - Log instalasi
  - Log aktivitas node
  - Log chat
  - Timestamp untuk setiap event

## 💻 Persyaratan Sistem

### Hardware
- CPU: 2 core (recommended 4 core)
- RAM: 4GB minimum
- Storage: 20GB free space
- Network: Koneksi internet stabil

### Software
- OS: Ubuntu 20.04+ / Debian 11+
- Python 3.7+
- Screen
- Git
- curl
- jq

## 🚀 Cara Instalasi

1. Clone repository
```bash
git clone https://github.com/gorogith/GaiaNet-Node.git
cd GaiaNet-Node
```

2. Set permission
```bash
chmod +x gaia.sh
```

3. Jalankan installer
```bash
./gaia.sh
```

## 📖 Penggunaan

### Menu Utama
1. **Install Node** - Install node baru
   - Menginstall dependencies
   - Konfigurasi environment
   - Generate node ID dan device ID

2. **Start Node** - Menjalankan node
   - Start dalam screen session
   - Auto-restart jika crash
   - Start web interface

3. **Stop Node** - Menghentikan node
   - Graceful shutdown
   - Cleanup resources

4. **Check Status** - Status node
   - Status koneksi
   - Uptime
   - Resource usage

5. **View Logs** - Lihat log node
   - Error logs
   - Activity logs
   - Performance logs

6. **Node Info** - Informasi node
   - Node ID
   - Device ID
   - Public URL
   - Konfigurasi

7. **Start Auto Chat** - Mulai auto chat
   - Interval: 5 menit
   - Keyword: "hello"
   - Log di chat_logs.txt

8. **Stop Auto Chat** - Stop auto chat
   - Graceful shutdown
   - Save chat logs

9. **Auto Chat Status** - Status auto chat
   - Running/stopped
   - Last chat time
   - Chat logs

10. **Remove Node** - Hapus node
    - Konfirmasi penghapusan
    - Hapus semua data node
    - Hapus konfigurasi environment
    - Bersihkan screen sessions

0. **Exit** - Keluar program

### 📂 Struktur Direktori

```
~/gaianet/
├── bin/           # Binary dan executables
├── logs/          # Log files
│   ├── node.log   # Node logs
│   └── chat.log   # Chat logs
├── config/        # Konfigurasi
└── data/          # Data node
```

### 🔍 Log Files

- **Install Log**: `~/gaianet/install.log`
  - Log proses instalasi
  - Error installation
  - System checks

- **Node Log**: `~/gaianet/logs/node.log`
  - Status node
  - Error node
  - Performance metrics

- **Chat Log**: `~/gaianet/chat_logs.txt`
  - Chat history
  - Response AI
  - Timestamp

## 🛠️ Troubleshooting

### Node Tidak Start
1. Cek logs: `tail -f ~/gaianet/logs/node.log`
2. Pastikan port tidak terpakai
3. Cek resource system

### Auto Chat Error
1. Cek chat logs: `tail -f ~/gaianet/chat_logs.txt`
2. Pastikan node running
3. Cek koneksi internet

## 🤝 Kontribusi

Silakan berkontribusi dengan cara:
- Report bugs
- Feature request
- Pull request
- Dokumentasi

## 📜 Lisensi

MIT License - Bebas digunakan dan dimodifikasi.

## 📞 Support

- GitHub Issues
- Discord: [GaiaNet Community](https://discord.gg/gaianet)
- Telegram: [@GaiaNetSupport](https://t.me/gaianetsupport)
