defmodule Ael.Web.SecretView do
  @moduledoc false

  use Ael.Web, :view
  alias Ael.Web.SecretView

  def render("show.json", %{secret: secret}) do
    %{data: render_one(secret, SecretView, "secret.json")}
  end

  def render("secret.json", %{secret: secret}) do
    %{action: secret.action,
      bucket: secret.bucket,
      resource_id: secret.resource_id,
      resource_name: secret.resource_name,
      secret_url: secret.secret_url,
      expires_at: secret.expires_at,
      inserted_at: secret.inserted_at}
  end
end
