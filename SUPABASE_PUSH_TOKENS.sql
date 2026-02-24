-- Run this in Supabase SQL Editor to store FCM/APNs tokens for push notifications.
-- Your backend or Edge Function can then send push via FCM using these tokens.

create table if not exists public.push_tokens (
  user_id uuid primary key references auth.users(id) on delete cascade,
  token text not null,
  platform text not null default 'ios',
  updated_at timestamptz not null default now()
);

alter table public.push_tokens enable row level security;

create policy "Users can manage own push token"
  on public.push_tokens
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

comment on table public.push_tokens is 'FCM/APNs device tokens for push notifications; used by backend to send to specific users.';
