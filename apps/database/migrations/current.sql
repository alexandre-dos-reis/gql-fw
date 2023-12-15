-- Read implementation details here:
-- https://github.com/graphile/starter/blob/main/%40app/db/migrations/committed/000001.sql
--
-- Env vars available: 
-- - ANON_ROLE: Role used by postgraphile to anonymous user.
-- - PERSON_ROLE: Role used bu postgrftaphile to an authenticated user.

-- Common extensions
create extension if not exists plpgsql with schema pg_catalog;
create extension if not exists "uuid-ossp" with schema public;
create extension if not exists citext with schema public;
create extension if not exists pgcrypto with schema public;

-- Reset
drop schema if exists :PUBLIC_SCHEMA cascade;
drop schema if exists :PRIVATE_SCHEMA cascade;
drop schema if exists :ADMIN_SCHEMA cascade;
drop schema if exists app_utils cascade;

revoke all on schema public from public;
alter default privileges revoke all on sequences from public;
alter default privileges revoke all on functions from public;


/*
 * Read about our :PUBLIC_SCHEMA/app_hidden/:PRIVATE_SCHEMA schemas here:
 * https://www.graphile.org/postgraphile/namespaces/#advice
 *
 * :PUBLIC_SCHEMA - tables and functions to be exposed to GraphQL (or any other system) - it's the public interface for. This is the main part of your database.
 * :PRIVATE_SCHEMA - SUPER SECRET STUFF 🕵️ No-one should be able to read this without a SECURITY DEFINER function letting them selectively do things. This is where you store passwords (bcrypted), access tokens (hopefully encrypted), etc. It should be impossible (thanks to RBAC (GRANT/REVOKE)) for web users to access this.
 */
create schema :PUBLIC_SCHEMA;
create schema :PRIVATE_SCHEMA;
create schema :ADMIN_SCHEMA;
create schema app_utils;

grant all on schema public to :DATABASE_OWNER;

grant usage on schema public, :PUBLIC_SCHEMA, :ADMIN_SCHEMA, app_utils to :PERSON_ROLE;
grant usage on schema :PUBLIC_SCHEMA to :ANON_ROLE;

alter default privileges in schema public, :PUBLIC_SCHEMA, :ADMIN_SCHEMA, app_utils grant usage, select on sequences to :PERSON_ROLE;
alter default privileges in schema public, :PUBLIC_SCHEMA, :ADMIN_SCHEMA, app_utils grant execute on functions to :PERSON_ROLE;


/*
 * Function that resturn the current user based on the request
 */
create or replace function app_utils.get_current_user_id() returns uuid as $$
begin
  return (current_setting('request.jwt.claims', true)::json->>'sub')::uuid;
end;
$$ language plpgsql volatile;

/*
 * Function update_at
 */
create or replace function app_utils.set_updated_at_columns() returns trigger as $$
begin
  new.updated_at := current_timestamp;
  new.updated_by_role := current_user;
  new.updated_by_id := auth.get_current_user_id();
return new;
end;
$$ language plpgsql;

/*
 * Table private persons and private persons_accounts
 */
-- drop type if exists :PRIVATE_SCHEMA.person_type;
-- create type :PRIVATE_SCHEMA.person_type AS enum ('admin', 'user', 'org');
--
-- create table if not exists :PRIVATE_SCHEMA.persons (
--   id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
--   first_name text not null,
--   last_name text not null,
--   type :PRIVATE_SCHEMA.person_type not null,
--   created_at timestamp not null default now(),
--   updated_at timestamp not null default now()
-- );
--
-- -- Trigger name: table-name_function-name
-- create trigger persons_updated_at before update
--   on :PRIVATE_SCHEMA.persons
--   for each row
--   execute procedure app_utils.set_updated_at_columns();

-- create table if not exists :PRIVATE_SCHEMA.persons_accounts (
--   person_id        uuid primary key references :PRIVATE_SCHEMA.persons(id) on delete cascade,
--   email            text not null unique check (email ~* '^.+@.+\..+$'),
--   password_hash    text not null
-- );
--
-- grant select on table :PRIVATE_SCHEMA.persons to :ANON_ROLE, :PERSON_ROLE;

/*
 * Table public persons
 */
create table if not exists :PRIVATE_SCHEMA.books (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text not null,
  year integer not null,
  author_fullname text not null,
  created_at timestamp not null default now(),
  created_by_id uuid not null default auth.get_current_user_id(),
  created_by_role name not null default current_user,
  updated_at timestamp not null default now(),
  updated_by_id uuid not null default auth.get_current_user_id(),
  updated_by_role name not null default current_user
);

create or replace view :ADMIN_SCHEMA.books as (
  select id,name,year,author_fullname from :PRIVATE_SCHEMA.books
);

create trigger books_updated_at before update
  on :PRIVATE_SCHEMA.books
  for each row
  execute procedure app_utils.set_updated_at_columns();


grant all on table :ADMIN_SCHEMA.books to :PERSON_ROLE;
