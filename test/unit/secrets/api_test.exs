defmodule Ael.Secrets.APITest do
  use ExUnit.Case
  alias Ael.Secrets.API
  alias Ael.Secrets.Secret

  test "signes url's with resource name (with content-type)" do
    bucket = "declarations-dev"
    resource_id = "uuid"
    resource_name = "test.txt"

    secret = create_secret("PUT", bucket, resource_id, resource_name, MIME.from_path(resource_name), "gcs")

    assert %Secret{
      action: "PUT",
      bucket: ^bucket,
      expires_at: _,
      inserted_at: _,
      resource_id: ^resource_id,
      resource_name: resource_name,
      content_type: "text/plain",
      secret_url: secret_url
    } = secret

    assert "https://storage.googleapis.com/declarations-dev/uuid/test.txt?GoogleAccessId=" <> _ = secret_url

    file_path = "test/fixtures/secret.txt"

    headers = [
      {"Accept", "*/*"},
      {"Connection", "close"},
      {"Cache-Control", "no-cache"},
      {"Content-Type", "text/plain"},
    ]
    %HTTPoison.Response{body: _, status_code: code} = HTTPoison.put!(secret.secret_url, {:file, file_path}, headers)

    assert 200 == code

    secret = create_secret("GET", bucket, resource_id, resource_name, "", "gcs")

    %HTTPoison.Response{body: body, status_code: code} = HTTPoison.get!(secret.secret_url)
    assert 200 == code
    assert File.read!(file_path) == body

    secret = create_secret("HEAD", bucket, resource_id, resource_name, "", "gcs")
    %HTTPoison.Response{status_code: code} = HTTPoison.head!(secret.secret_url)
    assert 200 == code
  end

  test "signes url's with resource name (no content-type)" do
    bucket = "declarations-dev"
    resource_id = "uuid"
    resource_name = "test.txt"

    secret = create_secret("PUT", bucket, resource_id, resource_name, "", "gcs")

    assert %Secret{
      action: "PUT",
      bucket: ^bucket,
      expires_at: _,
      inserted_at: _,
      resource_id: ^resource_id,
      resource_name: resource_name,
      content_type: "",
      secret_url: secret_url
    } = secret

    assert "https://storage.googleapis.com/declarations-dev/uuid/test.txt?GoogleAccessId=" <> _ = secret_url

    file_path = "test/fixtures/secret.txt"

    headers = [
      {"Accept", "*/*"},
      {"Connection", "close"},
      {"Cache-Control", "no-cache"},
      {"Content-Type", ""},
    ]
    %HTTPoison.Response{body: _, status_code: code} = HTTPoison.put!(secret.secret_url, {:file, file_path}, headers)

    assert 200 == code

    secret = create_secret("GET", bucket, resource_id, resource_name, "", "gcs")

    %HTTPoison.Response{body: body, status_code: code} = HTTPoison.get!(secret.secret_url)
    assert 200 == code
    assert File.read!(file_path) == body

    secret = create_secret("HEAD", bucket, resource_id, resource_name, "", "gcs")
    %HTTPoison.Response{status_code: code} = HTTPoison.head!(secret.secret_url)
    assert 200 == code
  end

  test "signes url's with resource name (swift; no content-type)" do
    bucket = "declarations-dev"
    resource_id = "uuid"
    resource_name = "test.txt"

    secret = create_secret("PUT", bucket, resource_id, resource_name, "", "swift")

    assert %Secret{
      action: "PUT",
      bucket: ^bucket,
      expires_at: _,
      inserted_at: _,
      resource_id: ^resource_id,
      resource_name: resource_name,
      content_type: "",
      secret_url: secret_url
    } = secret

    assert "https://object.os.cloud.de-novo.biz" <> _ = secret_url

    file_path = "test/fixtures/secret.txt"

    headers = [
      {"Accept", "*/*"},
      {"Connection", "close"},
      {"Cache-Control", "no-cache"},
      {"Content-Type", ""},
    ]
    %HTTPoison.Response{body: _, status_code: code} = HTTPoison.put!(secret.secret_url, {:file, file_path}, headers)

    assert 201 == code

    secret = create_secret("GET", bucket, resource_id, resource_name, "", "swift")

    %HTTPoison.Response{body: body, status_code: code} = HTTPoison.get!(secret.secret_url)
    assert 200 == code
    assert File.read!(file_path) == body

    secret = create_secret("HEAD", bucket, resource_id, resource_name, "", "swift")
    %HTTPoison.Response{status_code: code} = HTTPoison.head!(secret.secret_url)
    assert 200 == code
  end

  test "signes url's without resource name" do
    secret = create_secret("PUT", "declarations-dev", "uuid", "gcs")

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

  test "swift link is generated correctly" do
    secret = %Secret{
      action: "PUT",
      expires_at: "2017-11-08 11:21:32Z",
      bucket: "test-container",
      resource_id: "B09E9D3E-EDE1-4A51-8FA7-46B4E8035795",
      resource_name: "some-file.png"
    }

    url_params = "?temp_url_sig=11090e588a184bad8eeb284cb493026c1caf40a6&temp_url_expires=1510140092"

    assert String.ends_with?(API.put_secret_url(secret, "swift").secret_url, url_params)
  end

  def create_secret(action, bucket, resource_id, backend) do
    {:ok, secret} = API.create_secret(%{
      action: action,
      bucket: bucket,
      resource_id: resource_id
    }, backend)
    secret
  end

  def create_secret(action, bucket, resource_id, resource_name, content_type, backend) do
    {:ok, secret} = API.create_secret(%{
      action: action,
      bucket: bucket,
      resource_id: resource_id,
      resource_name: resource_name,
      content_type: content_type
    }, backend)
    secret
  end
end
