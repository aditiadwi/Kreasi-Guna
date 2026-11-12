-- feedback.is_anonymous: tampilkan ulasan sebagai Anonim (nama disembunyikan dari publik).
-- Dijalankan di Supabase Dashboard -> SQL Editor (aman diulang).
--
-- Kode yang membutuhkannya:
--   app.js injectRateModal       -> checkbox "Tampilkan sebagai Anonim"
--   app.js submitRateModal       -> insert { is_anonymous: true }
--   app.js renderTestimonials    -> tampil "Anonim" (avatar huruf A, tanpa foto profil)
--   app.js fetchProductRatings   -> sample ulasan produk ikut kolom ini
--   account.html edit modal      -> checkbox anonim bisa diubah saat edit
--   admin.html feedback table    -> badge "publik: Anonim" (nama asli tetap terlihat utk moderasi)
--
-- Tanpa kolom ini kode tetap jalan (fallback insert/update tanpa is_anonymous),
-- tapi fitur anonimnya belum aktif — semua ulasan tampil dengan nama.
-- Urutan aman: SQL dulu baru deploy, ATAU deploy dulu lalu SQL (karena ada fallback).

alter table public.feedback
    add column if not exists is_anonymous boolean not null default false;
