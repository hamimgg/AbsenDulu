## **Tugas 15 Flutter: Autentikasi & CRUD Profile via API**

### **1\. Tujuan Pembelajaran**

* **Write Operations:** Peserta mampu melakukan pengiriman data ke server menggunakan metode **POST** (Register/Login) dan **PUT** (Update Profile).  
* **Token-Based Auth:** Memahami cara menangkap dan menggunakan *Bearer Token* dari API untuk mengakses data yang diproteksi.  
* **State Management:** Mengelola perubahan data profil secara dinamis menggunakan `TextEditingController` dan `setState`.  
* **Secure Networking:** Mengimplementasikan *Headers* pada request HTTP untuk menyertakan otorisasi.

### **2\. Makna Tugas**

Hampir seluruh aplikasi profesional memerlukan fitur akun pengguna. Tugas ini mensimulasikan alur nyata pendaftaran pengguna, proses masuk (*login*), hingga perubahan profil mandiri. Peserta akan belajar bahwa data di internet bersifat privat, sehingga diperlukan "kunci" (token) untuk membaca atau mengubah informasi tersebut.

### **3\. Instruksi Umum**

Bangunlah aplikasi Flutter yang terhubung dengan server **MobilePro** untuk mengelola data akun. Pastikan alur navigasi berjalan sesuai dengan urutan proses autentikasi yang benar.

**Wajib Menggunakan:** Package `dio`, `FutureBuilder`, dan API Endpoint yang telah disediakan.

---

### **4\. Detail Teknis & Alur Tugas**

**🔗 API Dasar:** [`Link API`](https://drive.google.com/file/d/1W71bDRaEp-HcJUlfkY9s5-3bod8VulPm/view?usp=sharing) *(Dokumentasi lengkap silakan merujuk pada link Postman yang dibagikan berikut)*

[https://drive.google.com/file/d/1W71bDRaEp-HcJUlfkY9s5-3bod8VulPm/view?usp=sharing](https://drive.google.com/file/d/1W71bDRaEp-HcJUlfkY9s5-3bod8VulPm/view?usp=sharing)

Link URL : [https://appabsensi.mobileprojp.com](https://appabsensi.mobileprojp.com)

#### **Alur Kerja Aplikasi (User Flow):**

1. **Register**: User mengisi form pendaftaran (Nama, Email, Password, Jenis Kelamin, Profile Photo, Batch ID, dan Training ID) dan mengirimkan data ke endpoint registrasi (POST /api/register).  
2. **Login**: User masuk menggunakan Email dan Password yang telah didaftarkan ke endpoint (POST /api/login) untuk mendapatkan Token otentikasi.  
3. **Get Profile**: Setelah login berhasil, aplikasi mengambil data profil pengguna berdasarkan token tersebut (menggunakan otentikasi *Bearer Token*) melalui endpoint (GET /api/profile) dan menampilkannya di halaman utama.  
4. **Edit Profile**: User dapat mengubah informasi nama profil melalui form edit, yang kemudian datanya dikirim kembali ke server melalui endpoint (PUT /api/profile).  
5. **Edit Profile Photo**: User dapat memperbarui foto profil mereka dengan mengirimkan data gambar dalam format base64 ke server melalui endpoint (PUT /api/profile).

### **5\. Checklist Implementasi**

| Fitur | Spesifikasi Teknis |
| :---- | :---- |
| **Form Login & Register** | Gunakan TextFormField dengan validasi. Kirim data menggunakan Dio. |
| **Auth Handling** | Simpan token yang didapat dari response login ke dalam variabel global atau *State*. |
| **Profile Dashboard** | Tampilkan data user (Nama, Email, dll) menggunakan FutureBuilder. Tambahkan *Header* Authorization pada request. |
| **Update Profile** | Gunakan metode http.put untuk mengirimkan perubahan data ke server. |
| **Modern UI** | Tampilkan *Loading Spinner* saat proses request berlangsung agar pengguna tahu aplikasi sedang bekerja. |

### **6\. Bonus / Tantangan (Opsional)**

* **Detail User:** Tambahkan navigasi untuk melihat detail informasi akun secara lebih lengkap.  
* **Clean UI:** Gunakan desain yang modern dengan *Custom Shapes*, *Shadows*, dan skema warna yang menarik.  
* **Token Persistence:** (Advanced) Coba gunakan package `flutter_secure_storage` agar user tidak perlu login ulang saat aplikasi ditutup.

