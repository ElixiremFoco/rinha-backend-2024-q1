defmodule Rinha.InputTransaction do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:valor, :integer)
    field(:descricao, :string)
    field(:tipo, Ecto.Enum, values: [:c, :d])
    field(:account_id, :id)
  end

  @doc false
  def parse(transaction \\ %__MODULE__{}, attrs) do
    transaction
    |> cast(attrs, [:valor, :descricao, :tipo])
    |> validate_required([:valor, :descricao, :tipo])
    |> apply_action(:parse)
  end
end
