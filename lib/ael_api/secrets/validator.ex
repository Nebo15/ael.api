defmodule Ael.Secrets.Validator do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @rule_attrs ~w(field type value)a
  @required_rule_attrs ~w(field type value)a

  @primary_key false
  embedded_schema do
    field :url, :string
    embeds_many :rules, Rule, primary_key: false do
      field :field, {:array, :string}
      field :type, :string
      field :value, :string
    end
  end

  def rule_changeset(%Ael.Secrets.Validator.Rule{} = rule, params) do
    rule
    |> cast(params, @rule_attrs)
    |> validate_required(@required_rule_attrs)
    |> validate_inclusion(:type, ~w(eq))
  end
end
