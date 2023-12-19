import {
  BooleanField,
  BooleanInput,
  Create,
  Datagrid,
  Edit,
  List,
  NumberField,
  NumberInput,
  RaRecord,
  ResourceProps,
  SelectInput,
  SimpleForm,
  TextField,
  TextInput,
  TransformData,
  required,
  useGetList,
} from "react-admin";

const Form = (props: { isEdit?: boolean }) => {
  const { data, isLoading } = useGetList("lang_codes");
  return (
    <SimpleForm>
      {props.isEdit ? (
        <TextInput source="id" fullWidth disabled label="Locale" />
      ) : (
        <SelectInput
          source="id"
          choices={data}
          optionText="id"
          optionValue="id"
          defaultValue={"id"}
          validate={required()}
          isLoading={isLoading}
          label="Locale"
          fullWidth
        />
      )}
      <TextInput source="name" fullWidth />
      <TextInput source="name_in_native_language" fullWidth />
      <TextInput source="date_format" fullWidth />
      <TextInput source="currency" fullWidth />
      <NumberInput source="mult_to_euro" fullWidth />
      <BooleanInput source="is_published" fullWidth />
    </SimpleForm>
  );
};

const transform: TransformData = (data) => {
  delete data.slug;
  return data;
};

const create = () => (
  <Create transform={transform}>
    <Form />
  </Create>
);

const edit = () => (
  <Edit transform={transform}>
    <Form isEdit />
  </Edit>
);

const list = () => (
  <List>
    <Datagrid rowClick="edit">
      <TextField source="id" label="Locale" />
      <TextField source="name" />
      <TextField source="slug" />
      <TextField source="name_in_native_language" />
      <TextField source="date_format" />
      <TextField source="currency" />
      <NumberField source="mult_to_euro" />
      <BooleanField source="is_published" />
    </Datagrid>
  </List>
);

export const languagesResource: ResourceProps = {
  name: "languages",
  edit,
  create,
  list,
  recordRepresentation: (record: RaRecord) => record.name,
};
