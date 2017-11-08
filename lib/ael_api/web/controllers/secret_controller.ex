defmodule Ael.Web.SecretController do
  @moduledoc false
  use Ael.Web, :controller
  alias Ael.Secrets.API
  alias Ael.Secrets.Secret
  alias Ael.Utils

  action_fallback Ael.Web.FallbackController

  def create(conn, %{"secret" => secret_params}) do
    backend = Utils.get_from_registry(:object_storage_backend)

    with {:ok, %Secret{} = secret} <- API.create_secret(secret_params, backend) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", secret.secret_url)
      |> render("show.json", secret: secret)
    end
  end

  def validate(conn, params) do
    with {:ok, is_valid} <- API.validate_entity(params) do
      render(conn, "validator.json", is_valid: is_valid)
    end
  end
end
