defmodule Rinha.Balance do
  @moduledoc """
  Representa a estrutura interna de um saldo, que mapeia
  a tabela no banco de dados.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{amount: integer, account_id: integer}

  schema "balances" do
    field :amount, :integer

    belongs_to :account, Rinha.Account
  end

  @doc false
  def changeset(balance, attrs) do
    balance
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
  end
end
