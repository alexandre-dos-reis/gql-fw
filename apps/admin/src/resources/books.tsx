import {
  Create,
  Datagrid,
  Edit,
  List,
  NumberField,
  NumberInput,
  ResourceProps,
  SimpleForm,
  TextField,
  TextInput,
} from "react-admin";

const Form = () => {
  return (
    <SimpleForm>
      <TextInput source="name" fullWidth />
      <NumberInput source="year" fullWidth />
      <TextInput source="author_fullname" fullWidth />
    </SimpleForm>
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

const list = () => (
  <List>
    <Datagrid rowClick="edit">
      <TextField source="name" />
      <NumberField source="year" />
      <TextField source="author_fullname" />
    </Datagrid>
  </List>
);

export const bookResource: ResourceProps = {
  name: "books",
  edit,
  create,
  list,
};
