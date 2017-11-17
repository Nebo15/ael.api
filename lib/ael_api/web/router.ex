defmodule Ael.Web.Router do
  @moduledoc """
  The router provides a set of macros for generating routes
  that dispatch to specific controllers and actions.
  Those macros are named after HTTP verbs.

  More info at: https://hexdocs.pm/phoenix/Phoenix.Router.html
  """
  use Ael.Web, :router
  use Plug.ErrorHandler

  require Logger

  pipeline :api do
    plug :accepts, ["json"]
    plug :put_secure_browser_headers

    # You can allow JSONP requests by uncommenting this line:
    # plug :allow_jsonp
  end

  scope "/", Ael.Web do
    pipe_through :api

    post "/media_content_storage_secrets", SecretController, :create
    post "/validate_signed_entity", SecretController, :validate
  end

  defp handle_errors(%Plug.Conn{status: 500} = conn, %{kind: kind, reason: reason, stack: stacktrace}) do
    Plug.LoggerJSON.log_error(kind, reason, stacktrace)
    send_resp(conn, 500, Poison.encode!(%{errors: %{detail: "Internal server error"}}))
  end

  defp handle_errors(_, _), do: nil
end
