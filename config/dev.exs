use Mix.Config

# Configuration for test environment


# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :ael_api, Ael.Web.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :ael_api,
  known_buckets: {:system, :list, "KNOWN_BUCKETS", ["declarations-dev", "legal-entities-dev"]},
  secrets_ttl: {:system, :integer, "SECRETS_TTL", 3 * 600} # seconds

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
