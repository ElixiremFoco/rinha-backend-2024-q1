defmodule Rinha.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field(:amount, :integer)
    field(:date, :utc_datetime)
    field(:description, :string)
    field(:transaction_type, Ecto.Enum, values: [:c, :d])
    field(:account_id, :id)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:amount, :description, :date, :transaction_type])
    |> validate_required([:amount, :description, :date, :transaction_type])
  end
end
