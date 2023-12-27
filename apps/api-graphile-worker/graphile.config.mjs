const preset = {
  worker: {
    connectionString: process.env.GW_DATABASE_URL,
    maxPoolSize: 10,
    pollInterval: 2000,
    preparedStatements: true,
    schema: "graphile_worker",
    crontabFile: "crontab",
    concurrentJobs: 1,
  },
};

export default preset;
