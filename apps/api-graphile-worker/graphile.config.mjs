const preset = {
  worker: {
    connectionString: "postgres://alex:alex@localhost:9854/main",
    maxPoolSize: 10,
    pollInterval: 2000,
    preparedStatements: true,
    schema: "graphile_worker",
    crontabFile: "crontab",
    concurrentJobs: 1,
  },
};

export default preset;
