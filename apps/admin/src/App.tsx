import { Admin, Resource } from "react-admin";
import { dataProvider } from "./providers/dataProvider";
import { bookResource } from "./resources/books";
// @ts-expect-error no ts file provided
import initAuthProvider from "reactadmin-casdoor-authprovider";

const sdkConfig = {
  serverUrl: "http://localhost:8000",
  clientId: "47d92add16d0a4978edd",
  clientSecret: "2d2face453983124550ee0048e761f89ce1ff535",
  appName: "postgres_app",
  organizationName: "postgres_framework",
};
const authProvider = initAuthProvider(sdkConfig);

const App = () => (
  <Admin
    dataProvider={dataProvider()}
    authProvider={authProvider}
    loginPage={authProvider.loginPage}
  >
    <Resource {...bookResource} />
  </Admin>
);

export default App;
