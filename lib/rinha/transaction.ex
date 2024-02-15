defmodule Rinha.Transaction do
  use Ecto.Schema

  import Ecto.Changeset

  schema "transactions" do
    field(:amount, :integer)
    field(:date, :utc_datetime)
    field(:description, :string)
    field(:transaction_type, Ecto.Enum, values: [:c, :d])
    field(:account_id, :id)
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
