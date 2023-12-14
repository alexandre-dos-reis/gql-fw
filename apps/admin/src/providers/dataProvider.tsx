import { useEffect, useState } from "react";
import { Admin, Resource } from "react-admin";
import { useApolloClient } from "@apollo/react-hooks";
import pgDataProvider from "ra-postgraphile";

export const useDataProvider = () => {
  const [dataProvider, setDataProvider] = useState(null);
  const client = useApolloClient();

  useEffect(() => {
    (async () => {
      const dataProvider = await pgDataProvider(client);
      setDataProvider(() => dataProvider);
    })();
  }, []);

  useEffect(() => {
    (async () => {
      const dataProvider = await pgDataProvider(client);
      setDataProvider(() => dataProvider);
    })();
  }, []);

  return dataProvider;
};
