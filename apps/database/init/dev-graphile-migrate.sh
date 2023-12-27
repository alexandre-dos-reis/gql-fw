#!/bin/bash
set -e

if [[ "$NODE_ENV" == "development" ]]; then
	echo -e "\nCreating database shadow for graphile migrate :\n"
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
		  drop if exists database shadow;
		  create database shadow;
	EOSQL
fi
