defmodule Rinha.TransactionAdapter do
  @moduledoc """
  Módulo responsável por converter a estrutura interna
  de uma transação para a estrutura externa que os clientes esperam.
  """

  alias Rinha.Account
  alias Rinha.Balance
  alias Rinha.InputTransaction
  alias Rinha.Transaction

  @spec to_internal(InputTransaction.t(), integer) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  def to_internal(%InputTransaction{} = input, account_id) do
    attrs = %{
      amount: input.valor,
      description: input.descricao,
      account_id: account_id,
      transaction_type: input.tipo
    }

    Transaction.parse(attrs)
  end

  @spec to_response(Account.t(), Balance.t()) :: map
  def to_response(%Account{} = account, %Balance{} = balance) do
    %{"limite" => account.limit_amount, "saldo" => balance.amount}
  end

  @spec to_external(Transaction.t()) :: map
  def to_external(%Transaction{} = trx) do
    %{
      "valor" => trx.amount,
      "tipo" => externalize_trx_type(trx),
      "descricao" => trx.description,
      "realizada_em" => trx.date
    }
  end

  defp externalize_trx_type(%Transaction{transaction_type: :c}), do: "c"
  defp externalize_trx_type(%Transaction{transaction_type: :d}), do: "d"

  @spec to_statement(Account.t(), Balance.t(), list(Transaction.t()), NaiveDateTime.t()) :: map
  def to_statement(%Account{} = acc, %Balance{} = balance, trxs, issue_date) do
    %{
      "saldo" => format_balance(acc, balance, issue_date),
      "ultimas_transacoes" => parse_transactions(trxs)
    }
  end

  defp format_balance(%Account{} = acc, %Balance{} = balance, issue_date) do
    %{
      "total" => balance.amount,
      "data_extrato" => issue_date,
      "limite" => acc.limit_amount
    }
  end

  defp parse_transactions(trxs) do
    trxs
    |> Enum.sort_by(& &1.date, {:desc, NaiveDateTime})
    |> Enum.map(&to_external/1)
  end
end
