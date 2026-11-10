-- Undo untuk orders_privacy.sql.
-- Keadaan sebelum migrasi (terukur 10 Nov 2026 via LANGKAH 0):
--   rls_aktif = false, policies = [], kolom_token_ada = 0
-- Jadi undo = kembali persis ke keadaan itu: tanpa policy, tanpa kolom token,
-- tanpa fungsi, RLS mati.
--
-- PERINGATAN: menjalankan ini MENGEMBALIKAN kebocoran (anon bisa membaca semua
-- pesanan lagi). Pakai hanya bila migrasi merusak checkout/dashboard dan kamu
-- butuh keadaan semula sambil memperbaikinya.

drop function if exists public.track_order_by_token(uuid);

drop policy if exists "orders terbaca pemilik dan admin" on public.orders;
drop policy if exists "orders bisa dibuat checkout" on public.orders;
drop policy if exists "orders diubah admin" on public.orders;
drop policy if exists "orders dihapus admin" on public.orders;

alter table public.orders drop column if exists tracking_token;

alter table public.orders disable row level security;