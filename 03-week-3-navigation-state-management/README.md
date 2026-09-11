# Laporan Praktikum Minggu 3 - Navigation state Management

---

## Identitas Mahasiswa 
* **Nama:** Muhammad Nawfal Mawla Azhar
* **NIM:** 244107020174
* **Kelas:** 3G-TI

---

## 1. Aplikasi Multi page dengan GoRouter

**Screenshot Hasil Run:**

ScreenShoot Page Home :
> ![ScreenShoot Hasil Multi Page dengan Router (home)](ScreenShoot/Praktikum1_home.png)

ScreenShoot Page Detail:
> ![ScreenShoot Hasil Multi Page dengan Router (detail)](ScreenShoot/Praktikum1_detail.png)

## 2. Aplikasi ToDo dengan Riverpod

ScreenShoot Page Home :
> ![ScreenShoot Hasil Aplikasi ToDo (home)](ScreenShoot/Praktikum2_home.png)

ScreenShoot Page Detail:
> ![ScreenShoot Hasil Aplikasi ToDo (detail)](ScreenShoot/Praktikum2_Tambah.png)

## 3.  asyncValue: Loading, error, success

> ![ScreenShoot Hasil Run Sukses](ScreenShoot/Praktikum3_sukses.png)
**Penjelasan**
Saat Menjalankan Aplikasi Usera kaan melihat lingkarn loading berputar selama beberapa detik lalu memunculkan daftar barang (keyboard, mouse dan monitor)

> ![ScreenShoot Hasil Run gagal](ScreenShoot/Praktikum3_gagal.png)
**Penjelasan**
Saat (return[keyboard...]) di ganti menjadi Throw exception('gagal terhubung ke server'), maka akan memunculkan pesan yang menunjukan  gagal memuat

> ![ScreenShoot Hasil Run Recovery gagal](ScreenShoot/Praktikum3_sukses.png)
**Penjelasan**
Saat Mengeklik tombol muat ulang di dalam aplikasi maka akan terload kembali barang yang ada (mouse, keyboard dan komputer)

**Penjelasan Refleksi  (poin4)**
Hal tersebut berkaitan dengan User Experince, Mengosongkan layar dan menggantinya dengan ikon loading  besar di tengah layar akan membuat pengguna merasa terganggu dan kehilangankonteks apa yangsedang mereka baca, Dengan membiarkan data lama tetap terlihat sambil menampilkan indikator loading kecil di atas, pengguna bisa membaca konten sebelumnya meskipun aplikasi sedangmengambil data terbaru


## 4. AI Challenge

**Apakah state diubah secara immutable?**

Ya. Kode AI tidak melakukan mutasi langsung (misalnya state.value.add()). State selalu diganti dengan instansiasi AsyncValue baru melalui baris state = const AsyncValue.loading() dan state = await AsyncValue.guard(...).

**Apakah ref.watch hanya dipakai di dalam build, dan ref.read di callback?**

Ya. Pemantauan data dilakukan menggunakan ref.watch(statsProvider) murni di dalam metode build(). Sementara itu, aksi klik tombol retry menggunakan ref.read(statsProvider.notifier).retry() di dalam callback onPressed.

**Apakah ketiga state AsyncValue benar-benar ditangani?**

Ya. Metode statsAsyncValue.when() mendefinisikan dengan jelas blok loading: (mengembalikan spinner), blok error: (mengembalikan icon gagal, pesan error, dan tombol retry), serta blok data: (mengembalikan daftar ListView).

**Apakah provider dideklarasikan dengan tipe eksplisit?**

Ya. Provider ditulis menggunakan spesifikasi <StatsNotifier, List<String>> yang kokoh, sehingga tipe datanya jelas dan tidak ambigu.

**Apakah kode AI memakai API Riverpod versi lama?**

Tidak. Kode sudah menggunakan AsyncNotifier dan AsyncNotifierProvider yang merupakan standar modern (versi terbaru Riverpod 2.0+), meninggalkan StateNotifierProvider yang sudah mulai usang.

## 5. Refactoring and Testing


> ![ScreenShoot Hasil Run Sukses](ScreenShoot/Praktikum5_kode1.png)

> ![ScreenShoot Hasil Run Sukses](ScreenShoot/Praktikum5_kode2.png)


## 6. Tugas, Refleksi dan referensi