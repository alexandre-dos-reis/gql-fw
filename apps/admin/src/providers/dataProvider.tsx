import postgrestRestProvider, {
  defaultPrimaryKeys,
  defaultSchema,
} from "@raphiniert/ra-data-postgrest";
import { fetchUtils } from "react-admin";

export const dataProvider = () =>
  postgrestRestProvider({
    apiUrl: import.meta.env.VITE_ADMIN_POSTGREST_API,
    httpClient: fetchUtils.fetchJson,
    defaultListOp: "eq",
    primaryKeys: defaultPrimaryKeys,
    schema: defaultSchema,
  });
