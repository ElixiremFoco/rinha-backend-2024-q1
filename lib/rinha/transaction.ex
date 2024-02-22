defmodule Rinha.Transaction do
  @moduledoc """
  Representa a estrutura interna de uma transação, que
  mapeia a tabela do banco de dados.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          value: integer,
          created_at: DateTime.t(),
          description: String.t(),
          type: :c | :d,
          customer_id: integer
        }

  schema "transactions" do
    field :value, :integer
    field :created_at, :utc_datetime
    field :description, :string
    field :type, Ecto.Enum, values: [:c, :d]

    belongs_to :customer, Rinha.Customer
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:value, :description, :type, :customer_id])
    |> validate_required([:value, :description, :type])
    |> foreign_key_constraint(:customer_id)
  end

  def parse(trx \\ %__MODULE__{}, attrs) do
    trx
    |> changeset(attrs)
    |> apply_action(:parse)
  end
end
