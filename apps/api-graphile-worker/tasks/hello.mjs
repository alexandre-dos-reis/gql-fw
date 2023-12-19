export default async function (payload, helper) {
  const { name } = payload;
  helper.logger.info(`Hello, ${name}`);
}
