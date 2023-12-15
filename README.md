# Postgres Framework

# Todos

- Migrate the Casdoor database to Postgres.
- Write a script to [initialize Casdoor](https://casdoor.org/fr/docs/deployment/data-initialization/) by creating a public/private keys certificates and transform them to jwk used by PostGrest.
  - The [config file](https://github.com/casbin/casdoor/blob/master/init_data.json.template) is the same as [the api](https://door.casdoor.com/swagger/#/).

## Resources

- [Fullstack Graphql App Example](https://github.com/taneba/fullstack-graphql-app/tree/main)
- [Postres Idempotent Operations](https://wiki.postgresql.org/wiki/Idempotent_Deployment)
- [How to generate a JWK representing a self-signed certificate](https://darutk.medium.com/jwk-representing-self-signed-certificate-65276d70021b)
