import {
  Admin,
  EditGuesser,
  ListGuesser,
  Resource,
  fetchUtils,
} from "react-admin";
import postgrestRestProvider, {
  IDataProviderConfig,
  defaultPrimaryKeys,
  defaultSchema,
} from "@raphiniert/ra-data-postgrest";

console.log(import.meta.env.VITE_ADMIN_POSTGREST_API);

const config: IDataProviderConfig = {
  apiUrl: import.meta.env.VITE_ADMIN_POSTGREST_API,
  httpClient: fetchUtils.fetchJson,
  defaultListOp: "eq",
  primaryKeys: defaultPrimaryKeys,
  schema: defaultSchema,
};
const App = () => (
  <Admin dataProvider={postgrestRestProvider(config)}>
    <Resource name="books" list={ListGuesser} edit={EditGuesser} />
  </Admin>
);

export default App;
