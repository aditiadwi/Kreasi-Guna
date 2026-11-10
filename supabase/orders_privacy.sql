-- Privasi pesanan: tabel orders hanya boleh dibaca pemiliknya dan admin.
-- Sebelumnya policy SELECT mengizinkan anon, sehingga siapa pun di internet bisa
-- menarik seluruh pesanan (nama, email, telepon, alamat) lewat REST + anon key.
-- Jalankan file ini di Supabase SQL Editor SEBELUM deploy app.js versi baru.
--
-- CARA PAKAI AMAN (dua tahap, satu file):
--   1. Seleksi HANYA blok "LANGKAH 0" di bawah lalu Run -> kirim hasilnya ke agent.
--      Supabase menjalankan teks yang diseleksi saja, jadi migrasi belum tersentuh.
--   2. Setelah rollback disiapkan dari hasil itu, seleksi SELURUH file lalu Run.

-- ================= LANGKAH 0: read-only, tidak mengubah apa pun =================
select json_build_object(
  'rls_aktif', (select relrowsecurity from pg_class where oid = 'public.orders'::regclass),
  'policies', (select coalesce(json_agg(json_build_object(
      'nama', policyname, 'cmd', cmd, 'roles', roles::text,
      'using', qual, 'check', with_check)), '[]'::json)
    from pg_policies where schemaname = 'public' and tablename = 'orders'),
  'kolom_token_ada', (select count(*) from information_schema.columns
    where table_schema = 'public' and table_name = 'orders'
      and column_name = 'tracking_token')
) as keadaan_sekarang;

-- ================= LANGKAH 1: migrasi =================
alter table public.orders enable row level security;

-- Kalau RLS sebelumnya mati, belum ada policy tulis sama sekali; mengaktifkan RLS
-- tanpa ini akan membuat checkout gagal insert. Jadi policy tulis hanya dibuat
-- bila belum ada, sehingga tidak melebarkan apa pun yang sudah terpasang.
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'orders' and cmd = 'INSERT'
  ) then
    create policy "orders bisa dibuat checkout"
    on public.orders for insert
    to anon, authenticated
    with check (true);
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'orders' and cmd = 'UPDATE'
  ) then
    create policy "orders diubah admin"
    on public.orders for update
    to authenticated
    using (auth.jwt() ->> 'email' = 'kreasiguna2026@gmail.com')
    with check (auth.jwt() ->> 'email' = 'kreasiguna2026@gmail.com');
  end if;

  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'orders' and cmd = 'DELETE'
  ) then
    create policy "orders dihapus admin"
    on public.orders for delete
    to authenticated
    using (auth.jwt() ->> 'email' = 'kreasiguna2026@gmail.com');
  end if;
end $$;

-- Nama policy SELECT lama tidak diketahui, jadi disapu dari katalog dulu.
-- Policy INSERT/UPDATE/DELETE sengaja tidak disentuh: checkout & dashboard tetap jalan.
do $$
declare
  pol record;
begin
  for pol in
    select policyname
    from pg_policies
    where schemaname = 'public'
      and tablename = 'orders'
      and cmd = 'SELECT'
  loop
    execute format('drop policy if exists %I on public.orders', pol.policyname);
  end loop;
end $$;

-- Pemilik = email login sama dengan customer_email saat checkout.
-- Admin = satu email terdaftar. Sengaja TIDAK memakai predikat "provider = email"
-- seperti cek di admin.html: kalau signup email/password dibuka, predikat itu akan
-- menjadikan akun asing mana pun sebagai admin dan membaca semua pesanan.
create policy "orders terbaca pemilik dan admin"
on public.orders
for select
to authenticated
using (
  customer_email = auth.jwt() ->> 'email'
  or auth.jwt() ->> 'email' = 'kreasiguna2026@gmail.com'
);

-- Kunci lacak untuk tamu: UUID acak per baris. Kolom NOT NULL + default membuat
-- pesanan lama ikut terisi otomatis, jadi tidak perlu backfill terpisah.
alter table public.orders
  add column if not exists tracking_token uuid not null default gen_random_uuid();

-- Pemegang tautan ber-token boleh melihat pesanan itu tanpa login. SECURITY DEFINER
-- melewati RLS dengan sengaja, tapi WHERE hanya cocok pada token yang tepat:
-- token salah = nol baris, dan tidak ada cara menyebut order_id orang lain di sini.
create or replace function public.track_order_by_token(p_token uuid)
returns setof public.orders
language sql
security definer
set search_path = public
as $$
  select * from public.orders where tracking_token = p_token;
$$;

revoke all on function public.track_order_by_token(uuid) from public;
grant execute on function public.track_order_by_token(uuid) to anon, authenticated;