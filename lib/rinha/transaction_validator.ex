defmodule Rinha.TransactionValidator do
  alias Rinha.Account
  alias Rinha.Balance
  alias Rinha.Transaction

  # caso seja um crédito
  def run(_account, %Transaction{transaction_type: :c}), do: :ok

  # caso seja um débito
  def run(%Account{balance: %Balance{} = balance} = acc, %Transaction{} = trx) do
    if balance.amount - trx.amount < -acc.limit_amount do
      {:error, :insuficcient_limit_amount}
    else
      :ok
    end
  end
end
