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
revoke all on schema public from public;
alter default privileges revoke all on sequences from public;
alter default privileges revoke all on functions from public;

grant all on schema public to :DATABASE_OWNER;

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

grant usage on schema public, :PUBLIC_SCHEMA, :ADMIN_SCHEMA to :PERSON_ROLE;
grant usage on schema :PUBLIC_SCHEMA to :ANON_ROLE;

alter default privileges in schema public, :PUBLIC_SCHEMA, :ADMIN_SCHEMA grant usage, select on sequences to :PERSON_ROLE;
alter default privileges in schema public, :PUBLIC_SCHEMA, :ADMIN_SCHEMA grant execute on functions to :PERSON_ROLE;

/*
 * Function update_at
 */
create function :PRIVATE_SCHEMA.set_updated_at() returns trigger as $$
begin
  new.updated_at := current_timestamp;
  return new;
end;
$$ language plpgsql;

/*
 * Table private persons and private persons_accounts
 */
drop type if exists :PRIVATE_SCHEMA.person_type;
create type :PRIVATE_SCHEMA.person_type AS enum ('admin', 'user', 'org');

create table if not exists :PRIVATE_SCHEMA.persons (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name text not null,
  last_name text not null,
  type :PRIVATE_SCHEMA.person_type not null,
  created_at timestamp not null default now(),
  updated_at timestamp not null default now()
);

-- Trigger name: table-name_function-name
create trigger persons_updated_at before update
  on :PRIVATE_SCHEMA.persons
  for each row
  execute procedure :PRIVATE_SCHEMA.set_updated_at();

create table if not exists :PRIVATE_SCHEMA.persons_accounts (
  person_id        uuid primary key references :PRIVATE_SCHEMA.persons(id) on delete cascade,
  email            text not null unique check (email ~* '^.+@.+\..+$'),
  password_hash    text not null
);

grant select on table :PRIVATE_SCHEMA.persons to :ANON_ROLE, :PERSON_ROLE;

/*
 * Table public persons
 */

create table if not exists :PRIVATE_SCHEMA.books (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text not null,
  year integer not null,
  author_fullname text not null
);


create or replace view :PUBLIC_SCHEMA.books as (
  select * from :PRIVATE_SCHEMA.books
);


grant all on table :PUBLIC_SCHEMA.books to :PERSON_ROLE, :ANON_ROLE;
