defmodule Ael.Secrets.API do
  @moduledoc """
  The boundary for the Secrets system.
  """
  import Ecto.Changeset, warn: false
  alias Ecto.Changeset
  alias Ael.API.Signature
  alias Ael.Secrets.Secret
  alias Ael.Secrets.Validator

  import Ael.Utils, only: [get_from_registry: 1]

  @secret_attrs ~w(action bucket resource_id resource_name content_type)a
  @required_secret_attrs ~w(action bucket resource_id)a
  @validator_attrs ~w(url)a
  @required_validator_attrs ~w(url)a
  @verbs ~w(PUT GET HEAD)

  @doc """
  Creates a secret.

  ## Examples

      iex> create_secret(%{field: value})
      {:ok, %Secret{}}

      iex> create_secret(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_secret(attrs \\ %{}, backend) do
    changeset = secret_changeset(%Secret{}, attrs)

    case changeset do
      %Changeset{valid?: false} = changeset ->
        {:error, changeset}
      %Changeset{valid?: true} = changeset ->
        secret =
          changeset
          |> apply_changes()
          |> put_timestamps()
          |> put_secret_url(backend)

        {:ok, secret}
    end
  end

  defp put_timestamps(%Secret{} = secret) do
    now = DateTime.utc_now()
    expires_at =
      now
      |> DateTime.to_unix()
      |> Kernel.+(get_from_registry(:secrets_ttl))
      |> DateTime.from_unix!()
      |> DateTime.to_iso8601()

    secret
    |> Map.put(:expires_at, expires_at)
    |> Map.put(:inserted_at, now)
  end

  def put_secret_url(%Secret{action: action, expires_at: expires_at, content_type: content_type} = secret, "gcs") do
    canonicalized_resource = get_canonicalized_resource(secret)
    expires_at = iso8601_to_unix(expires_at)
    signature =
      action
      |> string_to_sign(expires_at, content_type, canonicalized_resource, "gcs")
      |> base64_sign()

    secret
    |> Map.put(:secret_url, "https://storage.googleapis.com#{canonicalized_resource}" <>
                            "?GoogleAccessId=#{get_from_registry(:gcs_service_account_id)}" <>
                            "&Expires=#{expires_at}" <>
                            "&Signature=#{signature}")
  end

  def put_secret_url(%Secret{action: action, expires_at: expires_at} = secret, "swift") do
    canonicalized_resource = get_canonicalized_resource(secret)
    expires_at = iso8601_to_unix(expires_at)
    path = Enum.join(["/v1/", get_from_registry(:swift_tenant_id), canonicalized_resource])
    signature =
      action
      |> string_to_sign(expires_at, path, "swift")
      |> hmac_sign(get_from_registry(:swift_temp_url_key))
      |> String.downcase

    host = get_from_registry(:swift_endpoint)

    Map.put(secret, :secret_url, "#{host}#{path}?temp_url_sig=#{signature}&temp_url_expires=#{expires_at}")
  end

  def string_to_sign(action, expires_at, content_type, canonicalized_resource, "gcs") do
    Enum.join([action, "", content_type, expires_at, canonicalized_resource], "\n")
  end

  def string_to_sign(action, expires_at, path, "swift") do
    Enum.join([action, expires_at, path], "\n")
  end

  def base64_sign(plaintext) do
    plaintext
    |> :public_key.sign(:sha256, get_from_registry(:gcs_service_account_key))
    |> Base.encode64()
    |> URI.encode_www_form()
  end

  def hmac_sign(string, key) do
    :sha
    |> :crypto.hmac(key, string)
    |> Base.encode16()
  end

  def iso8601_to_unix(datetime) do
    {:ok, datetime, _} = DateTime.from_iso8601(datetime)
    DateTime.to_unix(datetime)
  end

  def validate_entity(params) do
    with %Ecto.Changeset{valid?: true} = changeset <- validation_changeset(%Validator{}, params),
         {:ok, %HTTPoison.Response{body: body}} <- get_signed_content(changeset),
         {:ok, %{"data" => %{"is_valid" => true, "content" => content}}} <- validate_signed_content(body)
    do
      {:ok, validate_rules(content, Changeset.apply_changes(changeset))}
    else
      # False in all other cases
      _ -> {:ok, false}
    end
  end

  defp get_canonicalized_resource(%Secret{bucket: bucket, resource_id: resource_id, resource_name: resource_name})
    when is_binary(resource_name) and resource_name != "" do
    "/#{bucket}/#{resource_id}/#{resource_name}"
  end

  defp get_canonicalized_resource(%Secret{bucket: bucket, resource_id: resource_id}) do
    "/#{bucket}/#{resource_id}"
  end

  defp secret_changeset(%Secret{} = secret, attrs) do
    secret
    |> cast(attrs, @secret_attrs)
    |> validate_required(@required_secret_attrs)
    |> validate_inclusion(:action, @verbs)
    |> validate_inclusion(:bucket, get_from_registry(:known_buckets))
  end

  defp validation_changeset(%Validator{} = validator, attrs) do
    validator
    |> cast(attrs, @validator_attrs)
    |> validate_required(@required_validator_attrs)
    |> cast_embed(:rules, required: true, with: &Validator.rule_changeset/2)
  end

  defp validate_rules(content, %Validator{rules: rules}) do
    Enum.all?(rules, fn rule ->
      case rule do
        %{"type" => "eq", "field" => field, "value" => value} ->
          to_string(get_in(content, field)) == to_string(value)
        _ ->
          true
      end
    end)
  end

  defp validate_signed_content(body) do
    Signature.decode_and_validate(Base.encode64(body), "base64")
  end

  defp get_signed_content(changeset) do
    changeset
    |> Changeset.get_change(:url)
    |> HTTPoison.get
  end
end
