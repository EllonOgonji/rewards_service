import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :rewards_service, RewardsService.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "rewards_service_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rewards_service, RewardsServiceWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "NL9Xa/k13s7u1xIQog5tDSjL/XHo/yXk2rK/YobRoVjEg9zVCqIBKbK+iL5hwwFi",
  server: false

# Disable Oban in test
config :rewards_service, Oban, testing: :inline

# In test we don't send emails
config :rewards_service, RewardsService.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
