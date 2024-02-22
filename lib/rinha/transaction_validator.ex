defmodule Rinha.TransactionValidator do
  @moduledoc """
  Módulo que valida se uma transação é válida e pode ser processada
  ou não com base no saldo atual de uma conta e seu respectivo
  limite de crédito.
  """

  alias Rinha.Customer
  alias Rinha.Transaction

  # caso seja um crédito
  def run(_customer, %Transaction{type: :c}), do: :ok

  # caso seja um débito
  def run(%Customer{} = customer, %Transaction{} = trx) do
    if has_sufficient_limit?(customer, trx) do
      :ok
    else
      {:error, :insuficcient_limit_amount}
    end
  end

  defp has_sufficient_limit?(customer, trx) do
    not (customer.balance - trx.value < -customer.max_limit)
  end
end
