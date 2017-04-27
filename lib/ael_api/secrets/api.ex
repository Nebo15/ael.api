defmodule Ael.Secrets.API do
  @moduledoc """
  The boundary for the Secrets system.
  """
  import Ecto.Changeset, warn: false
  alias Ecto.Changeset
  alias Ael.Secrets.Secret

  @secrets_ttl Confex.get(:ael_api, :secrets_ttl) || raise ArgumentError, "Can not read SECRETS_TTL env."
  @known_buckets Confex.get(:ael_api, :known_buckets) || raise ArgumentError, "Can not read KNOWN_BUCKETS env."

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
          |> Map.put(:secret_url, "sksksksks")

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
