defmodule Ael.Web.FallbackController do
  @moduledoc """
  This controller should be used as `action_fallback` in rest of controllers to remove duplicated error handling.
  """
  use Ael.Web, :controller

  def call(conn, {:error, :access_denied}) do
    conn
    |> put_status(:unauthorized)
    |> render(EView.Views.Error, :"401")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(EView.Views.Error, :"404")
  end

  def call(conn, nil) do
    conn
    |> put_status(:not_found)
    |> render(EView.Views.Error, :"404")
  end
end
