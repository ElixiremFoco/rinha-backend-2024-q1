defmodule Rinha.TransactionAdapter do
  alias Rinha.Account
  alias Rinha.Balance
  alias Rinha.InputTransaction
  alias Rinha.Transaction

  @spec to_internal(struct, integer) :: struct
  def to_internal(%InputTransaction{} = input, account_id) do
    attrs = %{
      amount: input.valor,
      description: input.descricao,
      account_id: account_id,
      transaction_type: input.tipo
    }

    Transaction.parse(attrs)
  end

  def to_external(%Account{} = account, %Balance{} = balance) do
    %{"limite" => account.limit_amount, "saldo" => balance.amount}
  end
end
