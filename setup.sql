-- Jalankan sekali pada proyek Supabase BARU melalui SQL Editor.
create table public.teachers (user_id uuid primary key references auth.users(id) on delete cascade);
alter table public.teachers enable row level security;
create policy "read own teacher membership" on public.teachers for select to authenticated using (user_id = (select auth.uid()));
grant select on public.teachers to authenticated;
revoke insert, update, delete on public.teachers from anon, authenticated;
create table public.profiles (id uuid primary key references auth.users(id) on delete cascade, name text not null check(char_length(name) between 1 and 150), grade text not null check(grade in ('VII','VIII','IX')));
create table public.materials (id uuid primary key default gen_random_uuid(), teacher_id uuid not null references auth.users(id), title text not null, grade text not null check(grade in ('VII','VIII','IX')), body text not null, file_path text, question text, options jsonb, answer integer check(answer between 0 and 2), created_at timestamptz not null default now());
create table public.progress (student_id uuid not null references public.profiles(id) on delete cascade, material_id uuid not null references public.materials(id) on delete cascade, completed boolean not null default false, score integer check(score in (0,100)), updated_at timestamptz not null default now(), primary key(student_id,material_id));
alter table public.profiles enable row level security;
alter table public.materials enable row level security;
alter table public.progress enable row level security;
create policy "own profile or teacher" on public.profiles for select to authenticated using (id=(select auth.uid()) or exists(select 1 from public.teachers where user_id=(select auth.uid())));
create policy "create own profile" on public.profiles for insert to authenticated with check(id=(select auth.uid()));
create policy "authenticated material read" on public.materials for select to authenticated using(true);
create policy "teacher material insert" on public.materials for insert to authenticated with check(teacher_id=(select auth.uid()) and exists(select 1 from public.teachers where user_id=(select auth.uid())));
create policy "own progress or teacher" on public.progress for select to authenticated using(student_id=(select auth.uid()) or exists(select 1 from public.teachers where user_id=(select auth.uid())));
create policy "own progress insert" on public.progress for insert to authenticated with check(student_id=(select auth.uid()));
create policy "own progress update" on public.progress for update to authenticated using(student_id=(select auth.uid())) with check(student_id=(select auth.uid()));
grant select,insert on public.profiles,public.materials to authenticated;
grant select,insert,update on public.progress to authenticated;
create index materials_grade_idx on public.materials(grade);
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types) values ('materials','materials',false,10485760,array['application/pdf','image/png','image/jpeg','audio/mpeg','video/mp4']);
create policy "read material attachments" on storage.objects for select to authenticated using(bucket_id='materials');
create policy "teacher upload" on storage.objects for insert to authenticated with check(bucket_id='materials' and (storage.foldername(name))[1]=(select auth.uid())::text and exists(select 1 from public.teachers where user_id=(select auth.uid())));
create policy "teacher cleanup own file" on storage.objects for delete to authenticated using(bucket_id='materials' and (storage.foldername(name))[1]=(select auth.uid())::text and exists(select 1 from public.teachers where user_id=(select auth.uid())));
-- ADMIN: setelah guru mendaftar dan mengonfirmasi email, jalankan terpisah:
-- insert into public.teachers(user_id) select id from auth.users where email='EMAIL_GURU';
