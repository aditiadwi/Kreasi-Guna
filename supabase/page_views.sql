-- page_views: pencacah kunjungan per halaman untuk kartu "Page Views" di dashboard admin.
-- Dijalankan sekali di Supabase Dashboard -> SQL Editor.
--
-- Kode yang membutuhkannya:
--   app.js:3817  -> tiap halaman publik manggil rpc('bump_page_view', { p: namaHalaman })
--   admin.html:722 -> select('*').order('views', desc), lalu baca kolom r.page dan r.views
--
-- Catatan RLS: dashboard admin membaca tabel ini pakai ANON KEY (gate admin di
-- admin.html cuma kosmetik, tidak ada service role di client). Jadi kebijakan SELECT
-- di bawah memang harus terbuka — tanpa itu RLS menyaring barisnya diam-diam jadi 0 row
-- dan kartu tetap berbunyi "Belum ada data". Konsekuensinya: siapa pun yang punya anon
-- key bisa melihat jumlah kunjungan per halaman. Angka agregat, tanpa identitas
-- pengunjung. Kalau mau dirahasiakan, pencacah ini harus pindah ke sisi server.

create table if not exists public.page_views (
    page       text primary key,
    views      bigint not null default 0,
    updated_at timestamptz not null default now()
);

alter table public.page_views enable row level security;

-- Hanya baca yang boleh lewat anon key; INSERT/UPDATE/DELETE langsung ditolak,
-- semuanya lewat fungsi bump_page_view di bawah.
drop policy if exists "page_views terbaca dashboard" on public.page_views;
create policy "page_views terbaca dashboard"
    on public.page_views
    for select
    using (true);

-- SECURITY DEFINER supaya bisa menulis walau tabelnya select-only bagi anon.
-- search_path dikunci biar tidak bisa dibajak lewat fungsi search_path lain.
create or replace function public.bump_page_view(p text)
returns void
language sql
security definer
set search_path = public
as $$
    insert into public.page_views (page, views, updated_at)
    values (p, 1, now())
    on conflict (page)
    do update set views = page_views.views + 1,
                  updated_at = now();
$$;

revoke all on function public.bump_page_view(text) from public;
grant execute on function public.bump_page_view(text) to anon, authenticated, service_role;
