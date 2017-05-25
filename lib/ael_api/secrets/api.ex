defmodule Ael.Secrets.API do
  @moduledoc """
  The boundary for the Secrets system.
  """
  import Ecto.Changeset, warn: false
  alias Ecto.Changeset
  alias Ael.Secrets.Secret

  @doc """
  Creates a secret.

  ## Examples

      iex> create_secret(%{field: value})
      {:ok, %Secret{}}

      iex> create_secret(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_secret(attrs \\ %{}) do
    changeset = secret_changeset(%Secret{}, attrs)

    case changeset do
      %Changeset{valid?: false} = changeset ->
        {:error, changeset}
      %Changeset{valid?: true} = changeset ->
        secret =
          changeset
          |> apply_changes()
          |> put_timestamps()
          |> put_secret_url()

        {:ok, secret}
    end
  end

  defp put_timestamps(%Secret{} = secret) do
    now = DateTime.utc_now()
    expires_at =
      now
      |> DateTime.to_unix()
      |> Kernel.+(get_gcs_signed_url_ttl())
      |> DateTime.from_unix!()
      |> DateTime.to_iso8601()

    secret
    |> Map.put(:expires_at, expires_at)
    |> Map.put(:inserted_at, now)
  end

  defp put_secret_url(%Secret{action: action, expires_at: expires_at} = secret) do
    canonicalized_resource = get_canonicalized_resource(secret)
    expires_at = iso8601_to_unix(expires_at)
    signature =
      action
      |> string_to_sign(expires_at, canonicalized_resource)
      |> base64_sign()

    secret
    |> Map.put(:secret_url, "https://storage.googleapis.com#{canonicalized_resource}" <>
                            "?GoogleAccessId=#{get_gcs_service_account_id()}" <>
                            "&Expires=#{expires_at}" <>
                            "&Signature=#{signature}")
  end

  def string_to_sign(action, expires_at, canonicalized_resource) do
    Enum.join([action, "", "", expires_at, canonicalized_resource], "\n")
  end

  def base64_sign(plaintext) do
    plaintext
    |> :public_key.sign(:sha256, get_gcs_service_account_key())
    |> Base.encode64()
    |> URI.encode_www_form()
  end

  def iso8601_to_unix(datetime) do
    {:ok, datetime, _} = DateTime.from_iso8601(datetime)
    DateTime.to_unix(datetime)
  end

  defp get_canonicalized_resource(%Secret{bucket: bucket, resource_id: resource_id, resource_name: resource_name})
    when is_binary(resource_name) and resource_name != "" do
    "/#{bucket}/#{resource_id}/#{resource_name}"
  end

  defp get_canonicalized_resource(%Secret{bucket: bucket, resource_id: resource_id}) do
    "/#{bucket}/#{resource_id}"
  end

  @attrs [:action, :bucket, :resource_id, :resource_name]
  @required_attrs [:action, :bucket, :resource_id]
  @verbs ["PUT", "GET", "HEAD"]

  defp secret_changeset(%Secret{} = secret, attrs) do
    secret
    |> cast(attrs, @attrs)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:action, @verbs)
    |> validate_inclusion(:bucket, get_gcs_allowed_buckets())
  end

  defp get_gcs_service_account_id do
    get_from_registry(:gcs_service_account_id)
  end

  defp get_gcs_service_account_key do
    get_from_registry(:gcs_service_account_key)
  end

  defp get_gcs_signed_url_ttl do
    get_from_registry(:gcs_service_secrets_ttl)
  end

  defp get_gcs_allowed_buckets do
    get_from_registry(:gcs_service_known_buckets)
  end

  defp get_from_registry(key) do
    [{_pid, val}] = Registry.lookup(Ael.Registry, key)
    val
  end
end
