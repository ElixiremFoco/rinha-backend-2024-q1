defmodule Rinha.TransactionAdapter do
  @moduledoc """
  Módulo responsável por converter a estrutura interna
  de uma transação para a estrutura externa que os clientes esperam.
  """

  alias Rinha.Customer
  alias Rinha.InputTransaction
  alias Rinha.Transaction

  @spec to_internal(InputTransaction.t(), integer) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def to_internal(%InputTransaction{} = input, customer_id) do
    attrs = %{
      value: input.valor,
      description: input.descricao,
      customer_id: customer_id,
      type: input.tipo
    }

    Transaction.parse(attrs)
  end

  @spec to_response(Customer.t()) :: map
  def to_response(%Customer{} = customer) do
    %{"limite" => customer.max_limit, "saldo" => customer.balance}
  end

  @spec to_external(Transaction.t()) :: map
  def to_external(%Transaction{} = trx) do
    %{
      "valor" => trx.value,
      "tipo" => externalize_trx_type(trx),
      "descricao" => trx.description,
      "realizada_em" => trx.created_at
    }
  end

  defp externalize_trx_type(%Transaction{type: :c}), do: "c"
  defp externalize_trx_type(%Transaction{type: :d}), do: "d"

  @spec to_statement(Customer.t(), list(Transaction.t()), NaiveDateTime.t()) :: map
  def to_statement(%Customer{} = customer, trxs, issue_date) do
    %{
      "saldo" => format_balance(customer, issue_date),
      "ultimas_transacoes" => parse_transactions(trxs)
    }
  end

  defp format_balance(%Customer{} = customer, issue_date) do
    %{
      "total" => customer.balance,
      "data_extrato" => issue_date,
      "limite" => customer.max_limit
    }
  end

  defp parse_transactions(trxs) do
    trxs
    |> Enum.sort_by(& &1.created_at, {:desc, NaiveDateTime})
    |> Enum.map(&to_external/1)
  end
end
