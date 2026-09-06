# Laporan Praktikum Minggu 2 - Declarative UI & Responsive Design

---

## Identitas Mahasiswa

* **Nama:** Muhammad Nawfal Mawla Azhar
* **NIM:** 244107020174
* **Kelas:** 3G-TI

---

## 1. Warm-Up: Aplikasi Profil Sederhana

**Screenshot Hasil Run:**

> ![ScreenShoot Hasil ui](Screeshoot/Warmup_Normal.png)

**menghapus Expanded pada baris nama**

> ![ScreenShoot Hasil ui](Screeshoot/Warmup_1.png.png)

**Penjelasan**
Jika Expanded di hilangkan dan nama terlalu panjang maka akan ada tanda garis kuning (overflow) di dalam kartu

**Ganti mainAxisSize: MainAxisSize.min**

> ![ScreenShoot Hasil ui](Screeshoot/Warmup_2.png)

**Penjelasan**
Jika Di Ganti dengan kode tersebut maka card akan memenuhi satu layar

**Menambahkan Email Di dalam Card**

> ![ScreenShoot Hasil ui](Screeshoot/Warmup_3.png)

---

## 2. Praktikum: DashboardApp & CupertinoSwitch

**Hasil dari run kode sebelum menggunakan StatefulWidget dan Cupertino**

> ![ScreenShoot Hasil ui](Screeshoot/Praktikum_1.png)

 **Penjelasan**
 Disini Terlihat bahwa aplikasi tidak bisa digunakan untuk mengubah warna tema (gelap / terang)

 **Hasil Dari run kode setelah Menggunakan StatefulWidget dan Cupertino**

> ![ScreenShoot Hasil ui](Screeshoot/Praktikum_2.png)

 **Penjelasan**
 Disini Terlihat bahwa aplikasi telah bisa digunakan untuk mengubah warna tema (gelap / terang) menggunakan tombol switch di atas

**Hasil Dari run Setelah breakpoint diubah menjadi 700**
> ![ScreenShoot Hasil ui](Screeshoot/Praktikum_3.png)

 **Penjelasan**
 Bisa kita lihat jika Card akan berubah menjadi besar setelah diganti menjadi 700

 **Mengubah themeMode menajadi ThemeMode.dark lalu kembalikan ke ThemeMode.System**

> ![ScreenShoot Hasil ui](Screeshoot/Praktikum_2.png)


  **Penjelasan**
  saat di ganti menjadi ThemeMode.dark maka tidak bisa di ganti ke dalam mode light, untuk ThemeMode.System sendiri warna dari tema daalam aplikasi mengikuti dari system device yang ada

**Melihat hasil Jika digunakan dalam ukuran yang berbeda (ukuran laptop)**

> ![ScreenShoot Hasil ui](Screeshoot/Praktikum_4.png)

**hasil dari Penambahan Semantics**

> ![ScreenShoot Hasil ui](Screeshoot/Praktikum_5.png)



**Penjelasan**
Tidak ada yang berbeda dalam UI tapi kode akan mempermudah untuk penggunaan orang yang memiliki  disabilitas tunanetra
---

## Tugas dan AI design exploration ##

**Hasil ScreenShoot Akhir**

> ![ScreenShoot Hasil ui](Screeshoot/TugasPraktikum.png)


**Refleksi**
1. Imperatif Fokus pada intruksi bagaimana mengubah antarmuka langkah demi langkah sedangkan Deklaratif fokus pada apa wujud antarmuka berdasarkan kondisi saat ini
2. Sangat membantu karena saat di letakkan di dalam parent widget yang memiliki batasan ukuran paseti (seperti row), Exoanded akan membagi dan mngisi sisa ruang kosong
3. Brekpoint Mencegah tampilan UI menjadi kacau saat diakses dari perangkat berbeda dengan memecah tata letah pada batas ukuran tertentu

  Theme memberikan kenyamanan visual dan personalisasi. Dukungan mode gelap sangat perlu untuk mengurangikelelahan mata
4. Verif Rekomendasi AI setelah tugas selesai
- Mengecek apakah kode yang dihasilkan bebeas dari error sintaks dan sejalan dengan alat analisis bawaan
- memvalidasi secara visual (tatak letak benar benar responsif)
- memsatikan AI tidak sengaja menghapus elemen penting atau merombak