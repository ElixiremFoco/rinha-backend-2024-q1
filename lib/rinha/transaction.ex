defmodule Rinha.Transaction do
  @moduledoc """
  Representa a estrutura interna de uma transação, que
  mapeia a tabela do banco de dados.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          amount: integer,
          date: DateTime.t(),
          description: String.t(),
          transaction_type: :c | :d,
          account_id: integer
        }

  schema "transactions" do
    field :amount, :integer
    field :date, :utc_datetime
    field :description, :string
    field :transaction_type, Ecto.Enum, values: [:c, :d]

    belongs_to :account, Rinha.Account
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:amount, :description, :transaction_type, :account_id])
    |> validate_required([:amount, :description, :transaction_type])
    |> foreign_key_constraint(:account_id)
  end

  def parse(trx \\ %__MODULE__{}, attrs) do
    trx
    |> changeset(attrs)
    |> apply_action(:parse)
  end
end
