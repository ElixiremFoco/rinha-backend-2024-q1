defmodule Rinha.CMD.Router do
  use Commanded.Commands.Router

  alias Rinha.CMD.BankAccount
  alias Rinha.InputTransaction

  identify(BankAccount, by: :customer_id)

  dispatch(InputTransaction, to: BankAccount)
end
