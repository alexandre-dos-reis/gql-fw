import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
  overwrite: true,
  schema: process.env.GQL_TYPES_SCHEMA_ENDPOINT,
  generates: {
    "dist/types.ts": {
      plugins: ["typescript"],
    },
  },
};

export default config;
