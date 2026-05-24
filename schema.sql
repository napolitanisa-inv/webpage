-- ============================================================
-- Napolitani Investments — Rental Applications
-- Run this once in: Supabase Dashboard → SQL Editor → New query
-- ============================================================

create table if not exists rental_applications (
  id                           uuid primary key default gen_random_uuid(),
  created_at                   timestamptz default now(),

  -- Property being applied for
  property_address             text,
  unit_number                  text,
  move_in_date                 date,
  monthly_rent                 numeric(10,2),
  lease_term                   text,
  parking_required             boolean default false,

  -- Primary applicant
  full_name                    text,
  date_of_birth                date,
  email                        text,
  mobile                       text,
  alternate_phone              text,
  id_number                    text,
  current_address              text,
  time_at_address              text,
  reason_for_leaving           text,

  -- Co-applicants / occupants: [{ name, dob, relationship, id_or_age }]
  co_occupants                 jsonb default '[]',

  -- Employment
  employment_type              text,
  employer_name                text,
  job_title                    text,
  employment_start_date        date,
  employer_phone               text,
  employer_address             text,
  gross_monthly_income         numeric(10,2),
  net_monthly_income           numeric(10,2),
  additional_income            jsonb default '[]',  -- [{ source, amount }]
  personal_references          jsonb default '[]',  -- [{ name, relationship, phone, email }]

  -- Rental history: { name, phone, address, monthly_rent, start_date, end_date, reason_for_leaving }
  current_landlord             jsonb,
  previous_landlord            jsonb,

  -- Declarations (yes/no per question key)
  declarations                 jsonb,
  pet_types                    text,
  pet_count                    integer default 0,
  vehicle_make_model           text,
  vehicle_registration         text,

  -- Consent & signature
  consents_acknowledged        boolean default false,
  signature_name               text,
  signature_date               date,
  co_applicant_signature_name  text,

  -- Internal workflow
  status                       text default 'pending'
    check (status in ('pending', 'in_review', 'approved', 'conditional', 'declined'))
);

-- Indexes for common queries
create index if not exists idx_applications_status     on rental_applications (status);
create index if not exists idx_applications_created_at on rental_applications (created_at desc);
create index if not exists idx_applications_email      on rental_applications (email);

-- ============================================================
-- Pre-Applications (tenant pre-screening + vetting fee step)
-- ============================================================

create table if not exists pre_applications (
  id                       uuid primary key default gen_random_uuid(),
  created_at               timestamptz default now(),

  property_address         text,
  listing_reference        text,
  monthly_rental           text,
  move_in_date             date,
  lease_term               text,

  full_name                text,
  id_passport_number       text,
  nationality              text,
  date_of_birth            date,
  mobile                   text,
  email                    text,
  current_address          text,

  employment_status        text,
  employer_name            text,
  employer_phone           text,
  gross_monthly_income     text,
  net_monthly_income       text,
  monthly_debt             text,

  total_occupants          integer,
  num_adults               integer,
  num_minors               integer,
  pets                     text,

  landlord_name            text,
  landlord_phone           text,
  reason_for_leaving       text,
  eviction_history         text,
  eviction_details         text,

  consent_info_accurate    boolean default false,
  consent_vetting_fee      boolean default false,
  consent_popia            boolean default false,
  consent_viewing_terms    boolean default false,
  consent_no_inducement    boolean default false,

  applicant_print_name     text,
  signature_date           date,
  signature                text,
  place_of_signature       text,

  status                   text default 'pending'
    check (status in ('pending', 'vetting_fee_received', 'approved_to_view', 'declined'))
);

create index if not exists idx_pre_apps_status     on pre_applications (status);
create index if not exists idx_pre_apps_created_at on pre_applications (created_at desc);
create index if not exists idx_pre_apps_email      on pre_applications (email);

alter table pre_applications enable row level security;

create policy "pre_public_insert"  on pre_applications for insert to anon with check (true);
create policy "pre_auth_select"    on pre_applications for select to authenticated using (true);
create policy "pre_auth_update"    on pre_applications for update to authenticated using (true) with check (true);

-- ── Row Level Security (rental_applications) ──────────────────
alter table rental_applications enable row level security;

-- Public (anon) visitors can INSERT only — no reads
create policy "public_insert"
  on rental_applications
  for insert
  to anon
  with check (true);

-- Authenticated users (property managers) can read all applications
create policy "auth_select"
  on rental_applications
  for select
  to authenticated
  using (true);

-- Authenticated users can update status and vetting notes
create policy "auth_update"
  on rental_applications
  for update
  to authenticated
  using (true)
  with check (true);
