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

  @spec to_external(Account.t(), Balance.t()) :: map
  def to_external(%Account{} = account, %Balance{} = balance) do
    %{"limite" => account.limit_amount, "saldo" => balance.amount}
  end
end
