defmodule Ael.Web.Endpoint do
  @moduledoc """
  Phoenix Endpoint for ael_api application.
  """
  use Phoenix.Endpoint, otp_app: :ael_api
  alias Confex.Resolver

  plug Plug.RequestId
  plug EView.Plugs.Idempotency
  plug Plug.JSONLogger, log: Logger.level

  plug EView

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Ael.Web.Router

  @doc """
  Dynamically loads configuration from the system environment
  on startup.

  It receives the endpoint configuration from the config files
  and must return the updated configuration.
  """
  def load_from_system_env(config) do
    config = Resolver.resolve!(config)

    unless config[:secret_key_base] do
      raise "Set SECRET_KEY environment variable!"
    end

    {:ok, config}
  end
end
