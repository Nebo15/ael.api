# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :ael_api, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:ael_api, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#
# Or read environment variables in runtime (!) as:
#
#     :var_name, "${ENV_VAR_NAME}"
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration

config :ael_api,
  namespace: Ael

# Configures the endpoint
config :ael_api, Ael.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "b9WHCgR5TGcrSnd0TNihII7przcYtrVPnSw4ZAXtHOjAVCLZJDb20CQ0ZP65/xbw",
  render_errors: [view: EView.Views.PhoenixError, accepts: ~w(json)]

# Configures Elixir's Logger
config :logger, :console, format: "$message\n"

config :ael_api,
  known_buckets: {:system, :list, "KNOWN_BUCKETS", []},
  secrets_ttl: {:system, :integer, "SECRETS_TTL", 600} # seconds

# Configures Digital Signature API
config :ael_api, Ael.API.Signature,
  endpoint: {:system, "DIGITAL_SIGNATURE_ENDPOINT", "http://35.187.186.145"},
  timeouts: [
    connect_timeout: {:system, :integer, "DIGITAL_SIGNATURE_REQUEST_TIMEOUT", 30_000},
    recv_timeout: {:system, :integer, "DIGITAL_SIGNATURE_REQUEST_TIMEOUT", 30_000},
    timeout: {:system, :integer, "DIGITAL_SIGNATURE_REQUEST_TIMEOUT", 30_000}
  ]

config :ael_api, :google_cloud_storage,
  service_account_key_path: {:system, "SERVICE_ACCOUNT_KEY_PATH", "priv/service_account_key.json"}

config :ael_api, :swift_endpoint, {:system, "SWIFT_ENDPOINT", "set_swift_enpoint"}
config :ael_api, :swift_tenant_id, {:system, "SWIFT_TENANT_ID", "set_swift_tenant_id"}
config :ael_api, :swift_temp_url_key, {:system, "SWIFT_TEMP_URL_KEY", "set_swift_temp_url_key"}
config :ael_api, :object_storage_backend, {:system, "OBJECT_STORAGE_BACKEND", "set_object_storage_backend"}

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env}.exs"
