defmodule Rinha.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field(:limit_amount, :integer)
    field(:name, :string)

    has_one :balance, Rinha.Balance
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :limit_amount])
    |> validate_required([:name, :limit_amount])
  end
end
