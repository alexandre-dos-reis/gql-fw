import {
  BooleanInput,
  Create,
  Edit,
  RaRecord,
  RedirectionSideEffect,
  ResourceProps,
  SelectInput,
  SimpleForm,
  TextInput,
  TransformData,
  useGetList,
  useRecordContext,
} from "react-admin";

const Form = (props: { isEdit?: boolean }) => {
  const record = useRecordContext<{ product_id: string }>();
  const { data: translations, isLoading: isLoadingTranslations } = useGetList(
    "product_translations",
    { filter: { product_id: record.product_id } },
  );

  const { data: langs, isLoading: isLoadingLangs } = useGetList("languages");
  return (
    <SimpleForm>
      {props.isEdit ? (
        <TextInput source="language_code" fullWidth disabled />
      ) : (
        <SelectInput
          source="language_code"
          choices={langs?.filter(
            (l) => !translations?.map((t) => t.language_code)?.includes(l.code),
          )}
          optionText="name"
          optionValue="id"
          isLoading={isLoadingLangs || isLoadingTranslations}
          label="Lang"
          fullWidth
        />
      )}
      <TextInput source="name" fullWidth />
      <TextInput source="description" fullWidth />
      <BooleanInput source="is_published" fullWidth />
    </SimpleForm>
  );
};

const redirect: RedirectionSideEffect = (_1, _2, data) => {
  return `products/${data?.product_id}/i18n`;
};

const transform: TransformData = (data) => {
  // this is the "id" used by react-admin, the db doesn't care about it !
  delete data.id;
  // slug is a generated column
  delete data.slug;
  return data;
};

const create = () => (
  <Create redirect={redirect} transform={transform}>
    <Form />
  </Create>
);

const edit = () => (
  <Edit redirect={redirect} transform={transform}>
    <Form isEdit />
  </Edit>
);

export const productTranslationsResource: ResourceProps = {
  name: "product_translations",
  edit,
  create,
  recordRepresentation: (record: RaRecord) => record.name,
};
