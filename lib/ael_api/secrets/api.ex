defmodule Ael.Secrets.API do
  @moduledoc """
  The boundary for the Secrets system.
  """
  import Ecto.Changeset, warn: false
  alias Ecto.Changeset
  alias Ael.Secrets.Secret

  @secrets_ttl Confex.get(:ael_api, :secrets_ttl) || raise ArgumentError, "Can not read SECRETS_TTL env."
  @known_buckets Confex.get(:ael_api, :known_buckets) || raise ArgumentError, "Can not read KNOWN_BUCKETS env."

  gcs_service_account =
    :ael_api
    |> Confex.get_map(:google_cloud_storage)
    |> Keyword.get(:service_account_key_path)
    |> File.read!()
    |> Poison.decode!()

  {:PrivateKeyInfo, :v1, {:PrivateKeyInfo_privateKeyAlgorithm, {1, 2, 840, 113549, 1, 1, 1}, {:asn1_OPENTYPE, <<5, 0>>}}, der, :asn1_NOVALUE} =
    gcs_service_account
    |> Map.get("private_key")
    # |> String.to_charlist()
    |> :public_key.pem_decode
    |> List.first
    |> :public_key.pem_entry_decode

  IO.inspect :public_key.der_decode(:'pkcs-1', der)

  @gcs_service_account_id Map.get(gcs_service_account, "client_id")
  @gcs_service_account_key #[e, n, d]

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
      |> Kernel.+(@secrets_ttl)
      |> DateTime.from_unix!()
      |> DateTime.to_iso8601()

    secret
    |> Map.put(:expires_at, expires_at)
    |> Map.put(:inserted_at, now)
  end

  defp put_secret_url(%Secret{} = secret) do
    %{action: action, expires_at: expires_at} = secret
    canonicalized_resource = get_canonicalized_resource(secret)

    string_to_sign = "#{action}\n#{expires_at}\n#{canonicalized_resource}"

    IO.inspect :crypto.private_encrypt(:rsa, string_to_sign, @gcs_service_account_key, :rsa_no_padding)

    signature =
      string_to_sign
      |> Base.encode64()
      |> URI.encode()

    secret
    |> Map.put(:secret_url, "https://storage.googleapis.com#{canonicalized_resource}" <>
                            "?GoogleAccessId=#{@gcs_service_account_id}&" <>
                            "Expires=#{expires_at}" <>
                            "&Signature=#{signature}")
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
    |> validate_inclusion(:bucket, @known_buckets)
  end
end
