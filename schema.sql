-- StudyVix database schema for Supabase.
-- Run in Supabase SQL Editor. RLS ensures users can access only their own records.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  exam_track text not null default 'JAMB' check (exam_track in ('JAMB','IJMB')),
  subject_combination text[] not null default '{}',
  daily_goal_minutes integer not null default 60 check (daily_goal_minutes between 10 and 600),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.study_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  minutes integer not null default 0 check (minutes >= 0),
  quizzes_completed integer not null default 0 check (quizzes_completed >= 0),
  correct_answers integer not null default 0 check (correct_answers >= 0),
  topic_key text,
  completed_at timestamptz not null default now()
);

create table if not exists public.study_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  subject text not null,
  exam_track text not null check (exam_track in ('JAMB','IJMB')),
  day_of_week smallint not null check (day_of_week between 0 and 6),
  start_time time not null,
  duration_minutes integer not null default 45 check (duration_minutes between 10 and 240),
  created_at timestamptz not null default now()
);

create table if not exists public.saved_notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  subject text not null,
  exam_track text not null check (exam_track in ('JAMB','IJMB')),
  topic text not null default '',
  body text not null,
  source_label text not null default 'Unverified study note',
  verified_source_url text,
  saved_offline boolean not null default false,
  updated_at timestamptz not null default now()
);

create table if not exists public.quiz_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  exam_track text not null check (exam_track in ('JAMB','IJMB')),
  subject text not null,
  total_questions integer not null check (total_questions > 0),
  correct_answers integer not null check (correct_answers between 0 and total_questions),
  question_set_version text not null default 'demo',
  completed_at timestamptz not null default now()
);

-- Content is curated/admin-published. Students may read published content, not modify it.
create table if not exists public.content_items (
  id uuid primary key default gen_random_uuid(),
  exam_track text not null check (exam_track in ('JAMB','IJMB')),
  subject text not null,
  topic text not null,
  content_type text not null check (content_type in ('syllabus','note','question','explanation','practice')),
  title text not null,
  body text not null,
  options jsonb,
  correct_option integer,
  explanation text,
  source_name text not null,
  source_url text,
  verification_status text not null default 'unverified' check (verification_status in ('unverified','reviewed','verified','retired')),
  reviewed_by text,
  reviewed_at timestamptz,
  rights_status text not null default 'permission_needed' check (rights_status in ('original','public_domain','licensed','permission_needed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (correct_option is null or (options is not null and correct_option >= 0 and correct_option < jsonb_array_length(options)))
);

create index if not exists study_progress_user_date_idx on public.study_progress(user_id, completed_at desc);
create index if not exists saved_notes_user_idx on public.saved_notes(user_id);
create index if not exists content_items_filter_idx on public.content_items(exam_track, subject, topic, verification_status);

alter table public.profiles enable row level security;
alter table public.study_progress enable row level security;
alter table public.study_sessions enable row level security;
alter table public.saved_notes enable row level security;
alter table public.quiz_attempts enable row level security;
alter table public.content_items enable row level security;

create policy "Profiles: read own" on public.profiles for select to authenticated using (auth.uid() = id);
create policy "Profiles: insert own" on public.profiles for insert to authenticated with check (auth.uid() = id);
create policy "Profiles: update own" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);
create policy "Progress: own records" on public.study_progress for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Sessions: own records" on public.study_sessions for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Notes: own records" on public.saved_notes for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Attempts: own records" on public.quiz_attempts for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Published content readable" on public.content_items for select to anon, authenticated using (verification_status in ('reviewed','verified'));
-- Do not create public write policies for content_items. Use a trusted admin workflow.
-- Add a trigger/profile bootstrap in production if you want automatic profile creation.
