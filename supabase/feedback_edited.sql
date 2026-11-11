-- feedback.edit_count: jumlah kali ulasan boleh diubah (batas 2).
-- Dijalankan di Supabase Dashboard -> SQL Editor (aman diulang).
--
-- Kode yang membutuhkannya:
--   account.html saveAccEditReview -> update({ message, edit_count: n+1 })
--   account.html accReviewCard     -> sembunyikan tombol "Ubah" kalau edit_count >= 2
--
-- Menggantikan kolom boolean edited (batas 1). Data lama ikut dimigrasikan.
-- Tanpa kolom ini kode tetap jalan (fallback update tanpa edit_count), tapi
-- batas edit-nya tidak aktif — tombol Ubah selalu muncul.

alter table public.feedback
    add column if not exists edit_count smallint not null default 0;

-- Migrasi dari kolom boolean edited lama (kalau masih ada)
do $$
begin
    if exists (
        select 1 from information_schema.columns
        where table_schema = 'public' and table_name = 'feedback' and column_name = 'edited'
    ) then
        update public.feedback set edit_count = 1 where edited = true and edit_count = 0;
        alter table public.feedback drop column edited;
    end if;
end $$;
