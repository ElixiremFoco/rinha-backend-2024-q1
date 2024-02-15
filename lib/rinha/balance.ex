defmodule Rinha.Balance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "balances" do
    field(:amount, :integer)

    belongs_to :account, Rinha.Account
  end

  @doc false
  def changeset(balance, attrs) do
    balance
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
  end
end
