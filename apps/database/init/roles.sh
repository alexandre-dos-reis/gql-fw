#!/bin/bash
set -e

echo -e "\n Creating roles...\n"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	    drop role if exists ${DATABASE_OWNER};
	    create role ${DATABASE_OWNER} with login password '${DATABASE_OWNER_PASSWORD}' superuser;
	    grant connect on database ${POSTGRES_DB} to ${DATABASE_OWNER};
	    grant all on database ${POSTGRES_DB} to ${DATABASE_OWNER};

	    drop role if exists ${AUTHENTICATOR_ROLE};
	    create role ${AUTHENTICATOR_ROLE} with login password '${AUTHENTICATOR_PASSWORD}' noinherit;

	    drop role if exists ${ANON_ROLE};
	    create role ${ANON_ROLE} nologin;
	    grant ${ANON_ROLE} to ${AUTHENTICATOR_ROLE};

	    drop role if exists ${PERSON_ROLE};
	    create role ${PERSON_ROLE} nologin;
	    grant ${PERSON_ROLE} to ${AUTHENTICATOR_ROLE};
EOSQL
