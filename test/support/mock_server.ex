defmodule Ael.MockServer do
  @moduledoc false

  use Plug.Router

  plug :match
  plug :dispatch

  get "/declaration_signed_content" do
    Plug.Conn.send_resp(conn, 200, Poison.encode!(%{
      "data" => %{
        "content" => %{
          "legal_entity" => %{
            "id" => "1bce381a-7b82-11e7-bb31-be2e44b06b34"
          }
        },
      "is_valid" => true
      },
    }))
  end

  get "/declaration_signed_content_not_valid" do
    Plug.Conn.send_resp(conn, 200, Poison.encode!(%{
      "data" => %{
        "content" => %{
          "legal_entity" => %{
            "id" => "1bce381a-7b82-11e7-bb31-be2e44b06b34"
          }
        },
      "is_valid" => false
      },
    }))
  end

  post "/digital_signatures" do
    {:ok, body, conn} = Plug.Conn.read_body(conn)
    body = Poison.decode!(body)
    Plug.Conn.send_resp(conn, 200, Base.decode64!(body["signed_content"]))
  end
end
