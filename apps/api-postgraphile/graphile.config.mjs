import "graphile-config";
import "postgraphile";
import { PostGraphileAmberPreset } from "postgraphile/presets/amber";
import { PgSimplifyInflectionPreset } from "@graphile/simplify-inflection";
import { makePgService } from "postgraphile/adaptors/pg";
import { PgLazyJWTPreset } from "postgraphile/presets/lazy-jwt";
import { PostGraphileRelayPreset } from "postgraphile/presets/relay";

const isEnvDev = process.env.NODE_ENV === "development";

/** @type {GraphileConfig.Preset} */
export default {
  extends: [
    PostGraphileAmberPreset,
    PgSimplifyInflectionPreset,
    // PostGraphileRelayPreset,
    PgLazyJWTPreset,
  ],
  plugins: [
    {
      name: "IdPlugin",
      version: "0.0.0",

      inflection: {
        replace: {
          attribute(previous, options, details) {
            const name = previous.call(this, details);
            if (name === "rowId") return "id";
            return name;
          },
        },
      },
    },
  ],
  gather: {
    pgJwtTypes: process.env.POSTGRAPHILE_JWT_TYPE,
  },
  schema: {
    pgJwtSecret: process.env.POSTGRAPHILE_JWT_SECRET,
  },
  pgServices: [
    makePgService({
      schemas: ["app_public"],
      connectionString: process.env.POSTGRAPHILE_DB_URL,
      ...(isEnvDev
        ? {
            superuserConnectionString:
              process.env.POSTGRAPHILE_DB_SUPERUSER_URL,
          }
        : {}),
    }),
  ],
  grafserv: {
    dangerouslyAllowAllCORSRequests: isEnvDev,
    port: process.env.POSTGRAPHILE_PORT,
    watch: isEnvDev,
  },
  disablePlugins: ["NodePlugin"],
  grafast: {
    explain: isEnvDev,
    context: (_, args) => {
      return {
        pgSettings: {
          role: process.env.POSTGRAPHILE_ANON_ROLE,
          ...args.contextValue?.pgSettings,
        },
      };
    },
  },
};
