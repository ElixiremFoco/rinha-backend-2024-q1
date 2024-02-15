defmodule Rinha do
  @moduledoc false

  alias Rinha.Account
  alias Rinha.Balance
  alias Rinha.InputTransaction
  alias Rinha.Transaction
  alias Rinha.TransactionAdapter
  alias Rinha.TransactionValidator

  alias Rinha.Repo

  def fetch_account(account_id) do
    import Ecto.Query
    query = from a in Account, where: a.id == ^account_id, preload: [:balance]

    if account = Repo.one(query) do
      {:ok, account}
    else
      {:error, :not_found}
    end
  end

  def update_balance(balance, %Transaction{transaction_type: :c} = trx) do
    balance
    |> Balance.changeset(%{amount: balance.amount + trx.amount})
    |> Repo.update()
  end

  def update_balance(balance, %Transaction{transaction_type: :d} = trx) do
    balance
    |> Balance.changeset(%{amount: balance.amount - trx.amount})
    |> Repo.update()
  end

  def transact(%{"id" => account_id} = payload) do
    Repo.transaction(fn ->
      with {:ok, account} <- fetch_account(account_id),
           {:ok, external} <- InputTransaction.parse(payload),
           {:ok, internal} <- TransactionAdapter.to_internal(external, account.id),
           :ok <- TransactionValidator.run(account, internal) do
        Repo.insert!(internal)
        {:ok, balance} = update_balance(account.balance, internal)
        {account, balance}
      else
        {:error, err} -> Repo.rollback(err)
      end
    end)
    |> then(fn
      {:ok, {account, balance}} ->
        {:ok, TransactionAdapter.to_external(account, balance)}

      {:error, reason} ->
        {:error, reason}
    end)
  end
end
