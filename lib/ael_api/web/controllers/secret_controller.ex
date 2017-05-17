defmodule Ael.Web.SecretController do
  @moduledoc false
  use Ael.Web, :controller
  alias Ael.Secrets.API
  alias Ael.Secrets.Secret

  action_fallback Ael.Web.FallbackController

  def create(conn, %{"secret" => secret_params}) do
    with {:ok, %Secret{} = secret} <- API.create_secret(secret_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", secret.secret_url)
      |> render("show.json", secret: secret)
    end
  end
end
