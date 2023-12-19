--! Previous: -
--! Hash: sha1:83c6b22105c7a3ca428e59f6386642f0b955f6c1

-- Common extensions
create extension if not exists plpgsql with schema pg_catalog;
create extension if not exists "uuid-ossp" with schema public;
create extension if not exists citext with schema public;
create extension if not exists pgcrypto with schema public;
create extension if not exists unaccent with schema public;

-- Reset
drop schema if exists :PUBLIC_SCHEMA cascade;
drop schema if exists :PRIVATE_SCHEMA cascade;
drop schema if exists :ADMIN_SCHEMA cascade;
drop schema if exists app_utils cascade;
drop schema if exists app_types cascade;

revoke all on schema public from public;
alter default privileges revoke all on sequences from public;
alter default privileges revoke all on functions from public;

-- Schema
create schema :PUBLIC_SCHEMA;
create schema :PRIVATE_SCHEMA;
create schema :ADMIN_SCHEMA;
create schema app_utils;
create schema app_types;

grant all on schema public to :DATABASE_OWNER;
grant usage on schema public, :PUBLIC_SCHEMA, :ADMIN_SCHEMA, app_utils, app_types to :PERSON_ROLE;
grant usage on schema :PUBLIC_SCHEMA to :ANON_ROLE;

alter default privileges in schema public, :PUBLIC_SCHEMA, :ADMIN_SCHEMA, app_utils, app_types grant usage, select on sequences to :PERSON_ROLE;
alter default privileges in schema public, :PUBLIC_SCHEMA, :ADMIN_SCHEMA, app_utils, app_types grant execute on functions to :PERSON_ROLE;

/*
 * Schema APP_UTILS
 */
create or replace function app_utils.slugify(v text) returns text as $$
begin
  -- 1. trim trailing and leading whitespaces from text
  -- 2. remove accents (diacritic signs) from a given text
  -- 3. lowercase unaccented text
  -- 4. replace non-alphanumeric (excluding hyphen, underscore) with a hyphen
  -- 5. trim leading and trailing hyphens
  return trim(BOTH '-' FROM regexp_replace(lower(public.unaccent(trim(v))), '[^a-z0-9\\-_]+', '-', 'gi'));
end;
$$ language PLPGSQL strict immutable ;

 -- https://postgraphile.org/postgraphile/next/postgresql-schema-design/#using-the-authorized-user
create or replace function app_utils.get_current_user_id() returns uuid as $$
begin
  return (current_setting('request.jwt.claims', true)::json->>'sub')::uuid;
end;
$$ language plpgsql volatile;


create or replace function app_utils.get_current_user_role() returns text as $$
declare
  claims json;
begin
  claims = current_setting('request.jwt.claims', true)::json;

  if (claims->>'isAdmin')::boolean is true then
    return 'admin';
  end if;

  return claims->'roles'->0->>'name';
end;
$$ language plpgsql stable;

create or replace function app_utils.set_updated_at_columns() returns trigger as $$
begin
  new.updated_at := current_timestamp;
  new.updated_by_role := app_utils.get_current_user_role();
  new.updated_by_id := app_utils.get_current_user_id();
return new;
end;
$$ language plpgsql;


/*
 * Schema APP_TYPES
 */
create type app_types.lang_code as enum ('fr', 'en', 'es');

/*
 * Schema APP_PRIVATE
 */
create table if not exists :PRIVATE_SCHEMA.languages (
  id app_types.lang_code primary key not null,
  name text not null,
  name_in_native_language text not null,
  date_format text not null,
  currency text not null,
  mult_to_euro decimal not null default 1,
  slug text not null generated always as (app_utils.slugify(name)) stored,
  is_published boolean not null default false,

  created_at timestamp not null default now(),
  created_by_id uuid not null default app_utils.get_current_user_id(),
  created_by_role name not null default app_utils.get_current_user_role(),
  updated_at timestamp not null default now(),
  updated_by_id uuid not null default app_utils.get_current_user_id(),
  updated_by_role name not null default app_utils.get_current_user_role()
);

create trigger languages_updated_at before update
  on :PRIVATE_SCHEMA.languages
  for each row
  execute procedure app_utils.set_updated_at_columns();

create table if not exists :PRIVATE_SCHEMA.products (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),

  stock integer not null default 0,
  price integer not null default 0,
  is_published boolean,

  created_at timestamp not null default now(),
  created_by_id uuid not null default app_utils.get_current_user_id(),
  created_by_role name not null default app_utils.get_current_user_role(),
  updated_at timestamp not null default now(),
  updated_by_id uuid not null default app_utils.get_current_user_id(),
  updated_by_role name not null default app_utils.get_current_user_role()
);

create trigger products_updated_at before update
  on :PRIVATE_SCHEMA.products
  for each row
  execute procedure app_utils.set_updated_at_columns();

create table if not exists :PRIVATE_SCHEMA.product_translations (
  product_id uuid references :PRIVATE_SCHEMA.products(id),
  language_code app_types.lang_code references :PRIVATE_SCHEMA.languages(id),
  primary key(product_id, language_code),

  name text not null,
  description text not null,
  slug text not null generated always as (app_utils.slugify(name)) stored,
  is_published boolean not null default false,

  created_at timestamp not null default now(),
  created_by_id uuid not null default app_utils.get_current_user_id(),
  created_by_role name not null default app_utils.get_current_user_role(),
  updated_at timestamp not null default now(),
  updated_by_id uuid not null default app_utils.get_current_user_id(),
  updated_by_role name not null default app_utils.get_current_user_role()
);

create trigger product_translations_updated_at before update
  on :PRIVATE_SCHEMA.product_translations
  for each row
  execute procedure app_utils.set_updated_at_columns();

/*
 * Schema APP_ADMIN
 */
create or replace view :ADMIN_SCHEMA.languages as (
  select id, name, name_in_native_language, date_format, currency, slug, mult_to_euro, is_published from :PRIVATE_SCHEMA.languages
);

create or replace view :ADMIN_SCHEMA.lang_codes as (
  with lang_codes as (
    select unnest(enum_range(null::app_types.lang_code)) as id
  )
  select lc.id from lang_codes lc where lc.id not in (
    select id from :ADMIN_SCHEMA.languages
  )
);

create or replace view :ADMIN_SCHEMA.products as (
  select id, stock, price, is_published from :PRIVATE_SCHEMA.products
);

create or replace view :ADMIN_SCHEMA.product_translations as (
  select product_id, language_code, name, description, slug, is_published from :PRIVATE_SCHEMA.product_translations
);

grant all on table 
  :ADMIN_SCHEMA.languages,
  :ADMIN_SCHEMA.product_translations, 
  :ADMIN_SCHEMA.products,
  :ADMIN_SCHEMA.lang_codes
to :PERSON_ROLE;
