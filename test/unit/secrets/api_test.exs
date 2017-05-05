defmodule Ael.Secrets.APITest do
  use ExUnit.Case
  alias Ael.Secrets.API
  alias Ael.Secrets.Secret

  test "signes url's with resource name" do
    {:ok, secret} = API.create_secret(%{
      action: "PUT",
      bucket: "declarations-dev",
      resource_id: "uuid",
      resource_name: "passport.jpg"
    })

    assert %Secret{
      action: "PUT",
      bucket: "declarations-dev",
      expires_at: _,
      inserted_at: _,
      resource_id: "uuid",
      resource_name: "passport.jpg",
      secret_url: secret_url
    } = secret

    assert "https://storage.googleapis.com/declarations-dev/uuid/passport.jpg" <> _ = secret_url

    IO.inspect secret
  end

  test "signes url's without resource name" do
    {:ok, secret} = API.create_secret(%{
      action: "PUT",
      bucket: "declarations-dev",
      resource_id: "uuid"
    })

    assert %Secret{
      action: "PUT",
      bucket: "declarations-dev",
      expires_at: _,
      inserted_at: _,
      resource_id: "uuid",
      secret_url: secret_url
    } = secret

    assert "https://storage.googleapis.com/declarations-dev/uuid" <> _ = secret_url
  end
end
