defmodule Rinha.InputTransaction do
  @moduledoc """
  Representa a estrutura de uma transação recebida pela API.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          valor: integer,
          descricao: String.t(),
          customer_id: integer,
          tipo: :c | :d
        }

  @primary_key false
  embedded_schema do
    field(:valor, :integer)
    field(:descricao, :string)
    field(:tipo, Ecto.Enum, values: [:c, :d])
    field(:customer_id, :integer)
  end

  @doc false
  def parse(transaction \\ %__MODULE__{}, attrs) do
    transaction
    |> cast(attrs, [:valor, :descricao, :tipo])
    |> validate_required([:valor, :descricao, :tipo])
    |> apply_action(:parse)
  end
end
