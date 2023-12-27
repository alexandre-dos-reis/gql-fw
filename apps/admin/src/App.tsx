import { Admin, Resource } from "react-admin";
import { dataProvider, authProvider } from "./providers";
import { productsResource } from "./resources/products";
import { productTranslationsResource } from "./resources/product_translations";
import { languagesResource } from "./resources/languages";

const App = () => {
  return (
    <Admin
      dataProvider={dataProvider}
      authProvider={authProvider}
      loginPage={authProvider.loginPage}
    >
      <Resource {...languagesResource} />
      <Resource {...productsResource} />
      <Resource {...productTranslationsResource} />
    </Admin>
  );
};

export default App;
