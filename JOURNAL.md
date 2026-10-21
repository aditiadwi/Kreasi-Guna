# 📝 Jurnal Pengembangan: Smart Drip Coffee (Evolution to V2)

### **1. Deskripsi Proyek**
Membangun platform e-commerce kopi premium (Smart Drip Coffee) yang mengintegrasikan pusat data cloud, manajemen inventaris otomatis, dan dashboard analitik visual. Proyek ini berevolusi dari landing page statis menjadi aplikasi web dinamis berskala produksi.

---

### **2. Tech Stack & Ekosistem (V2 Upgrade)**
*   **Frontend:** HTML5, CSS3 (Custom Properties & Responsive Grid), JavaScript (Vanilla ES6+).
*   **Backend & Database (BaaS):** 
    *   **Supabase:** Menggantikan `localStorage` sebagai database utama (PostgreSQL). Menangani persistensi data untuk Produk, Pesanan, Event, dan Feedback.
*   **API & Service Integration:** 
    *   **Cloudinary:** Penyimpanan bukti pembayaran melalui *Unsigned Uploads*.
    *   **EmailJS:** Notifikasi email transaksional dua sisi (untuk admin/penjual menggunakan `template_32knsih` dan pembeli/customer menggunakan `template_vsn07oo`).
    *   **Google Chart/Chart.js:** Visualisasi data statistik di dashboard admin.
*   **State Management:** LocalStorage digunakan secara strategis untuk *Form Persistence* dan *Cart State*.

---

### **3. Milestone Fitur Utama (Detail)**

#### **A. Dynamic Cloud Infrastructure (Database)**
*   **Schema Design:** Membangun relasi data untuk melacak penjualan.
*   **Autopilot Inventory:** Implementasi logika *atomic update* di mana stok produk berkurang secara otomatis seketika setelah transaksi divalidasi oleh sistem.
*   **Data Integrity:** Menggunakan SQL Repair scripts untuk memastikan skema database (kolom, tipe data) selalu sinkron dengan logika bisnis di frontend.

#### **B. Advanced Admin Dashboard (Control Center)**
*   **Visual Business Intelligence:** 
    *   Implementasi grafik garis interaktif untuk memantau tren pesanan harian.
    *   Algoritma penghitung "Best Seller" yang secara otomatis mengurai (parsing) data pesanan untuk menentukan produk terpopuler.
*   **Unified Management (All-in-One):**
    *   **Product CRUD:** Kontrol penuh atas nama, harga, stok, dan lokasi gambar.
    *   **Order Intelligence:** Detail pesanan mendalam termasuk rincian kurir, catatan pembeli, dan verifikasi bukti bayar visual.
    *   **Data Export:** Fitur "Download Excel (CSV)" untuk ekspor laporan penjualan dengan format yang dioptimalkan (BOM & Auto-Separator).
    *   **Feedback Moderation:** Sistem kurasi ulasan pelanggan sebelum dipublikasikan ke publik.
    *   **Live Event Controller:** Fitur untuk mengaktifkan/menonaktifkan pengumuman stand bazar secara real-time.

#### **C. Customer Experience (UX) Engineering**
*   **Private Order Tracking:** Sistem pelacakan pesanan berbasis Order ID unik, memastikan privasi antar pembeli tetap terjaga tanpa mewajibkan registrasi akun (User-friendly).
*   **Form Auto-Save:** Mencegah kehilangan data input pembeli saat halaman ter-refresh secara tidak sengaja melalui sinkronisasi *Real-time LocalStorage*.
*   **Visual Validation:** Memberikan *instant feedback* (highlight merah & pesan error) saat pengguna salah memasukkan format email atau nomor telepon.
*   **Dual-Receipt Email Notification:** Mengirimkan salinan detail pesanan secara otomatis baik ke penjual (admin) maupun pembeli (customer) sesaat setelah transaksi checkout dilakukan menggunakan API EmailJS.
*   **User Geolocation Auto-Fill:** Tombol "Gunakan Lokasi Terkini" pada formulir alamat checkout yang mendeteksi koordinat GPS pengguna secara otomatis menggunakan HTML5 Geolocation API, menerjemahkannya ke nama jalan/kota nyata menggunakan Nominatim API (reverse geocoding), lalu otomatis mengisi kolom alamat dan kota tujuan (yang secara otomatis memperbarui ongkos kirim).

---

### **4. Technical Challenges & Engineering Solutions**

| Masalah | Analisis Teknis | Solusi Engineering |
| :--- | :--- | :--- |
| **Database Schema Drift** | Perubahan kolom di Supabase sering terhambat oleh *cache* atau inkonsistensi tipe data (Array vs Text). | Implementasi **Master Fix SQL** (Drop & Recreate) untuk memastikan skema tabel 100% akurat. |
| **JS Reference Errors** | Penambahan library eksternal (CDN) sering menyebabkan tabrakan variabel atau fungsi yang tidak terdefinisi (*null*). | Menggunakan **Global Namespace (window.object)** dan *Safety Checks* (if-existence) pada setiap manipulasi DOM. |
| **UI Scalability** | Modal detail pesanan yang sangat panjang menyebabkan elemen penting (tombol update) terpotong di layar kecil. | Implementasi **Flexbox Modal Layout** dengan area scroll internal yang terisolasi (*Fixed Header & Footer*). |
| **Image Fallback** | Link gambar yang salah atau terhapus merusak estetika website (ikon broken image). | Penambahan event listener **onerror** pada elemen `<img>` untuk otomatis memuat gambar *placeholder* default. |
| **Accidental Deletion** | Menghapus data penting (produk/pesanan) tanpa sengaja dapat merusak laporan keuangan. | Implementasi **Confirmation Prompts** dengan pesan dinamis yang menyebutkan nama item sebelum proses `DELETE` dilakukan. |
| **Excel CSV Mess** | File CSV seringkali tidak terformat rapi (berantakan) saat dibuka di Microsoft Excel. | Penambahan **UTF-8 BOM** dan instruksi `sep=,` agar Excel otomatis mengenali kolom dan karakter spesial secara rapi. |
| **Dual Email Notification** | Kebutuhan untuk mengirim bukti pemesanan ke dua pihak secara independen (penjual dan pembeli) dengan template/tujuan yang berbeda menggunakan batasan EmailJS gratis. | Konfigurasi pemanggilan API ganda (`emailjs.send`) dengan memisahkan template admin (`template_32knsih`) dan template pembeli (`template_vsn07oo`) yang dinamis berdasarkan input email pembeli. |
| **User Address Entry & Autocomplete** | Pengguna seringkali kesulitan menuliskan alamat lengkap secara manual secara presisi, yang dapat memengaruhi keakuratan pengiriman dan ongkos kirim. | Integrasi tombol "Gunakan Lokasi Terkini" menggunakan **HTML5 Geolocation API** dan **OpenStreetMap Nominatim Reverse Geocoding API** untuk mengisi textarea alamat lengkap dan select dropdown kota secara instan. |
| **CSS Pollution & Conditional Deletion** | Class `.btn-delete` global di `style.css` menyembunyikan semua tombol hapus admin secara tidak sengaja karena bentrok nama. Selain itu, tombol hapus pesanan tidak terfilter sehingga bisa memicu penghapusan pesanan aktif. | Menyesuaikan selector di `style.css` menjadi `.testimonial-card .btn-delete` agar terisolasi, serta mengkondisikan tombol hapus pesanan di `admin.html` agar hanya dirender untuk pesanan berstatus `'CANCELLED'`. |
| **WhatsApp Floating Button & Contact Redirection** | Tombol WA melayang tidak ada di halaman pelacakan/sejarah. Selain itu, tautan email (`mailto:`) sering membuka tab kosong baru yang tidak menutup otomatis jika tidak memiliki klien email lokal. | Menambahkan tombol WA melayang di semua halaman. Mengubah alur tombol kontak Email menggunakan fungsi `handleEmailClick()` di `app.js` untuk otomatis menyalin alamat email ke clipboard dan mengarahkan ke halaman tulis Gmail Web secara aman. |
| **Contact Form split Email/WhatsApp** | Kebutuhan untuk memproses pesan formulir kontak lewat EmailJS (masuk ke kotak masuk email) sambil menyediakan opsi obrolan cepat langsung ke WhatsApp. | Memisahkan form kontak menjadi dua opsi tombol: Tombol Submit (`✉️ Kirim ke Email`) yang memicu pengiriman data via EmailJS, dan Tombol Shortcut (`💬 Hubungi via WhatsApp`) yang memvalidasi form lalu menyusun pesan teks terformat ke API WhatsApp. |
| **WhatsApp SVG Logo Accuracy** | Ikon WA sebelumnya adalah siluet putih dasar yang rentan terpotong oleh CSS `overflow: hidden` di beberapa browser dan kurang menyerupai logo resmi WhatsApp. | Mengganti SVG siluet dengan SVG resmi WhatsApp bertumpuk 2-lapisan (balon chat whites + lingkaran hijau & telepon cut-out), serta membersihkan batasan overflow pada CSS untuk rendering yang 100% presisi. |
| **Account Session Cart, Profile & Order History Isolation** | Menggunakan kunci global (`coffee_cart`, `checkout_form_data`, `customer_profile`, dan `recent_orders`) di `localStorage` membuat data keranjang, autofill alamat, dan riwayat pelacakan pesanan milik pengguna sebelumnya bocor ke pengguna lain yang login di browser/perangkat yang sama. | Mengubah seluruh kunci tersebut menjadi dinamis berdasarkan ID sesi aktif Supabase (`*_userId`). Ketika user melakukan login/logout atau ganti akun, sistem secara otomatis memuat ulang keranjang belanja, memperbarui profil autofill, dan menampilkan daftar nomor pelacakan pesanan (`recent_orders`) yang sesuai secara terisolasi. Selain itu, saat melakukan logoff (logout), seluruh data guest akan dihapus bersih (reset) agar sesi guest berikutnya dimulai dengan form & keranjang kosong tanpa sisa data akun sebelumnya. |
| **Mobile Burger Menu Scroll Clipping** | Pada layar HP / landscape, hamburger menu yang terbuka (`.nav-links`) tidak bisa di-scroll jika item menu melebihi tinggi layar, serta `justify-content: center` memotong bagian atas menu. Selain itu, scroll layar background tetap aktif. | Mengubah alignment menu ke `justify-content: flex-start`, menambahkan `overflow-y: auto`, `max-height: 100dvh`, serta `padding-top: 100px`. Menambahkan class `body.menu-open { overflow: hidden; }` saat menu aktif untuk mengunci scroll halaman utama di belakangnya. |
| **Mobile & Tablet 2-Column Product Layout** | Tampilan katalog produk (`.product-grid`) di perangkat mobile sebelumnya hanya menampilkan 1 produk per baris (1 kolom vertikal), memaksa pengguna melakukan scroll sangat panjang. | Mengubah sistem grid CSS responsif menjadi 2 kolom (`grid-template-columns: repeat(2, 1fr)`), serta menyesuaikan proporsi padding kartu, ukuran font judul, harga, dan tombol *Add to Cart* agar tampil presisi dan compact di layar HP/tablet. |
| **Checkout Stock Transparency & Real-time Limit** | Pada halaman checkout, fitur *Quick-Add* ("Tambah Produk Lain") dan daftar keranjang tidak menampilkan jumlah stok yang tersedia, sehingga pembeli tidak tahu berapa sisa stok dan bisa bingung jika mencoba menambah barang melebihi stok. | Menambahkan badge info stok real-time (`Stok: X unit` / `Sisa X unit`), menampilkan indikator stok di rincian keranjang, serta menonaktifkan tombol `➕ Tambah` otomatis (menjadi `🚫 Habis`) ketika batas stok maksimal dalam keranjang tercapai. |
| **Checkout UI Redundancy Cleanup** | Komponen `payment-area` menampilkan blok duplikat `Total Amount to Pay` yang persis sama dengan nilai `Total` di atasnya, membuat sidebar ringkasan belanja terpotong dan terlalu tinggi (*cluttered*). | Menghapus blok duplikat `payment-amount-display` di `checkout.html`, membuat alur dari `Final Summary` langsung menuju pilihan pembayaran & formulir bukti transfer dengan bersih dan intuitif. |
| **Active Navigation Menu Link Highlight (UX)** | Pengguna tidak dapat mengetahui halaman mana yang sedang mereka buka karena tautan menu di header/navbar (`.nav-links`) tidak memiliki penanda visual aktif (*active indicator*). | Mengimplementasikan pendeteksian otomatis URL halaman aktif di `app.js` yang memberikan class `active`. Menambahkan garis penanda emas (*gold indicator bar*) di desktop dan badge latar belakang *soft gold* pada drawer menu HP. |
| **Page Navigation Delay (0.5s) & White Flash** | Navigasi antar halaman HTML (Multi-Page App) terasa ada jeda 0.5 detik dan kedipan putih (*white flash*) karena browser memuat ulang seluruh resource dari nol saat link diklik. | Menambahkan **Native View Transitions API** (`@view-transition { navigation: auto; }`) di `style.css` untuk animasi *cross-fade* mulus 0.2s, serta mengimplementasikan **Smart Hover Link Prefetching** di `app.js` untuk memuat HTML di latar belakang saat kursor menyentuh menu. |
| **Home Page Featured Selection Products Loading** | Bagian "Featured Selection" di `index.html` tidak menampilkan daftar produk karena tag script Supabase menggunakan atribut `defer`, menyebabkan `typeof supabase` bernilai `undefined` saat `app.js` mengeksekusi inisialisasi awal. | Menghapus atribut `defer` dari tag script Supabase di `index.html` & `about.html`, membuat fungsi inisialisasi `initSupabase()` yang tangguh (*lazy-loaded*) di `app.js`, serta memastikan `renderFeaturedProducts()` selalu dipanggil setelah data produk Supabase berhasil dimuat. |
| **Coffee News Quality Filtering & Image Fallback** | Beberapa artikel dari NewsAPI menampilkan gambar rusak/hilang, tautan 404, atau artikel terhapus bertuliskan `[Removed]`. | Mengimplementasikan **Article Quality Filter** di `getCoffeeNews()` untuk membuang artikel mati/terhapus, menambahkan **Fallback Image Handler** (`onerror`) dengan foto kopi HD Unsplash di `displayNews()`, serta memperbarui daftar `MOCK_COFFEE_NEWS` dengan artikel kopi terverifikasi dan berbahasa Indonesia yang edukatif. |
| **Approved Testimonials / Feedback on Home Page** | Ulasan pelanggan yang disetujui Admin sebelumnya hanya muncul di `about.html`, membuat calon pembeli di `index.html` (Home) tidak langsung melihat ulasan positif. | Menambahkan komponen **What Our Brewers Say** di `index.html` di bawah bagian *Our Mission*, menyesuaikan `renderTestimonials()` di `app.js` agar memuat ulasan yang disetujui Admin (*is_approved = true*) secara dinamis pada halaman Home, serta mempercantik tata letak kartu ulasan di `style.css`. |
| **Feedback Redundancy & Admin Evaluation Archive with Pagination** | Menampilkan ulasan publik di `about.html` terasa duplikat karena sudah dipindah ke Home (`index.html`). Selain itu, Admin belum memiliki cara untuk memfilter masukan/kritik buruk (rating ≤ 3) dan mengatur jumlah ulasan per halaman jika jumlah ulasan membengkak. | Menghapus `testimonials-section` dari `about.html`. Menambahkan fitur **Quick Stats**, **Dropdown Filter Tampilan**, **Dropdown Limit (10, 25, 50, 100, Semua)**, serta **Tombol Pagination Halaman (Next, Prev, Halaman 1, 2, dst)** dan **Highlight Visual** (`⚠️ Evaluasi Produk`) pada tabel Feedback di `admin.html`. |
| **Testimonial Card Modern Header-Layout & Compact Sizing** | Layout kartu ulasan publik sebelumnya menaruh bintang rating di paling atas dan nama pengulas di paling bawah dengan ukuran kartu yang agak terlalu lebar. Jika ulasan hanya ada 1 item, kartu melebarkan ukurannya melintasi seluruh grid (stretching). | Memperbarui `renderTestimonials()` di `app.js` dengan struktur header terpisah (**Nama Pengulas** & **Rating ★** di atas, pesan di bawah). Mengunci batas lebar maksimal kartu (`max-width: 360px`), menambahkan `justify-content: center` pada grid CSS di `style.css` sehingga bila ulasan hanya berjumlah 1 (atau 2), kartu tetap berukuran ideal dan berada terpusat di tengah halaman Home. |

---

### **5. Kesimpulan & Status Proyek**
Sistem **Smart Drip V2** saat ini dalam status **Stable**. Arsitektur telah siap untuk menangani trafik nyata dengan manajemen data yang terpusat dan aman di cloud.

*Update Terakhir: 7 Agustus 2026*

---

### **6. Recent Updates (12 Agustus 2026)**

| Fitur | Deskripsi Detail | File Terkait |
| :--- | :--- | :--- |
| **Product Card Enhancement** | Setiap kartu produk kini menampilkan: gambar produk (fixed 250px height, object-fit: cover agar proporsi konsisten), nama produk, rating bintang (dari review), harga dalam Rupiah, stok tersedia, tombol **"See Description"** (buka modal detail), dan tombol **"Add to Cart"**. Gambar produk diseragamkan ukurannya agar grid rapi. | `app.js`, `style.css`, `products.html` |
| **Product Detail Modal** | Klik "See Description" membuka modal slide-up dengan: gambar produk besar (350px max), nama produk, harga, status stok (tersedia/habis), deskripsi lengkap (dari field `description` di Supabase, fallback ke "No description available"), dan tombol **"Add to Cart"** yang sekaligus menutup modal dan menambah item ke keranjang. Modal responsif: desktop 2 kolom (gambar kiri, detail kanan), mobile 1 kolom vertikal. | `app.js`, `style.css` |
| **Dedicated Cart Page (`cart.html`)** | Halaman keranjang baru (`cart.html`) dengan layout 2 kolom: kiri daftar item (gambar 80px, nama, harga, subtotal, kontrol +/- qty, tombol hapus), kanan ringkasan order (subtotal, total, tombol **"Checkout Now →"** ke `checkout.html`, link **"← Continue Shopping"**). Empty state menampilkan ikon keranjang kosong + tombol belanja. | `cart.html`, `app.js`, `style.css` |
| **Cart Icon in Nav** | Ikon keranjang (SVG) ditambahkan di header navigation (posisi sebelum item "Track") di **semua halaman**. Badge merah di kanan atas menampilkan jumlah total item, update real-time via `localStorage` per user session. Ikon highlight (emas) saat berada di halaman `cart.html`. | `products.html`, `checkout.html`, `index.html`, `about.html`, `history.html`, `brew.html`, `contact.html`, `track.html`, `app.js` |
| **Removed Cart from Products Page** | Bagian "Your Cart" (daftar item, subtotal, grand total, tombol Proceed to Checkout) dihapus total dari `products.html`. Halaman produk kini fokus murni pada katalog (product grid). Checkout dipindah ke halaman terpisah `cart.html` → `checkout.html`. | `products.html` |
| **Toast Notification** | Notifikasi toast muncul dari **kanan atas** (slide-in) saat user klik "Add to Cart": teks `"[Nama Produk] added to cart"`, background gelap, teks putih, rounded, shadow. Auto-hilang setelah 2.5 detik dengan animasi slide-out. Menggunakan `cubic-bezier` untuk efek bounce halus. | `app.js`, `style.css` |
| **Cart Badge Auto-Update** | Fungsi `updateCartBadge()` dipanggil di: `renderCart()` (setiap add/update/remove), `loadUserSpecificState()` (saat login/switch user), dan `DOMContentLoaded` (init halaman). Badge sembunyi (`display: none`) saat keranjang kosong. | `app.js` |
| **Consistent Image Sizing** | Gambar produk di kartu menggunakan `height: 250px; object-fit: cover; object-position: center` (desktop) dan `height: 160px` (mobile ≤768px). **Dihapus** class padding per-tipe (`img-box`, `img-sachet`, `img-pouch`) dan transform scale hover yang tidak konsisten. Semua gambar kini crop center seragam. | `style.css` |
| **Button Alignment Fix** | Tombol "See Description" & "Add to Cart" dibungkus `<div class="card-actions">` dengan `margin-top: auto` + `display: flex; flex-direction: column; gap: 10px`. Memastikan kedua tombol selalu **align di bawah kartu** (sticky bottom) meski nama produk beda panjang (1 vs 2 baris) atau rating beda. | `app.js`, `style.css` |
| **Home Page Featured Selection Products Loading** | Bagian "Featured Selection" di `index.html` tidak menampilkan daftar produk karena tag script Supabase menggunakan atribut `defer`, menyebabkan `typeof supabase` bernilai `undefined` saat `app.js` mengeksekusi inisialisasi awal. | `index.html`, `app.js` |
| **Coffee News Quality Filtering & Image Fallback** | Beberapa artikel dari NewsAPI menampilkan gambar rusak/hilang, tautan 404, atau artikel terhapus bertuliskan `[Removed]`. | `app.js` |
| **Approved Testimonials / Feedback on Home Page** | Ulasan pelanggan yang disetujui Admin sebelumnya hanya muncul di `about.html`, membuat calon pembeli di `index.html` (Home) tidak langsung melihat ulasan positif. | `index.html`, `app.js`, `style.css` |
| **Feedback Redundancy & Admin Evaluation Archive with Pagination** | Menampilkan ulasan publik di `about.html` terasa duplikat karena sudah dipindah ke Home (`index.html`). Selainnya, Admin belum memiliki cara untuk memfilter masukan/kritik buruk (rating ≤ 3) dan mengatur jumlah ulasan per halaman jika jumlah ulasan membengkak. | `about.html`, `admin.html` |
| **Testimonial Card Modern Header-Layout & Compact Sizing** | Layout kartu ulasan publik sebelumnya menaruh bintang rating di paling atas dan nama pengulas di paling bawah dengan ukuran kartu yang agak terlalu lebar. Jika ulasan hanya ada 1 item, kartu melebarkan ukurannya melintasi seluruh grid (stretching). | `app.js`, `style.css` |
| **See-More Testimonials Toggle** | Fitur **"Lihat Semua Ulasan"** pada halaman Home (`index.html`). Awalnya hanya menampilkan 6 ulasan terbaru, tombol **"Lihat Semua Ulasan"** akan menampilkan semua ulasan dengan animasi smooth slide-up/Down. Tombol akan berganti menjadi **"Lihat Lebih Sedikit"** ketika semua ulasan terlihat, dan bisa di-klik lagi untuk menyembunyikan ulasan kembali ke 6 ulasan pertama. | `index.html`, `app.js`, `style.css` |

*Update Terakhir: 19 Agustus 2026*

---

### **7. Recent Updates (9 September 2026)**

| Fitur | Deskripsi Detail | File Terkait |
| :--- | :--- | :--- |
| **Toast Position Fix** | Posisi notifikasi toast `#toast-notification` digeser turun dari `top: 30px` ke `top: 90px` agar tidak menutupi ikon keranjang di sticky header saat user klik "Add to Cart". | `style.css` |
| **Cart Qty Minus Clamp** | Tombol `-` pada keranjang kini berhenti di qty `1` (`if (next < 1) return`) dan tidak lagi menghapus produk secara diam-diam. Penghapusan hanya bisa lewat tombol **Remove**. | `app.js` |
| **Centered Remove Confirm Modal** | Mengganti browser `confirm()` bawaan dengan modal kustom di tengah layar (`#confirm-modal-backdrop`, z-index 5000, backdrop blur). Pesan: `Are you sure you want to remove "[Nama Produk]" from the cart?` dengan tombol **Cancel** / **Yes, Remove**. Mendukung klik backdrop & tombol Escape untuk batal. | `app.js`, `style.css` |
| **Cart Hover Preview** | Hover ikon keranjang di navbar kini menampilkan dropdown preview (`#cart-hover-preview`, 300px): thumbnail, nama, qty x harga, subtotal, dan tombol **View Cart**. Di-inject via JS (`ensureCartHoverPreview`) agar jalan di semua halaman tanpa edit HTML. Lazy-load `fetchProducts()` saat hover pertama + auto-refresh via `updateCartBadge()`. Disembunyikan di mobile. | `app.js`, `style.css` |
| **Quick +/- in Hover Preview** | Dropdown preview keranjang kini interaktif: setiap item punya tombol `-` / `+` (`.preview-qty`) yang memanggil `updateQty()` langsung tanpa ke `cart.html`. Minus tetap clamp di `1`, plus nonaktif saat capai stok maksimal. | `app.js`, `style.css` |
| **Low-Stock Urgency Badge** | Kartu produk (`renderShop` + `renderFeaturedProducts`) kini menampilkan badge oranye `Only X left!` (`.stock-urgency`, absolute top-left) saat `0 < stok <= 5`. Threshold 5 agar tidak berisik. `Sold Out` tetap untuk stok 0. | `app.js`, `style.css` |
| **Order Success Modal + Copy ID** | Mengganti `alert()` murahan setelah checkout dengan modal tengah (`#order-success-backdrop`): ikon sukses, Order ID dalam box dashed + tombol **Copy** (Clipboard API + fallback), dan tombol **Track My Order →**. Klik backdrop ikut redirect ke `track.html?id=...`. | `app.js`, `style.css` |
| **Saved Address Book (max 3)** | Bagian 📒 di atas form checkout (`#address-book-section`, inject via JS): simpan hingga 3 alamat per user (`address_book_<userId>` di localStorage), klik chip untuk autofill + update ongkir, tombol hapus per item, auto-save diam-diam setelah order sukses. Terisolasi per akun seperti cart. | `app.js`, `style.css` |
| **Long-Press Cart Peek (mobile)** | Hover preview tidak jalan di HP, jadi ikon keranjang kini mendukung tahan-tekan ~0.65 detik (`touchstart` timer + `navigator.vibrate`): membuka preview sebagai panel fixed top + tombol ✕, tap biasa tetap ke `cart.html`, tap di luar menutup. Long-press kedua menutup lagi. | `app.js`, `style.css` |
| **Long-Press Peek Fixes** | Perbaikan hasil tes HP: (1) menu bawaan browser ("Open in new tab") selalu di-block via `contextmenu preventDefault` pada ikon keranjang agar tidak muncul sebelum timer; (2) panel mobile diubah menjadi bottom-sheet full-width (56px thumbnail, font & tombol qty lebih besar, `max-height 75vh`, animasi slide-up) agar isi keranjang terbaca; (3) `initSupabase()` dipastikan jalan sebelum lazy-fetch produk di halaman tanpa preload. | `app.js`, `style.css` |
| **Peek Squeeze & Cache Fix** | Aduan "panel tipis" dari screenshot HP: (1) breakpoint panel mobile disamakan ke `1024px` mengikuti drawer menu (sebelumnya `768px`, tablet/mode desktop-site dapat dropdown desktop yang terjepit); (2) dropdown desktop diberi `width: 300px` eksplisit anti-squeeze; (3) cache-bust `style.css`/`app.js` `v=1.0.5` → `v=1.0.6` di semua 10 halaman agar HP tidak lagi menampilkan file lama dari cache. | `style.css`, semua `*.html` |
| **Long-Press Peek Removed** | Fitur tahan-tekan dihapus total atas permintaan: dikhawatirkan mengganggu fungsi utama ikon keranjang (tap → `cart.html`). Kembali ke awal: tap selalu navigasi penuh (termasuk menu browser bawaan), preview hanya bonus hover di desktop/laptop. Seluruh JS long-press, `preview-open`, tombol ✕, dan CSS bottom-sheet dibersihkan. | `app.js`, `style.css` |
| **Downloadable Receipt** | Struk pesanan yang bisa di-print / Save as PDF: tombol **🧾 Download Receipt** di modal sukses (data lengkap dari `window._lastReceipt`: item, qty, harga, subtotal, ongkir, total) + tombol **Print / Save Receipt** di `track.html` untuk cetak ulang kapan saja. Dibangun via `buildReceiptHTML()` + `window.print()` di tab baru, dengan escape HTML anti-XSS. | `app.js`, `style.css`, `track.html` |
| **Receipt Price Parse Fix** | Aduan struk dari Track menampilkan Qty 1 / Rp 0: `printTrackReceipt()` sebelumnya membaca teks DOM yang sudah dibuang harganya. Kini string mentah `items` (`"Nama (x2) [Rp 8.000]"`) disimpan ke `window._trackItemsRaw` lalu diurai via `parseTrackItems()` menjadi nama + qty + harga + subtotal yang benar. | `app.js`, `track.html` |
| **Receipt Subtotal/Shipping Fix** | Aduan struk Track menampilkan `Subtotal: -` / `Shipping: -`: nilainya ada di DB tapi tidak dirender halaman Track. Kini `data.subtotal` & `data.shipping_fee` disimpan ke `window._trackSubtotal/_trackShipping` dan dipakai di struk (fallback `-` untuk order lama yang belum punya kolom). | `app.js`, `track.html` |
| **Receipt PDF/PNG Download** | Opsi unduhan langsung selain Print: tombol **🖨️ Print / 📄 PDF / 🖼️ PNG** di modal sukses & halaman Track. PDF/PNG dirender client-side via `html2pdf.js` CDN (bundle html2canvas + jsPDF), file bernama `receipt-ORD-....pdf/png`, dengan busy-state & fallback ke Print bila library/CDN gagal. Cache-bust aset ke `v=1.0.7` di semua halaman. | `app.js`, `style.css`, `checkout.html`, `track.html`, semua `*.html` |
| **Receipt Lib Self-Loading** | Perbaikan alert "library still loading": app kini memuat sendiri `html2pdf.js` saat dibutuhkan (`ensureReceiptLib()` dengan fallback cdnjs → unpkg, tanpa tergantung cache HTML lama) + pre-warm 2 detik setelah halaman checkout/track dibuka. Gagal total (offline/adblock) baru menyarankan Print. Cache-bust ke `v=1.0.8`. | `app.js`, semua `*.html` |
| **PDF/PNG Buttons Removed** | Tombol PDF/PNG dihapus atas permintaan, kembali ke satu tombol **🧾 Download Receipt** (Print) di modal sukses & Track. Seluruh kode `html2pdf` (CDN tags, loader, export, pre-warm, CSS) dibersihkan. Cache-bust ke `v=1.0.9`. | `app.js`, `style.css`, `checkout.html`, `track.html`, semua `*.html` |
| **Admin Order Search & Filter** | Pencarian + filter status di tabel Orders (`admin.html`): input 🔍 mencocokkan Order ID / nama / telepon / email, dropdown filter PENDING / SHIPPED / COMPLETED / CANCELLED, plus penghitung `Showing X of Y`. Filter client-side dari cache `allOrdersData` tanpa query DB tambahan, baris & aksi (View/Del) tidak berubah. | `admin.html` |
| **Admin Fuzzy Search** | Aduan "Adi tidak ketemu": pencarian diganti fuzzy subsequence (`fuzzyMatch()`) — huruf yang diketik cukup muncul berurutan, tak harus bersebelahan. `adi` kini menemukan Aditia, Andini, Aldi; `brt` menemukan Budiarto. Berlaku per kolom + gabungan semua kolom. | `admin.html` |
| **Admin Search Ranking** | Hasil pencarian diurutkan relevansinya (`matchScore()`): persis dulu (`Adi`), lalu awalan (`Adiani`, `Aditia`), lalu substring, terakhir fuzzy (`Andini`, `Aldi`); dalam skor sama tetap terbaru dulu. | `admin.html` |
| **Admin Search Tightening** | Aduan `Fa` ikut menampilkan Feri/gtgf/Adi: pencocokan gabungan antar-kolom dihapus (huruf `f` di satu kolom tidak boleh berpasangan dengan `a` di kolom lain), dan email/telepon hanya substring persis (tanpa fuzzy) agar `@gmail`/`mail` tidak membocorkan match. Kini `Fa` → Fallen Leaf, Fabi, Fadil (+Rifal yang memang mengandung "fa"). | `admin.html` |
| **Sales Trend De-Kink** | Aduan garis grafik bengkok: chart memakai label string per hari-berisi-order sehingga hari kosong hilang dan jarak-x tidak proporsional. Kini sumbu harian kontinu (order tertua → hari ini, maks 30 hari) dengan hari kosong diisi 0, label `9 Sep`, grid-x disembunyikan, ticks-y integer. | `admin.html` |
| **Sales Trend Rewrite** | Chart ditulis ulang dari nol (`renderSalesTrend()`): jendela tetap 14 hari terakhir (bentuk selalu konsisten), hari kosong = 0, order di luar jendela diabaikan, tension 0.3 anti-overshoot, titik harian terlihat (putih-tepi), fill + grid-x mati. | `admin.html` |
| **Sales Trend Per-Month** | Chart kini per bulan agar tidak campur: dropdown 6 bulan terakhir (default bulan berjalan), sumbu = seluruh tanggal bulan itu (28/30/31 dinamis) dengan hari kosong = 0, order bulan lain tidak masuk, ticks-x dibatasi 10 agar label `9 Sep` tidak berdesakan. | `admin.html` |
| **Buy Again (Reorder)** | Tombol **🔁 Buy Again** di hasil Track: mengurai ulang item order (`parseTrackItems`), mencocokkan nama ke katalog (fetch bila perlu), menambah ke keranjang dengan cap stok (sold out / penuh dilewati + disebut di toast), lalu redirect ke `cart.html` setelah toast 1.2 detik. Catatan: `history.html` adalah artikel sejarah kopi, bukan riwayat order — jadi fitur hanya di Track. Cache-bust ke `v=1.0.10`. | `app.js`, `track.html`, semua `*.html` |
| **Checkout Steps Indicator** | Penanda progres **Cart → Details → Pay** di `cart.html` (langkah 1 aktif), `checkout.html` (langkah 2 aktif, pindah ke 3 via `setCheckoutStep()` saat area pembayaran dibuka), dan modal sukses (semua ✓). Style `.checkout-steps` emas/abu + responsif wrap. Cache-bust ke `v=1.0.11`. | `style.css`, `cart.html`, `checkout.html`, `app.js`, semua `*.html` |
| **Steps Alignment Fix** | Aduan garis penghubung tidak sejajar: trail boleh wrap di HP sehingga garis jatuh di tengah baris. Kini `nowrap` + label anti-wrap, `line-height: 1` pada lingkaran, dan mode kompak ≤480px (lingkaran 22px, garis 14px). Cache-bust ke `v=1.0.12`. | `style.css`, semua `*.html` |
| **Steps Grid Rebuild** | Aduan berlanjut di desktop (wrap bukan penyebab): trail dibangun ulang di atas CSS grid 5 kolom eksplisit — konektor secara struktural tidak bisa jatuh ke baris lain, selalu sejajar tengah lingkaran. Cache-bust ke `v=1.0.13`. | `style.css`, semua `*.html` |
| **Steps Dead-Center Lines** | Minta garis pas di tengah lingkaran: tinggi baris dikunci persis sebesar lingkaran (28px, 22px di HP) sehingga garis 2px otomatis terpusat sempurna apa pun ukuran label. Cache-bust ke `v=1.0.14`. | `style.css`, semua `*.html` |
| **Steps Margin Leak Fix** | Akar masalah garis turun akhirnya ketemu (bukti: CSS live sudah benar tapi render tetap salah): rule lama journey `.step-item { margin-bottom: clamp(...) }` bocor ke item stepper karena nama class sama, mengangkat lingkaran di atas garis. Ditutup via `.checkout-steps .step-item { margin-bottom: 0 }` yang scoped agar spacing journey tidak ikut mati. Cache-bust ke `v=1.0.15`. | `style.css`, semua `*.html` |
| **Direct PDF/PNG Receipt Download** | Permintaan unduhan langsung tanpa print: tombol **📄 PDF** (via `html2pdf.js` → `receipt-ORD-....pdf`) dan **🖼️ PNG** (via `html2canvas` → download link) di modal sukses & halaman Track, tetap berdampingan dengan Print. Library self-load saat diklik (fallback cdnjs → unpkg) + preload di kedua halaman + pre-warm 2 detik, busy-state `⏳...`, fallback ke Print bila gagal. Cache-bust ke `v=1.0.16`. | `app.js`, `style.css`, `checkout.html`, `track.html`, semua `*.html` |
| **Zero-Dependency PDF/PNG Export** | Aduan "could not load library" (CDN tak terjangkau dari HP): seluruh ketergantungan eksternal dibuang. Struk digambar manual via Canvas 2D (`drawReceiptCanvas()`), PNG via `toBlob`, PDF via builder biner minimal (`jpegToPdf()`: JPEG XObject + xref terverifikasi di Node). Tanpa internet tambahan selain halaman itu sendiri. Cache-bust ke `v=1.0.17`. | `app.js`, semua `*.html` |
| **Receipt Column Overlap Fix** | Aduan kata bertumpuk di struk (bukti: `receipt-ORD-...png` menunjukkan `Rp 35.00Rp 35.000` berhimpit): kolom Price–Subtotal hanya berjarak 95px sementara teks ~100px. Kolom disebar (Qty 360, Price 470, Subtotal 600) + kolom nama menyempit ke 230px dengan wrap otomatis yang ikut mengatur tinggi baris. Cache-bust ke `v=1.0.18`. | `app.js`, semua `*.html` |
| **Tidy Receipt Redesign** | Struk dirapikan sesuai sketsa: header tengah + `ORDER RECEIPT`, field label-berjajar (`Order ID : ...`), seksi `CUSTOMER INFORMATION` / `DELIVERY & PAYMENT`, badge status berwarna (`receiptStatus()`: PENDING 🟡 / SHIPPED / COMPLETED / CANCELLED), tabel ITEM–QTY–PRICE lega, TOTAL tegas, seksi NOTE berisi catatan pembeli (Track memakai kolom `note` DB, bukan teks status). Berlaku untuk file (canvas) & Print. Cache-bust ke `v=1.0.19`. | `app.js`, `track.html`, semua `*.html` |
| **Receipt Currency & Label Fix** | Aduan `Rp Rp15.000` ganda + label `Payment Method` menempel nilai: helper `rp()` menormalkan semua varian simpanan menjadi tepat satu `Rp` + digit tergrup (teruji: `"Rp Rp15.000"` → `Rp15.000`), dipakai di TOTAL canvas & Print; kolom label canvas dilebarkan 175→200 dan label Print 130→155px. Cache-bust ke `v=1.0.20`. | `app.js`, semua `*.html` |
| **Receipt Divider Overlap Fix** | Aduan garis acak menimpa tulisan (bukti: garis Hz memotong kata `Subtotal`): pembatas di atas total hanya berjarak 8px dari baseline teks sehingga masuk zona huruf. Jarak jadi 30px + kalkulasi tinggi kanvas diselaraskan. Cache-bust ke `v=1.0.21`. | `app.js`, semua `*.html` |
| **Buy Again Button Restored** | Aduan tombol hilang: tertimpa saat baris tombol struk ditulis ulang (`fffcd94`) — git history membuktikan. Tombol emas dikembalikan di samping Print/PDF/PNG (fungsi `reorderTrackItems` untungnya selamat). Cache-bust ke `v=1.0.22`. | `track.html`, semua `*.html` |
| **Admin Login Outage Fix** | Aduan tidak bisa login admin: refactoring chart menyisakan satu `}` berlebih sehingga seluruh script admin gagal parse dan login ikut mati. Brace dibuang, kedua blok inline script lolos `node --check`. Pelajaran: syntax-check `admin.html` setiap edit. | `admin.html` |

*Update Terakhir: 9 September 2026*


### **7. Catatan 14 September 2026**

Hari ini fokus ke halaman history sama beres-beres home:

- Halaman history dirombak. Tabel timeline yang datar itu diganti timeline vertikal (garis emas + titik per tahun), terus ditambah daftar isi sticky di atas, progress bar tipis pas baca, sama kutipan-kutipan ("Penny Universities", "Max Havelaar") biar nggak kayak tembok teks. Di bawahnya ada ajakan "Rasakan Sejarahnya" yang nyambung ke produk. Kartu daerah-daerah akhirnya dibalikin polos aja (emoji + judul + deskripsi) soalnya versi pakai label rasa malah kelihatan kosong. (`history.html`, `style.css`)
- Bagian "From Peak to Pouch" di home ganti gambar ke `Pohon Gayo.webp` (foto tegak, pas buat kolom teks yang panjang) dan dikunci pakai `object-fit: cover` biar tingginya ngikutin teks terus. Grid-nya juga dibetulin biar nggak luber di HP (`minmax(min(300px,100%),1fr)`). Jarak tombol View Complete Shop ke Our Mission dirapetin. (`index.html`, `style.css`)
- Nemu akar masalah teks journey yang luber ke kanan: ternyata class `.step-item` punya checkout (`display: flex` + `nowrap`) bocor ke home karena namanya sama persis. Sekarang yang checkout di-scope ke `.checkout-steps`, home aman. (`style.css`)
- Pengaman overflow buat grid journey: anak-anaknya dipaksa `min-width: 0`, teks boleh patah kata. (`style.css`)
- Push `7eb6bbd` ke main. Yang ikut cuma 4 file (termasuk gambar Pohon Gayo). Screenshot-screenshot sama folder `Coba Entre 2` nggak ikut, biarin lokal aja.

### **8. Nanti dikerjain (ditunda dulu)**

- **SEO biar muncul di Google.** Rencananya: bikin `robots.txt`, `sitemap.xml`, meta description, Open Graph, daftar ke Search Console, terus kunci `admin.html` supaya nggak keindeks. Ditunda, nunggu aba-aba.

### **9. Catatan 15 September 2026**

- Spacing diseragamkan: semua section sekarang 96px (desktop) / 64px (HP), judul section 48/32px. Sebelumnya campur aduk — 120, 100, 80 — bahkan `.shop-section` kedobel definisinya. Inline style di `index.html` yang nimpa-nimpa juga dibersihin. Commit `fe3f738`. (`style.css`, `index.html`)
- Checkout: total yang tadinya bisa jadi `Rp NaN` (ongkir nggak dikenal balikannya `undefined`) sekarang dipagari, nggak akan NaN lagi. Grid checkout juga dibetulin (`minmax(0,1fr)`) supaya sidebar Final Summary nggak kepental keluar layar. Commit `51a7d10`, `df4bdb3`. (`app.js`, `style.css`)
- Tombol Track yang pil orennya miring: penyebabnya sepele, sisa `padding-bottom: 4px` dari menu biasa plus spasi ekor `letter-spacing`. Udah dilurusin pakai selektor yang lebih spesifik. Berlaku semua halaman. (`style.css`)

### **10. Ide UI/UX yang belum dieksekusi**

Buat jaga-jaga, daftarnya disimpen di sini dulu:

1. Hero home dibikin satu pesan tegas + satu tombol utama, yang sekunder dikecilin.
2. Kartu produk disamain gayanya sama tombol Track (pil gold), hover foto yang alus.
3. (Udah dijelasin, belum dikerjain) Drawer menu HP: background coklat tua, tiap menu ada ikon, Track jadi tombol full-width, animasi masuknya gantian.
4. Bahasa diseragamkan: judul/CTA Inggris, penjelasan Indonesia.
5. Skeleton loading ala Featured dipakai juga di halaman products sama track.
6. Rating bintang per produk (terikat order, tampil rata-rata di kartu katalog) — dijadwalkan Jumat.


### **11. Catatan 16 September 2026**

- Testimoni home diubah jadi marquee yang ngalir terus kanan ke kiri, ngeloop selamanya, plus bisa diseret manual (mouse di desktop, swipe di HP). Tombol "Lihat Semua Ulasan" dipensiunkan karena nggak relevan lagi. Commit `60d9300`. (`app.js`, `style.css`)
- Kelanjutannya: habis digeser manual, marqueenya diam 3 detik dulu baru jalan lagi. Sempat nggak gerak sama sekali gara-gara satu variabel (`seeMoreBtn`) kehapus pas rewrite — udah dibetulin.
- Checkout opsi 3: ringkasan jadi sticky di desktop, di HP muncul bar bawah (total live + tombol bayar, ngumpet pas keranjang kosong atau udah masuk pembayaran), dan "Tambah Produk Lain" bisa dilipat. Commit `4c6244e`. (`app.js`, `checkout.html`, `style.css`)
- Foto profil di feedback: yang login Google fotonya ikut kesimpen (kolom `avatar_url`, dibikin manual di SQL editor) dan nongol di kartu. Yang nggak ada fotonya dapat lingkaran inisial gold (Dina jadi "D"). Sengaja satu warna biar tetap kalem. Sempat dikira error padahal penyebabnya kode belum di-push — udah naik di `c862a84`.
- Alert habis kirim feedback dibiarin bawaan browser dulu, belum diganti modal.
- Sinkron keranjang antar-HP/laptop diputusin nggak usah: keranjang tetap lokal per perangkat. Alasannya udah dibahas (konflik edit, butuh internet terus, kasus guest-login ribet).
- Catatan jurnal bagian 7–10 ditulis ulang pakai bahasa santai biar nggak kelihatan bikinan AI.
- Statistik kunjungan per halaman: tiap halaman publik manggil `bump_page_view` (gagal diam-diam biar nggak ganggu pengunjung), dashboard admin nambah kartu Page Views. Butuh tabel + function `page_views` dibikin manual di SQL editor. Belum di-push.


### **12. Catatan 14 Oktober 2026**

Bulan ini jatah progresnya buat SEO, yang dari September ditunda terus. Ternyata nggak seseram itu:

- Bikin `robots.txt` di root. Isinya ngizinin bot Google masuk ke halaman publik, tapi nolak `/admin`, `/cart`, `/checkout`, `/track`. Plus nunjukin lokasi sitemap. (`robots.txt`)
- Bikin `sitemap.xml` isi 6 halaman publik aja: Home `/`, `/products`, `/about`, `/brew`, `/history`, `/contact`. Pakai URL bersih (tanpa `.html`) ngikutin `cleanUrls: true` di Vercel. Yang transaksi/privat nggak dimasukin. (`sitemap.xml`)
- Halaman admin dikunci pakai `<meta name="robots" content="noindex, nofollow">` biar kalaupun bot nyasar masuk, nggak bakal dipajang di hasil search. Dibuka manual tetap normal. (`admin.html`)
- Semua halaman publik dipasang meta description + Open Graph + canonical + twitter card. Jadi pas link di-share ke WA/IG/Telegram muncul kartu cantik (judul + deskripsi + gambar `Latar Belakang Home 2.png`), bukan link polos. Deskripsi tiap halaman dibedain sesuai isinya. (`index.html`, `products.html`, `about.html`, `brew.html`, `history.html`, `contact.html`)
- Abis push ke Vercel tinggal cek `/robots.txt` sama `/sitemap.xml` kebuka, terus daftarin domain `kreasi-guna-v2.vercel.app` ke Google Search Console sekali. Sisanya nunggu Google mampir 3-14 hari.
- Update verifikasi: properti URL prefix `https://kreasi-guna-v2.vercel.app/` di Search Console **terverifikasi via Tag HTML** (`google-site-verification` di `index.html`, commit `7535367`). File verifikasi jangan dihapus biar status ijo terus. Lanjut submit `sitemap.xml` di menu Sitemaps.
- Update sitemap: `sitemap.xml` awalnya "Tidak dapat mengambil", setelah kirim ulang + tunggu akhirnya **Berhasil diproses (Terakhir dibaca 14/10/26, Halaman ditemukan: 6, Video: 0)**. SEO Oktober resmi tamat.
- Pelajaran indexing: sempat salah inspeksi `/product` (tanpa S, "URL tidak dikenali"). Yang bener `/products` statusnya "Ditemukan - saat ini tidak diindeks" (udah kedeteksi via sitemap, tinggal antre). Pas klik "Minta pengindeksan" kena **Kuota Terlampaui** (jatah harian Google habis, kesedot buat URL salah). Solusinya: 1 URL per hari mulai besok, sisanya biarin jalur sitemap otomatis 3-14 hari. Cara cek: `site:kreasi-guna-v2.vercel.app`.


### **13. Catatan 19 Oktober 2026**

Hari ini ngerapatin cart, checkout, sama gerbang login sebelum bayar:

- Item di Track yang udah dinilai sekarang nampilin skor bintang yang dikasih, jadi kelihatan "kamu kasih 4" nggak cuma tanda udah pernah. Commit `52a5f99`. (`track.html`, `app.js`)
- Cart dirombak sesuai contoh: tombol qty jadi lingkaran outline hitam, foto produk membulat (radius 20px, 16px di HP), tombol "Checkout Now" dikasih radius, "← Continue Shopping" dipindah ke bawah daftar produk biar nggak keburu ke-scroll, spasi "Order Summary" diseragamkan. Di HP item bisa di-swipe ke kiri buat muncul tombol hapus. Commit `184d56a`. (`cart.html`, `app.js`, `style.css`)
- Gerbang checkout: pencet "Checkout Now" belum login → muncul pilihan **Login** atau **Lanjut sebagai Tamu** (aksen gold, ngikutin contoh). Login Google dari gerbang otomatis balik ke checkout (flag di sessionStorage), tamu juga boleh lanjut. Pengecekan dipasang juga di `checkout.html` biar nyasar ke sana tanpa login tetap ketangkep. **Pending dari kamu:** isi Supabase Dashboard → Authentication → URL Configuration (Site URL + Redirect URLs) biar `redirectTo` Google-nya jalan. Commit `184d56a`. (`cart.html`, `checkout.html`, `app.js`, `style.css`)
- Label tombol full-width ("Checkout Now", "Shop Now") dipusatin lewat `.w-100`. Commit `f7f571f`. (`style.css`)
- Baris produk di checkout dapet thumbnail 56px kotak bundar sebelum nama (ngikutin contoh "Ringkasan Pesanan"), gambar di kartu quick-add juga dibulatin. Commit `a3b0cef`. (`app.js`, `style.css`)
- Aduan foto drip bag di cart nggak kelihatan kotak bundar: ternyata `My Product.png` itu landscape (1195×544), pakai `object-fit: contain` cuma jadi pita bersudut tajam di tengah kotak. Diganti `cover` di cart, thumb checkout, dan quick-add — foto jadi selalu ngisi kotak yang udah dibulatkan. Commit `6cab751`. (`style.css`, `app.js`)
- Cache-bust sampai `v=1.0.30`. Semua push ke main, Vercel auto-deploy. Backup `backup-2026-10-19/` plus screenshot/contoh gambar "Contoh..." dibiarin lokal aja, nggak ikut commit.
- Fix centang hijau terpotong: SVG viewBox diperbesar 52→64, radius 25→28, path diperpanjang, dasharray disesuaikan. Commit `95bbe96`. Cache-bust ke `v=1.0.41`, push ke main. (`app.js`, `style.css`)


### **14. Catatan 20 Oktober 2026**

Checkout & cart dirapatin sesuai contoh. Sambil lihat beberapa referensi gambar, muncul juga ide fitur halaman user: bikin halaman akun sendiri berisi **Pesanan Saya, Ulasan Saya, dan Alamat Pengiriman** — baru dieksekusi siang 20 Oktober juga (lihat Catatan 15):

- Bekasi masuk jadi kota pengiriman (fee sama Jakarta: 15k/25k/45k), `matchShippingCity()` deteksi "bekasi" → return `'bekasi'`, Jabodetabek lain tetap `'jakarta'`. Commit `fd04c8b`, `9c466eb`. (`app.js`)
- Label dropdown Layanan Pengiriman sekarang nampilin harga per opsi (mis. `Regular (J&T / JNE) — Rp 15.000`), harga ikut berubah pas ganti kota lewat `handleShippingUpdate()`. Default Jakarta terpilih. Commit `f50a04e`. (`app.js`)
- Dropdown Layanan Pengiriman (native `<select>`) tetap pakai styling bawaan browser untuk popup opsi-nya — nggak bisa di-style pakai CSS. Sudah diputuskan biarkan saja (opsi paling aman).
- **Redesign alamat pengiriman checkout** sesuai referensi `Images/Contoh Tampilan  Alamat Pengiriman Halaman Checkout.jpeg`: form dipecah jadi dua section — **Data Penerima** (Nama Lengkap, Nomor WhatsApp dengan prefix +62 & ikon WA, Email) dan **Alamat Pengiriman** (Alamat Lengkap + tombol deteksi lokasi, Kota/Kabupaten, Provinsi dropdown, Kode Pos). Nambah checkbox "Simpan alamat ini untuk pesanan berikutnya", tombol jadi "Lanjut ke Pembayaran →". `handleProceedToPayment()` validasi provinsi & kode pos juga; nomor HP otomatis prepend `+62` sebelum disimpan. Address book nyimpen province & postalCode. Commit `8130089`. Cache-bust `v=1.0.46`. (`checkout.html`, `app.js`)
- Tombol **Lokasi Terkini** & **Pilih di Peta** sekarang auto-fill **Provinsi** (dropdown, lewat helper baru `matchProvince()`) dan **Kode Pos** dari data Nominatim — user nggak perlu isi manual lagi setelah detect lokasi. `matchShippingCity()` valid list juga ditambah `'bekasi'`. Commit `e57e292`. Cache-bust `v=1.0.47`. (`app.js`)

- Judul "Complete Your Order" di checkout diratakan tinggi dengan "Final Summary" (tighten line-height, margin-top: 0). Commit `dddf8aa`. (`style.css`)
- Tombol quick-add "➕ Tambah" di checkout jadi emas (`--gold-premium`), `.btn-primary` (Checkout Now, Proceed to Payment, dll.) dikasih `border-radius: 12px`. Commit `0fd8251`. (`style.css`, `app.js`)
- Modal sukses order dirombak total ngikutin referensi gambar: "Pesanan Berhasil Dibuat!" + deskripsi terima kasih, 4 baris detail (Nomor Pesanan, QRIS, Total, Tanggal), tombol "Lihat Detail Pesanan" (emas) + "Lacak Pesanan Sebagai Tamu" (outline). Commit `ec6089c`. (`app.js`, `style.css`)
- Fix total jadi Rp 0: ambil `grand-total` **sebelum** clear cart, terus lempar ke modal. Commit `3fbb616`. (`app.js`)
- Nomor Pesanan label + value dibold, klik nomor = copy (toast "Tersalin!"), tombol bawah cuma "Lihat Detail Pesanan". Commit `6f02cfe`. (`app.js`)
- Tambah ikon copy `⧉` di samping nomor. Commit `b8efbdd`. (`app.js`)
- Nomor Pesanan dipindah tengah, icon ✅ diganti **lingkaran hijau + centang SVG animasi draw**, confetti jatuh pas modal muncul, toast copy nggak ganti teks nomor. Commit `1cf84e4`. (`app.js`, `style.css`)
- Order Summary di cart **disembunyikan pas keranjang kosong** (`display: none`), muncul pas ada item. Commit `7ffabda`. (`app.js`)
- Empty cart state di tengah penuh: grid jadi 1 kolom, `.cart-page-items` flex center + `min-height: 400px`. Commit `228b095`. (`app.js`, `style.css`)
- Cache-bust sampai `v=1.0.40`. Semua push ke main, Vercel auto-deploy.


### **15. Catatan 20 Oktober 2026 (lanjutan siang)**

Lanjutan sesi pagi (Catatan 14): polesan UI plus **eksekusi ide halaman akun** (versi basic, ide-nya dari sesi sebelumnya), ngikutin 3 contoh gambar (Pesanan Saya, Ulasan Saya, Alamat Pengiriman):

- **Address book di-restyle** biar matching desain checkout baru: container jadi kartu putih bersudut bundar (hapus border dashed), item alamat pakai background `#fafafa` + hover gold, tombol hapus merah, tombol "Simpan alamat ini" full-width gold outline. Teks di-Indonesikan ("Alamat Tersimpan", "maks. 3"). Commit `0f6b0b1`. Cache-bust `v=1.0.48`. (`style.css`, `app.js`)
- Perapian mikro: tombol "See Description" di produk nggak pecah dua baris (`white-space: nowrap`), header quick-add checkout nggak numpuk di HP, layout alamat checkout jadi satu kolom penuh di HP (class `.address-grid`), Total di paybar nggak ikut nge-wrap. Commits `4fe3b7b`, `7a8f2a8`, `340bc19`.
- Toast sukses dipindah ke tengah bawah (full-width di HP, `text-align: center`) biar nggak nempel kiri. Commit `7d2a11a`.
- Burger menu HP dikasih bayangan ke kanan + `overscroll-behavior: contain` biar scroll nggak bocor ke halaman di belakangnya. Commit `b5a022c`. Cache-bust `v=1.0.53`.
- **`account.html` (baru)** — layout sidebar (avatar + nama + email, menu: Pesanan Saya / Ulasan Saya / Alamat Pengiriman / Keluar) + konten di kanan. Belum login → kartu gerbang "Masuk dengan Google". Meta `noindex, nofollow` + masuk `robots.txt` (`Disallow: /account`) biar nggak keindeks. (`account.html`, `robots.txt`)
- **Pesanan Saya**: fetch `orders` by `customer_email`, kartu per order (ID, tanggal, chip status berwarna, preview item, total). "Lihat Detail" expand inline: timeline 4-step (Dibuat/Diproses/Dikirim/Selesai — mapping status PENDING/SHIPPED/COMPLETED; CANCELLED nggak ada timeline, diganti catatan merah), ringkasan produk + subtotal/ongkir/total, info pengiriman/pembayaran, preview bukti bayar. Tombol "Lacak" → `track.html?id=ORD-xxx`.
- **`track.html`** sekarang auto-track dari URL `?id=` — biar tombol Lacak dari halaman akun (atau link manapun) langsung nampilin hasilnya. (`track.html`)
- **Ulasan Saya**: fetch `feedback` dua jalur — by `customer_name` (nama lengkap session) + `order_id in` (order milik user), digabung & dedupe. Kartu: foto produk (lookup `DYNAMIC_PRODUCTS`), nama produk / "Ulasan Umum", bintang, komentar, tombol Ubah (prompt) & Hapus (confirm + delete Supabase).
- **Alamat Pengiriman**: baca/tulis address book localStorage per-user (maks. 3, fungsi lama `getAddressBook` dipakai ulang). Form tambah/ubah: nama, HP, kota, provinsi, kode pos, alamat. Validasi nama ≥3 & alamat ≥10 karakter (sama kayak checkout).
- **Dropdown user di header** (`app.js`): nambah item "👤 Akun Saya" → `account.html` sebelum Logout.
- CSS `.acc-*` di `style.css` (grid `260px 1fr`, sticky sidebar, ≤868px jadi 1 kolom + menu jadi baris wrap).
- Cache-bust `v=1.0.54` semua HTML. `node --check app.js` lolos. Commit `247f705`.
- **Poles dropdown user di header**: markup + style inline diganti class CSS (`.user-nav-trigger`, `.auth-dd-*`). Jadi kartu menu rapi: header gradasi cream (avatar 40px + nama + email, ellipsis kalau kepanjangan), item "👤 Akun Saya" & "🚪 Logout" dengan hover cream + border-left gold, animasi muncul 0.18s, chevron berputar pas dibuka. Tombol trigger jadi `<button>` asli (bisa keyboard/aria), `aria-expanded` ikut update, klik di luar juga reset chevron-nya. Item menu pakai selektor `.auth-dropdown .auth-dd-item` biar nggak kalah sama `.nav-links a { font-size: 1.6rem }` di drawer HP. Dropdown dipusatin (`left: 50%`) pas ≤1024px biar nggak keluar tepi. Cache-bust `v=1.0.55`. (`app.js`, `style.css`)
- **Poles item menu dropdown (Akun Saya / Logout)**: emoji mentah `👤`/`🚪` diganti **SVG stroke** (`currentColor` — tampilannya konsisten antar device dan ikut warna hover). Tiap item dapat icon badge 28px (background cream → gold pas hover; variant merah buat Logout), item geser 2px halus pas hover, dan "Akun Saya" dikasih panah `›` di kanan biar kelihatan sebagai link navigasi. Border-left diganti geser halus biar lebih clean. Cache-bust `v=1.0.56`. (`app.js`, `style.css`)


### **16. Catatan 20 Oktober 2026 (lanjutan sore)**

Hari ini fokus Track Order sama halaman akun, ngejar 3 contoh gambar (hasil track, detail pesanan, hero track):

- **Track Order auto-track + status badge**: `handleTrackOrder()` di `app.js` (query Supabase by `order_id`, render hasil + item + timeline + struk) supaya `track.html?id=...` langsung nampilin hasil — dipakai juga dari tombol Lacak di halaman akun. Status chip (PENDING/SHIPPED/COMPLETED/CANCELLED) nempel di hasil cari. Commit `32b47e2`. (`track.html`, `app.js`, `style.css`)
- **Redesign Track Order sesuai contoh** (`Images/Contoh Tampilan Tract Order.png`): hero pakai `Images/Header Tract Order.png` sebagai background + overlay gelap, form cari dengan ikon, hasil pencarian (info order, timeline 5 langkah hijau, daftar item + struk + tombol Buy Again), section bantuan WhatsApp. Semua emoji diganti **ikon SVG stroke gaya Feather** (`.tico`) biar seragam antar device. Commit `d7feb72`, `0d97993`, `f9430fe`, `30153c2`. (`track.html`, `style.css`, `app.js`)
- **Fix mojibake masif**: emoji di banyak file HTML rusak jadi karakter `â`/`ðŸ` (encoding ketuker cp1252→UTF-8). Dibetulin bulk pakai script Node roundtrip per-baris — `admin.html` (43 baris) + semua halaman root (133 baris: account, history, brew, checkout, index, about, contact, cart, products). Sambil jalan, `rp()` di `account.html` dipagari kayak app.js biar nggak balik `Rp NaN`. Commit `21c994c`, `9cf8db6`. (`admin.html` + semua `*.html`, `account.html`)
- **Badge ikon emoji di account**: menu sidebar & judul section dikasih badge rounded (`.acc-ico` 26px cream, aktif → gold + shadow, logout merah; `.acc-ico-lg` 34px gradasi gold buat judul). Gate login 🔒 jadi lingkaran gold 76px, empty state pakai lingkaran dashed gold. Commit `b95375e`. (`account.html`, `style.css`)
- **Pesanan selesai: Beri Ulasan + Beli Lagi per item** (ngikutin `Images/Contoh Tampilan Halaman User bagian Pesanan Saya.jpeg`): tiap item punya thumbnail, harga × qty, subtotal, tombol ★ Beri Ulasan (modal bintang, simpan ke `feedback` terikat `order_id`+`product_id`, kalau udah pernah jadi "★ n · Rated") dan 🛒 Beli Lagi (cek stok, masuk keranjang). Fungsi rating dipindah ke `app.js` (`rateOrderProduct`, `markRatedOrderButtons`, modal) biar dipakai bareng Track & Account — tombol rate di Track sempat hilang pas redesign, balik lagi. Commit `2547c99`. (`account.html`, `app.js`, `style.css`, `track.html`)
- **Emoji account diganti SVG Feather total**: 🔒📅⭐📍🚪📦⚠️🛒🧾🚚🔁 semua jadi SVG stroke custom (papan ikon `ACC_ICONS` + helper `accIco()`), warna ngikutin konteks (badge aktif putih, tombol gold putih). Karakter `★`/`✓` dibiarkan (dingbat teks, tampil konsisten). Commit `2a6d12b`. (`account.html`, `style.css`)
- **Halaman Detail Pesanan full-page** sesuai `Images/Contoh Tampilan Halaman User Setelah Menekan Detail Pesanan bagian Pesanan Saya.jpeg`: tombol Detail nyembunyiin daftar order, buka halaman sendiri — link "← Kembali ke Pesanan Saya", judul + chip status, nomor & tanggal order, tombol atas (Lihat Struk, Pesan Ulang, Hubungi Kami, Beri Ulasan emas), timeline 5 langkah (Dibuat → Pembayaran Berhasil → Diproses → Dikirim → Selesai, lingkaran hijau + ikon + tanggal), kolom kiri produk (foto, nama, qty, subtotal + aksi per item) + Ringkasan Pembayaran, kolom kanan Informasi Pengiriman & Pembayaran (chip Berhasil/Menunggu), banner "Butuh Bantuan?" WhatsApp. Status CONFIRMED/PAID/DELIVERED nambah di `STATUS_STYLES`. Sidebar akun tetap sticky (udah dari sononya, dipertahankan). Commit `9003b84`. (`account.html`, `style.css`)
- Cache-bust `app.js`/`style.css` account & track sampai `v=1.0.65`. `node -c app.js` + cek inline script lolos tiap commit. Semua push ke main, Vercel auto-deploy.
- **Rollback sementara**: halaman Detail Pesanan full-page (commit `9003b84`) di-undo (`ffca10a`) karena tampilannya amburadul di browser. Tombol Detail balik jadi accordion "Lihat Detail" lama, CSS halaman detail baru ikut ditarik, cache-bust ke `v=1.0.66`. Commit aslinya masih ada di git — kalau mau dikerjain ulang tinggal dari nol atau cherry-pick. Fitur lain (ikon SVG, Beri Ulasan/Beli Lagi, Track redesign) tetap.


### **17. Catatan 21 Oktober 2026**

Lanjutan halaman akun, fokus tampilan HP dari screenshot `Images/Contoh Tampilan HP di Halaman Account Yang HArus Diperbaiki.png`:

- **Menu sidebar HP**: awalnya grid 2 kolom (commit `cdc817f`) tapi "Alamat Pengiriman" kekerempet/tekstil nggak lega — user minta diperbaiki. Diubah jadi **daftar vertikal 1 baris penuh** (pola menu akun e-commerce: icon kiri + teks, tap target gede, "Keluar" merah di bawah). Item dikasih bg `#fafafa` + border tipis biar jelas sebagai menu. Commit `b5d45b7`. (`style.css`)
- **Avatar HP**: sempat diganti inisial gold semua (avatar Google default warnanya acak, ungu di screenshot — `cdc817f`), tapi user mau foto profil Google tetap dipakai. Logic `avatar_url` dibalikin, avatar dipaksa **bulat** di HP dengan `flex-shrink: 0` + `min-width: 72px` (yang bikin lonjong itu flex row sidebar nge-shrink avatar). Commit `89413c0`. (`account.html`, `style.css`)
- Cache-bust account `v=1.0.66` → `v=1.0.69`. `node -c app.js` + cek encoding lolos tiap commit. Push ke main, Vercel auto-deploy.
- **Burger menu mobile dirombak** (commit `bd3f5b5`): drawer baru `#mm-drawer` di-inject via JS (`buildMobileMenu()`) — pola sama kayak auth dropdown, karena `.nav-links` dipakai bareng desktop. Di ≤1024px `.nav-links` jadi `display: none !important`, hamburger toggle `mm-drawer.active` + `body.menu-open`. Drawer: bg `Images/Burger Menu Background Coffee Bean Cascade Border.png` (biji kopi cascade, sisi kiri transparan), head (logo KG + tombol X), dua section — **Jelajahi** (Beranda/Tentang Kami/Sejarah Kami/Produk/Panduan Brew/Kontak) dan **Pesanan & Akun** (Lacak Pesanan/Akun Saya/Keranjang + chevron), ikon SVG Feather stroke, badge keranjang `#mm-cart-badge` sinkron di `updateCartBadge()`. Desktop nav tetap utuh. Semua halaman root bump `v=1.0.70`. **Inkonsistensi label**: drawer Bahasa Indonesia sesuai contoh, desktop masih Inggris — tawarkan unifikasi ke user.
- **Insiden link aset `.0.70`**: commit burger menu (`bd3f5b5`) salah ngedit link aset di **semua 11 halaman** — `style.css?v=1.0.70` jadi `.0.70`, `app.js?v=1.0.70` juga ikut. Browser nggak nemu file `.0.70`, CSS & JS gagal load total → seluruh situs tampil tanpa styling. Fix: commit `4aea56e` balikin link yang benar. Screenshot bukti: `Images/Tampilan Burger Menu yang Harus Diperbaiki.png`.
- **Hardening `check-assets.js`**: script validasi yang cek tiap `*.html` wajib punya `style.css?v=X.Y.Z` & `app.js?v=X.Y.Z` dengan format versi bener, versi harus sama antar halaman, plus deteksi link rusak gaya `href="."`. Jalankan `npm run check:assets` sebelum push. (`check-assets.js`, `package.json`)
- **Burger menu restyle sesuai contoh**: background biji kopi dihapus sementara (user minta cek drawer bersih dulu), item menu dibuat **full-width + `min-height: 56px`** biar mudah tap di HP, `.mm-nav` dikasih `display: flex; flex-direction: column; align-items: flex-start` biar item **rata kiri penuh** (sebelumnya center). Font item sedikit diperbesar (`1.05rem`). Cache `v=1.0.71` → `v=1.0.75`. (`style.css`)
- **Fix encoding mojibake emoji**: perintah PowerShell `Set-Content` tanpa `-Encoding UTF8` merusak emoji di 11 halaman (jadi `?` / belah ketupat ). Ditulis ulang via Node dengan UTF-8 encoding benar. Emoji dipulihkan: ⚡🏆✨ (advantage cards), ➔ (banner arrow), 🌍☕ (about features), ★ (star rating account), 🛒 (empty cart), 👤 (guest button), ✓ (checkout step), ✕ (admin sidebar), «‹» (admin pagination), 🌋🌿⛰🌺🏝 (history regions), ✉️ (contact email button). Cache `v=1.0.76` → `v=1.0.78`. (`index.html`, `about.html`, `account.html`, `admin.html`, `brew.html`, `cart.html`, `checkout.html`, `contact.html`, `history.html`)


### **18. Rekap Progress (sampai 21 Oktober 2026)**

Daftar progress yang udah kelar, urut tanggal — ringkas doang, detailnya tetap ada di catatan harian masing-masing:

- **Sampai 7 Agustus 2026** — Fondasi Smart Drip V2: berhenti jadi landing page statis, jadi e-commerce beneran. Database Supabase (produk, pesanan, feedback), dashboard admin (CRUD, grafik penjualan, best seller, ekspor CSV), stok autopilot, lacak pesanan tanpa daftar akun, kirim email struk dua arah lewat EmailJS.
- **12–19 Agustus 2026** — Katalog & keranjang: kartu produk + modal "See Description", halaman `cart.html` sendiri, badge keranjang + toast notifikasi, gambar produk diseragamkan, testimoni home + tombol "Lihat Semua Ulasan".
- **9 September 2026** — Gelombang besar: hover preview keranjang (plus minus), modal sukses pesanan + Copy ID, address book, tombol Download Receipt, pencarian admin fuzzy + ranking, grafik sales trend per bulan, Buy Again, indikator langkah checkout, plus fix login admin yang sempat mati.
- **14 September 2026** — Halaman history dirombak (timeline vertikal, daftar isi sticky, progress bar baca), foto "From Peak to Pouch" diganti + grid HP dibetulin.
- **15 September 2026** — Spacing semua section diseragamkan (96/64px), fix total `Rp NaN`, tombol Track dilurusin.
- **16 September 2026** — Testimoni home jadi marquee yang ngalir (diam 3 detik kalo diseret manual), checkout opsi 3 (ringkasan sticky di desktop + bar total di HP), foto profil nongol di ulasan (avatar Google / inisial gold).
- **14 Oktober 2026** — SEO kelar: `robots.txt`, `sitemap.xml`, meta description + Open Graph di semua halaman publik, verifikasi Google Search Console, sitemap resmi kebaca (6 halaman).
- **19 Oktober 2026** — Cart & gerbang checkout: skor bintang nongol di Track, cart dirombak (qty outline, foto membulat, swipe hapus di HP), gerbang Login / Lanjut sebagai Tamu sebelum bayar, thumbnail baris checkout, fix centang modal sukses.
- **20 Oktober 2026** — Batch checkout sesuai contoh: Bekasi masuk + ongkir per-opsi, form alamat dipecah (Data Penerima + Alamat Pengiriman), auto-fill provinsi & kode pos dari deteksi lokasi, modal sukses + nomor pesanan bold/copy/⧉, ringkasan pesanan & empty cart dirapikan. Siang–sore: halaman akun user (`account.html`: Pesanan Saya, Ulasan Saya, Alamat Pengiriman), lacak otomatis dari URL `?id=`, poles dropdown header (kartu menu rapi + icon SVG), address book restyle, polesan mikro HP (toast tengah, burger menu, layout checkout), **perbaiki Track Order** (Enter/err/loading). Sore: Track Order dirombak sesuai contoh (hero gambar, ikon SVG Feather, timeline, hasil + struk + Buy Again), fix mojibake emoji di semua halaman, halaman akun: badge ikon di menu/judul, pesanan selesai punya tombol Beri Ulasan + Beli Lagi per item (rating tersimpan ke `feedback`), emoji account total diganti SVG custom. Detail Pesanan full-page sempat dibuat tapi di-rollback (amburadul), balik ke accordion lama. Cache aset terakhir `v=1.0.66`.
- **21 Oktober 2026** — Polesan tampilan HP halaman akun: menu sidebar jadi daftar vertikal 1 baris penuh (bukan 2 kolom kekerempet), avatar Google dipertahankan + dipaksa bulat (`flex-shrink: 0`). Burger menu mobile dirombak jadi drawer sectioned (Jelajahi / Pesanan & Akun) meniru contoh, ikon SVG Feather. Insiden link aset `.0.70` (seluruh situs tanpa CSS) difix + hardening `check-assets.js`. Burger menu restyle: bg biji kopi dihapus, item full-width rata kiri `min-height: 56px`. Fix encoding mojibake emoji di semua halaman (⚡🏆✨➔🌍☕🛒👤✓✕★ «‹» 🌋🌿⛰🌺🏝✉️). Cache aset terakhir `v=1.0.78`.


### **Catatan buat besok (lanjut)**

- **Cek burger menu di HP setelah deploy**: buka halaman mana pun → tap hamburger → pastikan drawer tampil (item full-width rata kiri, section Jelajahi/Pesanan & Akun, ikon, badge keranjang). Test close via X dan via klik item. **Tawarkan user**: bg biji kopi belum dipasang balik — mau ditambahin? Label drawer sekarang Bahasa Indonesia (sesuai contoh) tapi desktop nav masih Inggris (Home/About/...) — mau diseragamkan?
- Tes alur akun end-to-end di HP & desktop: login → Pesanan Saya (detail expand) → Beri Ulasan/Beli Lagi di item selesai → Ulasan (ubah/hapus) → Alamat (tambah/ubah/hapus)
- Kalau mau lanjut lagi: bikin ulang halaman Detail Pesanan full-page dari nol (commit `9003b84` cuma jadi referensi, jangan langsung cherry-pick — harus dirapikan dulu biar nggak amburadul)
- Cek RLS Supabase tabel `feedback`: kalau UPDATE/DELETE ditolak buat user biasa, tombol Ubah/Hapus ulasan bakal error — perlu policy khusus atau dipindah server-side
- Cek hasil deploy Vercel: pastikan Track Order hero + halaman Detail Pesanan tampil benar di HP
- Supabase Dashboard → Authentication → URL Configuration (Site URL + Redirect URLs) — biar OAuth Google jalan
- Ide lanjutan halaman akun (versi lanjutan): Wishlist, Metode Pembayaran, Pengaturan Akun, timeline detail pakai timestamp asli kalau kolomnya ada





