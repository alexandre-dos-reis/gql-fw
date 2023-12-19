import {
  Create,
  Datagrid,
  Edit,
  EditButton,
  CreateButton,
  List,
  NumberField,
  NumberInput,
  ReferenceManyField,
  ResourceProps,
  TabbedForm,
  TextField,
  useRecordContext,
  useGetList,
  FunctionField,
  ReferenceField,
  BooleanField,
} from "react-admin";

const Form = () => {
  const record = useRecordContext();
  return (
    <TabbedForm>
      <TabbedForm.Tab label="General">
        <NumberInput source="price" label="Price in euros" fullWidth />
        <NumberInput source="stock" fullWidth />
      </TabbedForm.Tab>
      {!record ? null : (
        <TabbedForm.Tab label="Translations" path="i18n">
          <CreateButton
            resource="product_translations"
            state={{ record: { product_id: record.id } }}
          />
          <ReferenceManyField
            reference="product_translations"
            target="product_id"
          >
            <Datagrid
              sx={{
                width: "100%",
                "& .column-comment": {
                  maxWidth: "20em",
                  overflow: "hidden",
                  textOverflow: "ellipsis",
                  whiteSpace: "nowrap",
                },
              }}
            >
              <ReferenceField
                source="language_code"
                reference="languages"
                label="Lang"
              />
              <TextField source="name" />
              <TextField source="slug" />
              <TextField source="description" />
              <BooleanField source="is_published" />
              <EditButton />
            </Datagrid>
          </ReferenceManyField>
        </TabbedForm.Tab>
      )}
    </TabbedForm>
  );
};

const create = () => (
  <Create>
    <Form />
  </Create>
);

const edit = () => (
  <Edit>
    <Form />
  </Edit>
);

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const NameField = (p: { label?: string }) => {
  const record = useRecordContext();
  const { data, isSuccess } = useGetList("product_translations", {
    filter: {
      product_id: record.id,
    },
    sort: { field: "language_code", order: "ASC" },
  });

  let output = "No title";

  if (isSuccess && data?.length > 0) {
    output = data?.[0].name + ` - [${data?.[0].language_code}]`;
  }
  return <FunctionField render={() => output} />;
};

const list = () => (
  <List>
    <Datagrid rowClick="edit">
      <NameField label="Name" />
      <NumberField source="price" />
      <NumberField source="stock" />
    </Datagrid>
  </List>
);

export const productsResource: ResourceProps = {
  name: "products",
  edit,
  create,
  list,
  recordRepresentation: <NameField />,
};
