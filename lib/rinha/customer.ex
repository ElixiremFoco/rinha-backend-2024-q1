defmodule Rinha.Customer do
  @moduledoc """
  Representação interna de uma conta, que mapeia com a tabela do banco de dados.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          max_limit: integer,
          name: String.t(),
          balance: integer,
          transactions: list(Rinha.Transaction.t())
        }

  schema "customers" do
    field :max_limit, :integer
    field :name, :string
    field :balance, :integer, default: 0

    has_many :transactions, Rinha.Transaction
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:name, :max_limit, :balance])
    |> validate_required([:name, :max_limit, :balance])
  end
end
