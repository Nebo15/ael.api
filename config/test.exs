use Mix.Config

# Configuration for test environment
config :ex_unit, capture_log: true


# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ael_api, Ael.Web.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Run acceptance test in concurrent mode
config :ael_api, sql_sandbox: true

config :ael_api,
  known_buckets: ["declarations-dev"],
  secret_ttl: 600 # seconds
