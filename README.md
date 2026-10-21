# Arabiyah MTs

Proyek HTML, CSS, JavaScript tanpa proses build. Siap disimpan di GitHub dan diimpor ke Vercel. Backend menggunakan Supabase Auth, Postgres, dan private Storage. Tidak ada password guru bawaan.

## Coba dulu

Jalankan `python -m http.server 3000` dari folder proyek, kemudian buka http://localhost:3000. Tanpa konfigurasi, aplikasi menampilkan dua contoh materi kelas VII dan menyimpan progres demo di perangkat. Ruang guru memerlukan backend, bukan simulasi. Materi contoh belum mencakup satu semester. Minta guru bahasa Arab memeriksa materi sebelum penggunaan di kelas.

## Aktifkan penyimpanan bersama

1. Buat proyek Supabase baru melalui https://supabase.com/dashboard.
2. Buka SQL Editor. Salin seluruh `setup.sql` lalu jalankan sekali. File ini membuat tabel, kebijakan akses, dan bucket privat dengan batas 10 MB.
3. Buka Project Settings / API. Salin Project URL dan publishable key ke `config.js`. Keduanya konfigurasi publik. Jangan gunakan secret key atau service_role di frontend.
4. Buka Authentication / URL Configuration. Isi Site URL dengan alamat Vercel Anda. Tambahkan alamat pengembangan bila diperlukan.
5. Daftarkan akun guru melalui web. Konfirmasi email, lalu masuk. Semua pendaftaran awal memiliki akses siswa.
6. Di SQL Editor, jalankan perintah berikut dengan email guru yang benar:

```sql
insert into public.teachers(user_id)
select id from auth.users where email='guru@sekolah.sch.id';
```

7. Keluar lalu masuk kembali. Menu Ruang guru menampilkan formulir materi dan monitoring.
8. Guru menambahkan judul, kelas, isi, lampiran opsional, serta latihan opsional. Setiap latihan memiliki satu pertanyaan dan tiga pilihan.
9. Siswa mendaftar memakai email, mengonfirmasi email, lalu masuk. Saat pertama masuk, siswa mengisi nama dan kelas. Untuk siswa tanpa email, administrator dapat membuat akun melalui dashboard Auth sesuai kebijakan sekolah.

Supabase mungkin membatasi pengiriman email bawaan. Atur SMTP sekolah untuk penggunaan kelas yang lebih luas. Jika email konfirmasi belum datang, cek spam dan konfigurasi Auth.

## GitHub dan Vercel

1. Ekstrak ZIP ini. Buat repository baru di GitHub.
2. Unggah seluruh isi folder `arabiyah-mts`, termasuk index.html, app.js, style.css, config.js, vercel.json, dan setup.sql. Jangan unggah ZIP sebagai satu-satunya isi repository.
3. Pada Vercel, pilih Add New / Project, lalu impor repository.
4. Pilih framework Other. Root Directory adalah folder yang langsung berisi index.html. Tidak perlu install command atau build command. Output Directory `.`.
5. Deploy. Masukkan alamat hasil deploy ke Site URL Supabase.
6. Perubahan file di repository akan memicu deploy berikutnya sesuai integrasi GitHub Vercel.

## Fitur dan batas

- Materi untuk kelas VII, VIII, IX, dengan penyaringan kelas.
- Unggah PDF, PNG, JPG, MP3, MP4 maksimal 10 MB. Lampiran terbuka melalui tautan sementara 10 menit. Buka ulang materi jika tautan kedaluwarsa.
- Materi teks dan satu pertanyaan pilihan ganda per materi.
- Progres selesai, nilai percobaan terakhir, aktivitas terakhir, ringkasan guru, filter kelas, dan ekspor CSV.
- Guru menekan Perbarui data untuk mengambil progres terbaru. Bukan pemantauan otomatis secara langsung.
- Siswa menandai selesai sendiri. Browser menghitung nilai latihan. Jangan gunakan nilai ini untuk ujian resmi atau pencegahan kecurangan karena siswa dapat memeriksa kode dan mengirim progres miliknya sendiri.
- Lingkup satu madrasah: seluruh akun terdaftar dapat membaca semua materi; guru terdaftar dapat membaca profil dan progres seluruh siswa. Filter kelas hanya mengatur tampilan. Aplikasi belum mendukung isolasi banyak madrasah, rombel, atau penugasan guru per kelas.
- Dashboard menghitung progres berdasarkan materi untuk kelas pada profil siswa. Materi baru menambah pembagi sehingga persentase dapat turun.
- Profil awal diisi sekali. Admin dapat memperbaiki nama/kelas melalui Table Editor. Belum tersedia editor profil, lupa kata sandi, ubah/hapus materi, audio pelafalan bawaan, atau rekaman suara siswa.
- Token sesi disimpan di sessionStorage dan disegarkan saat permintaan berikutnya. Tutup tab atau keluar setelah memakai komputer bersama.
- Schema membatasi siswa pada progres sendiri dan penambahan materi pada akun guru. Siswa tidak bisa menaikkan peran melalui formulir. Promosi guru hanya melalui SQL administrator.

## Pemeriksaan sebelum dipakai siswa

Kode JavaScript telah melewati pemeriksaan sintaks. Backend, pengiriman email, upload, kebijakan database, dan deploy belum dapat diuji dengan proyek Supabase nyata pada paket ini karena belum ada URL/key proyek Anda. Setelah konfigurasi, lakukan uji berikut dengan akun guru dan dua akun siswa:

1. Siswa A menandai materi selesai dan menjawab kuis; guru melihat progres sesudah Perbarui data.
2. Siswa B tidak dapat membaca atau mengubah baris progres A melalui REST API, tetapi guru dapat membacanya.
3. Permintaan insert materi dari akun siswa harus ditolak, termasuk ketika formulir guru ditampilkan melalui DevTools.
4. Unggah PDF sebagai guru. Buka lampiran dari perangkat siswa lain. Pastikan file terlalu besar atau MIME yang tidak diizinkan ditolak.
5. Pastikan pengguna tanpa login tidak dapat membaca data tabel atau lampiran privat.
6. Ekspor CSV dan cocokkan dengan dashboard. Periksa tampilan pada ponsel.

Rujukan integrasi: https://supabase.com/docs/guides/auth/passwords dan https://supabase.com/docs/guides/storage/security/access-control.
