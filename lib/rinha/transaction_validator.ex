defmodule Rinha.TransactionValidator do
  @moduledoc """
  Módulo que valida se uma transação é válida e pode ser processada
  ou não com base no saldo atual de uma conta e seu respectivo
  limite de crédito.
  """

  alias Rinha.Account
  alias Rinha.Balance
  alias Rinha.Transaction

  # caso seja um crédito
  def run(_account, %Transaction{transaction_type: :c}), do: :ok

  # caso seja um débito
  def run(%Account{balance: %Balance{} = balance} = acc, %Transaction{} = trx) do
    if has_sufficient_limit?(acc, balance, trx) do
      :ok
    else
      {:error, :insuficcient_limit_amount}
    end
  end

  defp has_sufficient_limit?(acc, balance, trx) do
    not (balance.amount - trx.amount < -acc.limit_amount)
  end
end
