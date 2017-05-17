defmodule Ael.Secrets.APITest do
  use ExUnit.Case
  alias Ael.Secrets.API
  alias Ael.Secrets.Secret

  test "signes url's with resource name" do
    action = "PUT"
    bucket = "declarations-dev"
    resource_id = "uuid"
    resource_name = "passport.jpg"

    {:ok, secret} = API.create_secret(%{
      action: action,
      bucket: bucket,
      resource_id: resource_id,
      resource_name: resource_name
    })

    assert %Secret{
      action: ^action,
      bucket: ^bucket,
      expires_at: _,
      inserted_at: _,
      resource_id: ^resource_id,
      resource_name: resource_name,
      secret_url: secret_url
    } = secret

    assert "https://storage.googleapis.com/declarations-dev/uuid/passport.jpg?GoogleAccessId=" <> _ = secret_url

    file_path = "test/fixtures/secret.txt"

    headers = [
      {"Accept", "*/*"},
      {"Connection", "close"},
      {"Cache-Control", "no-cache"},
      {"Content-Type", ""},
    ]
    %HTTPoison.Response{body: _, status_code: code} = HTTPoison.put!(secret.secret_url, {:file, file_path}, headers)

    assert 200 == code

    {:ok, secret} = API.create_secret(%{
      action: "GET",
      bucket: bucket,
      resource_id: resource_id,
      resource_name: resource_name
    })

    %HTTPoison.Response{body: body, status_code: code} = HTTPoison.get!(secret.secret_url)
    assert 200 == code
    assert File.read!(file_path) == body
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
