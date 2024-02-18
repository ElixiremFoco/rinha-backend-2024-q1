defmodule Rinha.Account do
  @moduledoc """
  Representação interna de uma conta, que mapeia com a tabela do banco de dados.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          limit_amount: integer,
          name: String.t(),
          balance: Rinha.Balance.t(),
          transactions: list(Rinha.Transaction.t())
        }

  schema "accounts" do
    field :limit_amount, :integer
    field :name, :string

    has_one :balance, Rinha.Balance
    has_many :transactions, Rinha.Transaction
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :limit_amount])
    |> validate_required([:name, :limit_amount])
  end
end
