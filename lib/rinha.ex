defmodule Rinha do
  @moduledoc """
  Porta de entrada da lógica do serviço. Fica responsável
  por gerenciar as contas, bem como seus saldos e suas respectivas
  transações.
  """

  alias Rinha.Account
  alias Rinha.Balance
  alias Rinha.InputTransaction
  alias Rinha.Transaction
  alias Rinha.TransactionAdapter
  alias Rinha.TransactionValidator

  alias Rinha.Repo

  @doc """
  Busca um conta a partir de seu ID. Retorna uma tupla
  de `:ok` com a conta encontrada ou `:error` caso ela não exista.
  """
  @spec fetch_account(integer) :: {:ok, Account.t()} | {:error, :not_found}
  def fetch_account(account_id) do
    import Ecto.Query
    query = from a in Account, where: a.id == ^account_id, preload: [:balance]

    if account = Repo.one(query) do
      {:ok, account}
    else
      {:error, :not_found}
    end
  end

  @doc """
  Atualiza o saldo de uma conta baseado na transação mais recente
  a ser processada. Se for uma transação de crédito, aumentos o saldo
  ou diminuimos caso seja uma transação de débito.

  Retorna uma tupla de `:ok` em caso de sucesso ou uma tupla de `:error`
  caso a atualização no banco falhe por algum motivo.
  """
  @spec update_balance(Balance.t(), Transaction.t()) ::
          {:ok, Balance.t()} | {:error, Ecto.Changeset.t()}
  def update_balance(%Balance{} = balance, %Transaction{} = trx) do
    operation = operation_by_trx_type(trx)

    balance
    |> Balance.changeset(%{amount: operation.(balance.amount, trx.amount)})
    |> Repo.update()
  end

  @spec operation_by_trx_type(Transaction.t()) :: (integer, integer -> integer)
  defp operation_by_trx_type(%Transaction{transaction_type: :credit}), do: &(&1 + &2)
  defp operation_by_trx_type(%Transaction{transaction_type: :debit}), do: &(&1 - &2)

  @doc """
  Função principal do sistema, reponsável por processar uma transação.
  Dentro de uma transaction do banco, busca a conta associada ao payload
  da transação a ser processada, converte a estrutura externa de uma transação
  para a estrutura interna e depois essa estrutura interna é validada.

  Caso tudo ocorra bem, inserimos essa transação sendo válida e atualizamos
  o saldo da conta, retornando a transação processada junto ao saldo atualizado.
  Com o resultado de sucesso, devolvemos a resposta estruturada confirmando
  que a transação foi processada corretamente, no seguinte formato:

  ```json
  %{"limite" => integer, "saldo" => integer}
  ```
  """
  @spec transact(map) :: {:ok, map} | {:error, :not_found | Ecto.Changeset.t()}
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
