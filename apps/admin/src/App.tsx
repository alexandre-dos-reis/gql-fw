import { Admin, Resource } from "react-admin";
import { dataProvider } from "./providers/dataProvider";
import { bookResource } from "./resources/books";

const App = () => (
  <Admin dataProvider={dataProvider()}>
    <Resource {...bookResource} />
  </Admin>
);

export default App;
