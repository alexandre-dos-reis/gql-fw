import postgrestRestProvider from "@raphiniert/ra-data-postgrest";
import { fetchUtils } from "react-admin";

const httpClient = (
  url: string,
  options: { user: { authenticated: boolean; token: string } },
) => {
  const token = localStorage.getItem("token");
  if (token) {
    options.user = {
      authenticated: true,
      token: `Bearer ${token}`,
    };
  }
  return fetchUtils.fetchJson(url, options);
};

export const dataProvider = postgrestRestProvider({
  apiUrl: import.meta.env.VITE_ADMIN_POSTGREST_API,
  httpClient,
  defaultListOp: "eq",
  primaryKeys: new Map([
    ["product_translations", ["product_id", "language_code"]],
  ]),
  schema: () => import.meta.env.VITE_ADMIN_POSTGREST_SCHEMA,
});
