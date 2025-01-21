# GaiaNet Node  🌍

Script ini membantu Anda menjalankan node Gaia di VPS atau komputer lokal dengan memudahkan proses instalasi, konfigurasi, dan monitoring node.

## ⭐ Fitur Utama

- 🚀 **One-Click Installation** - Instalasi node Gaia secara otomatis
- 🖥️ **Screen Management** - Menjalankan node dalam screen session
- 📊 **Monitoring** - Pemantauan status dan logs node
- 🤖 **Auto Chat** - Fitur auto chat dengan Gaia AI menggunakan keyword
- 🔄 **Auto-Restart** - Restart otomatis jika node berhenti

## 💻 Persyaratan Sistem

- **OS**: Ubuntu/Debian Linux
- **RAM**: Minimal 4GB
- **Storage**: 20GB free space
- **Software**:
  - Python 3.7+
  - Screen
  - Git

*Note: Package Python yang diperlukan akan diinstal otomatis oleh script*

## 🛠️ Cara Instalasi

1. Clone repository:
```bash
git clone https://github.com/gorogith/GaiaNet-Node.git
cd GaiaNet
```

2. Beri permission pada script:
```bash
chmod +x gaia.sh
```

## 📖 Cara Penggunaan

1. Jalankan script:
```bash
./gaia.sh
```

2. Pilih menu yang tersedia:
- 1️⃣ Install Gaia Node
- 2️⃣ Start Node
- 3️⃣ Stop Node
- 4️⃣ Check Node Status
- 5️⃣ View Node Logs
- 6️⃣ Show Node Info
- 7️⃣ Remove Node
- 8️⃣ Start Auto Chat
- 9️⃣ Stop Auto Chat
- 🔟 Check Auto Chat Status
- ⏹️ Exit

### 🤖 Menggunakan Auto Chat

1. Pastikan node sudah terinstall dan berjalan (menu 1 dan 2)
2. Pilih menu 8 untuk memulai auto chat dalam screen session
3. Script akan otomatis:
   - Mengecek dan menginstal package Python yang diperlukan
   - Membaca keyword dari file keyword.txt
   - Menjalankan auto chat dalam screen session 'gaia-auto-chat'
   - Mengirim chat ke Gaia AI dengan delay 30 detik
   - Menampilkan response dari AI

### 📺 Mengelola Screen Auto Chat

- **Melihat Auto Chat**: `screen -r gaia-auto-chat`
- **Keluar dari Screen**: Tekan `Ctrl+A`, lalu `D`
- **Menghentikan Auto Chat**: 
  - Melalui menu: Pilih menu 9
  - Manual: `screen -S gaia-auto-chat -X quit`
- **Cek Status Auto Chat**: 
  - Melalui menu: Pilih menu 10
  - Manual: `screen -list | grep gaia-auto-chat`

*Note: Anda dapat memodifikasi keyword.txt untuk mengubah daftar pertanyaan yang akan dikirim ke AI*

## 📝 Catatan Penting

- Pastikan Node ID sudah terkonfigurasi dengan benar
- Auto chat akan dimulai dari index ke-11 dalam file keyword
- Ada delay 30 detik antara setiap pengiriman chat untuk menghindari rate limiting
- Auto chat berjalan dalam screen session terpisah sehingga tetap aktif meskipun terminal ditutup
- Untuk melihat output auto chat, gunakan perintah screen yang tersedia
