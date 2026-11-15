-- Public portfolio media bucket; creators can only write inside their own user-id folder.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('creator-portfolio','creator-portfolio',true,52428800,array['image/jpeg','image/png','image/webp','image/gif','video/mp4','video/webm','application/pdf'])
on conflict (id) do update set public=true,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;
drop policy if exists "Public can view creator portfolio media" on storage.objects;
create policy "Public can view creator portfolio media" on storage.objects for select to anon,authenticated using (bucket_id='creator-portfolio');
drop policy if exists "Creators upload to their own portfolio folder" on storage.objects;
create policy "Creators upload to their own portfolio folder" on storage.objects for insert to authenticated with check (bucket_id='creator-portfolio' and (storage.foldername(name))[1]=(select auth.uid())::text);
drop policy if exists "Creators update their own portfolio media" on storage.objects;
create policy "Creators update their own portfolio media" on storage.objects for update to authenticated using (bucket_id='creator-portfolio' and (storage.foldername(name))[1]=(select auth.uid())::text) with check (bucket_id='creator-portfolio' and (storage.foldername(name))[1]=(select auth.uid())::text);
drop policy if exists "Creators delete their own portfolio media" on storage.objects;
create policy "Creators delete their own portfolio media" on storage.objects for delete to authenticated using (bucket_id='creator-portfolio' and (storage.foldername(name))[1]=(select auth.uid())::text);
