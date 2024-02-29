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
  def parse(transaction \\ %__MODULE__{}, %{"id" => customer_id} = attrs) do
    transaction
    |> cast(attrs, [:valor, :descricao, :tipo])
    |> put_change(:customer_id, customer_id)
    |> validate_required([:valor, :descricao, :tipo, :customer_id])
    |> apply_action(:parse)
  end

  def parse(%{"id" => customer_id} = attrs, limit) do
    %__MODULE__{}
    |> cast(attrs, [:valor, :descricao, :tipo])
    |> put_change(:customer_id, customer_id)
    |> validate_required([:valor, :descricao, :tipo, :customer_id])
    |> validate_transaction(limit)
    |> apply_action(:parse)
  end

  defp validate_transaction(%{valid?: false} = changeset, _limit), do: changeset

  defp validate_transaction(changeset, limit) do
    valor = get_change(changeset, :valor)
    tipo = get_change(changeset, :tipo)

    case tipo do
      :d ->
        if valor > limit do
          add_error(changeset, :valor, "cannot be greater than #{limit}")
        else
          changeset
        end
      _ ->
        changeset
    end
  end
end
