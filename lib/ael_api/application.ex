defmodule Ael do
  @moduledoc """
  This is an entry point of ael_api application.
  """
  use Application
  alias Ael.Web.Endpoint
  alias Confex.Resolver

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Configure Logger severity at runtime
    configure_log_level()

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(Ael.Web.Endpoint, []),
      supervisor(Registry, [:unique, Ael.Registry]),
      # Starts a worker by calling: Ael.Worker.start_link(arg1, arg2, arg3)
      # worker(Ael.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ael.Supervisor]

    application = Supervisor.start_link(children, opts)
    register_gcs_config()

    application
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end

  def register_gcs_config do
    gcs_service_account = load_gcs_service_config()

    {:PrivateKeyInfo,
      :v1,
      {:PrivateKeyInfo_privateKeyAlgorithm, {1, 2, 840, 113_549, 1, 1, 1}, {:asn1_OPENTYPE, <<5, 0>>}},
      der,
      :asn1_NOVALUE} =
      gcs_service_account
      |> Map.get("private_key")
      |> :public_key.pem_decode
      |> List.first
      |> :public_key.pem_entry_decode

    Registry.register(Ael.Registry, :gcs_service_account_id, Map.get(gcs_service_account, "client_email"))
    Registry.register(Ael.Registry, :gcs_service_account_key, :public_key.der_decode(:'RSAPrivateKey', der))
    Registry.register(Ael.Registry, :secrets_ttl, Confex.get_env(:ael_api, :secrets_ttl))
    Registry.register(Ael.Registry, :known_buckets, Confex.get_env(:ael_api, :known_buckets))
    Registry.register(Ael.Registry, :object_storage_backend, Confex.get_env(:ael_api, :object_storage_backend))
    Registry.register(Ael.Registry, :swift_endpoint, Confex.get_env(:ael_api, :swift_endpoint))
    Registry.register(Ael.Registry, :swift_tenant_id, Confex.get_env(:ael_api, :swift_tenant_id))
    Registry.register(Ael.Registry, :swift_temp_url_key, Confex.get_env(:ael_api, :swift_temp_url_key))
  end

  def load_gcs_service_config do
    :ael_api
    |> Confex.get_env(:google_cloud_storage)
    |> Keyword.get(:service_account_key_path)
    |> File.read!()
    |> Poison.decode!()
  end

  # Configures Logger level via LOG_LEVEL environment variable.
  defp configure_log_level do
    case System.get_env("LOG_LEVEL") do
      nil ->
        :ok
      level when level in ["debug", "info", "warn", "error"] ->
        Logger.configure(level: String.to_atom(level))
      level ->
        raise ArgumentError, "LOG_LEVEL environment should have one of 'debug', 'info', 'warn', 'error' values," <>
                             "got: #{inspect level}"
    end
  end

  # Loads configuration in `:on_init` callbacks and replaces `{:system, ..}` tuples via Confex
  @doc false
  def load_from_system_env(config) do
    {:ok, Resolver.resolve!(config)}
  end
end
