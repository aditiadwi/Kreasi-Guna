-- feedback.edited: penanda ulasan sudah pernah diubah (batas edit 1 kali).
-- Dijalankan sekali di Supabase Dashboard -> SQL Editor.
--
-- Kode yang membutuhkannya:
--   account.html saveAccEditReview -> update({ message, edited: true })
--   account.html accReviewCard     -> sembunyikan tombol "Ubah" kalau f.edited
--
-- Tanpa kolom ini kode tetap jalan (fallback update tanpa edited), tapi
-- batas edit-nya tidak aktif — tombol Ubah selalu muncul.

alter table public.feedback
    add column if not exists edited boolean not null default false;
