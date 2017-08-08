defmodule Ael.API.Signature do
  @moduledoc """
  Signature validator and data mapper
  """

  use HTTPoison.Base
  use Confex, otp_app: :ael_api
  alias Ael.API.ResponseDecoder

  @conn_timeouts [connect_timeout: 30_000, recv_timeout: 30_000, timeout: 30_000]

  def process_url(url), do: config()[:endpoint] <> url

  def decode_and_validate(signed_content, signed_content_encoding) do
    params = %{
      "signed_content" => signed_content,
      "signed_content_encoding" => signed_content_encoding
    }

    "/digital_signatures"
    |> post!(Poison.encode!(params), [], @conn_timeouts)
    |> ResponseDecoder.check_response()
  end
end
