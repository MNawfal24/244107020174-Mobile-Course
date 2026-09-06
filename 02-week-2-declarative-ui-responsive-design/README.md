# Laporan Praktikum Minggu 2 - Declarative UI & Responsive Design

---

## Identitas Mahasiswa

* **Nama:** Muhammad Nawfal Mawla Azhar
* **NIM:** 244107020174
* **Kelas:** 3G-TI

---

## 1. Warm-Up: Aplikasi Profil Sederhana

**Screenshot Hasil Run:**
> `<img src="ScreenShoot/Warmup_Normal.png" width="300">`

**menghapus Expanded pada baris nama**
`<img src="ScreenShoot/Warmup_1.png" width="300">`
**Penjelasan**
Jika Expanded di hilangkan dan nama terlalu panjang maka akan ada tanda garis kuning (overflow) di dalam kartu

**Ganti mainAxisSize: MainAxisSize.min**
`<img src="ScreenShoot/Warmup_2.png" width="300">`
**Penjelasan**
Jika Di Ganti dengan kode tersebut maka card akan memenuhi satu layar

**Menambahkan Email Di dalam Card**
`<img src="ScreenShoot/Warmup_3.png" width="300">`

---

## 2. Praktikum: DashboardApp & CupertinoSwitch

**Hasil dari run kode sebelum menggunakan StatefulWidget dan Cupertino**
 `<img src="ScreenShoot/Praktikum_1.png" width="300">`
 **Penjelasan**
 Disini Terlihat bahwa aplikasi tidak bisa digunakan untuk mengubah warna tema (gelap / terang)

 **Hasil Dari run kode setelah Menggunakan StatefulWidget dan Cupertino**
 `<img src="ScreenShoot/Praktikum_2.png" width="300">`
 **Penjelasan**
 Disini Terlihat bahwa aplikasi telah bisa digunakan untuk mengubah warna tema (gelap / terang) menggunakan tombol switch di atas

**Hasil Dari run Setelah breakpoint diubah menjadi 700**
 `<img src="ScreenShoot/Praktikum_3.png" width="300">`
 **Penjelasan**
 Bisa kita lihat jika Card akan berubah menjadi besar setelah diganti menjadi 700

 **Mengubah themeMode menajadi ThemeMode.dark lalu kembalikan ke ThemeMode.System**
  `<img src="ScreenShoot/Praktikum_2.png" width="300">`
  **Penjelasan**
  saat di ganti menjadi ThemeMode.dark maka tidak bisa di ganti ke dalam mode light, untuk ThemeMode.System sendiri warna dari tema daalam aplikasi mengikuti dari system device yang ada

**Melihat hasil Jika digunakan dalam ukuran yang berbeda (ukuran laptop)**
`<img src="ScreenShoot/Praktikum_4.png" width="300">`

**hasil dari Penambahan Semantics**
`<img src="ScreenShoot/Praktikum_5.png" width="300">`
**Penjelasan**
Tidak ada yang berbeda dalam UI tapi kode akan mempermudah untuk penggunaan orang yang memiliki  disabilitas tunanetra
---

