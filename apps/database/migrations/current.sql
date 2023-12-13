-- Read implementation details here:
-- https://github.com/graphile/starter/blob/main/%40app/db/migrations/committed/000001.sql
--
-- Env vars available: 
-- - POSTGRAPHILE_ANON_ROLE: Role used by postgraphile to anonymous user.
-- - POSTGRAPHILE_PERSON_ROLE: Role used bu postgrftaphile to an authenticated user.

-- Common extensions
CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

-- Reset
drop schema if exists app_public cascade;
drop schema if exists app_private cascade;
revoke all on schema public from public;
alter default privileges revoke all on sequences from public;
alter default privileges revoke all on functions from public;

grant all on schema public to :DATABASE_OWNER;

/*
 * Read about our app_public/app_hidden/app_private schemas here:
 * https://www.graphile.org/postgraphile/namespaces/#advice
 *
 * app_public - tables and functions to be exposed to GraphQL (or any other system) - it's the public interface for. This is the main part of your database.
 * app_hidden - same privileges as app_public, but it's not intended to be exposed publicly. It's like "implementation details" of your app_public schema. You may not need it often.
 * app_private - SUPER SECRET STUFF 🕵️ No-one should be able to read this without a SECURITY DEFINER function letting them selectively do things. This is where you store passwords (bcrypted), access tokens (hopefully encrypted), etc. It should be impossible (thanks to RBAC (GRANT/REVOKE)) for web users to access this.
 */
create schema app_public;
create schema app_private;

grant usage on schema public, app_public to :POSTGRAPHILE_PERSON_ROLE;
grant usage on schema app_public to :POSTGRAPHILE_ANON_ROLE;

alter default privileges in schema public, app_public grant usage, select on sequences to :POSTGRAPHILE_PERSON_ROLE;
alter default privileges in schema public, app_public grant execute on functions to :POSTGRAPHILE_PERSON_ROLE;

/*
 * Function update_at
 */
create function app_private.set_updated_at() returns trigger as $$
begin
  new.updated_at := current_timestamp;
  return new;
end;
$$ language plpgsql;

/*
 * Table private persons and private persons_accounts
 */
create table if not exists app_private.persons (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name text not null,
  last_name text not null,
  created_at timestamp not null default now(),
  updated_at timestamp not null default now()
);

-- Trigger name: table-name_function-name
create trigger persons_updated_at before update
  on app_private.persons
  for each row
  execute procedure app_private.set_updated_at();

create table if not exists app_private.persons_accounts (
  person_id        uuid primary key references app_private.persons(id) on delete cascade,
  email            text not null unique check (email ~* '^.+@.+\..+$'),
  password_hash    text not null
);

grant select on table app_private.persons to :POSTGRAPHILE_ANON_ROLE, :POSTGRAPHILE_PERSON_ROLE;

/*
 * Table public persons
 */

create table if not exists app_public.books (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text not null,
  year integer not null,
  author_fullname text not null
);

grant select on table app_public.books to :POSTGRAPHILE_ANON_ROLE, :POSTGRAPHILE_PERSON_ROLE;
