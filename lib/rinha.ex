defmodule Rinha do
  @moduledoc """
  Porta de entrada da lógica do serviço. Fica responsável
  por gerenciar as contas, bem como seus saldos e suas respectivas
  transações.
  """

  import Ecto.Query

  alias Rinha.Customer
  alias Rinha.InputTransaction
  alias Rinha.Transaction
  alias Rinha.TransactionAdapter
  alias Rinha.TransactionValidator

  alias Rinha.Repo

  @doc """
  Busca um conta a partir de seu ID. Retorna uma tupla
  de `:ok` com a conta encontrada ou `:error` caso ela não exista.
  """
  @spec fetch_customer(integer) :: {:ok, Customer.t()} | {:error, :not_found}
  def fetch_customer(customer_id) do
    query = from a in Customer, where: a.id == ^customer_id

    if customer = Repo.one(query) do
      {:ok, customer}
    else
      {:error, :not_found}
    end
  end

  @spec increment_balance(integer, Transaction.t()) :: integer
  defp increment_balance(balance, %Transaction{type: :c, value: value}), do: balance + value
  defp increment_balance(balance, %Transaction{type: :d, value: value}), do: balance + -value

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
  def transact(%{"id" => customer_id} = payload) do
    Repo.transaction(fn ->
      with {:ok, customer} <- fetch_customer(customer_id),
           {:ok, external} <- InputTransaction.parse(payload),
           {:ok, internal} <- TransactionAdapter.to_internal(external, customer.id),
           :ok <- TransactionValidator.run(customer, internal) do
        Repo.insert!(internal)
        new_balance = increment_balance(customer.balance, internal)

        customer
        |> Customer.changeset(%{balance: new_balance})
        |> Repo.update!()
      else
        {:error, err} -> Repo.rollback(err)
      end
    end)
    |> then(fn
      {:ok, customer} ->
        {:ok, TransactionAdapter.to_response(customer)}

      {:error, reason} ->
        {:error, reason} |> IO.inspect()
    end)
  end

  @spec generate_statement(Customer.t(), limit: integer | nil) :: map
  def generate_statement(%Customer{} = customer, opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)
    issue_date = NaiveDateTime.utc_now()
    transactions = fetch_last_transactions(customer, limit: limit)
    TransactionAdapter.to_statement(customer, transactions, issue_date)
  end

  defp fetch_last_transactions(%Customer{} = customer, limit: limit) do
    import Ecto.Query, only: [from: 2]

    Repo.all(
      from t in Transaction,
        where: t.customer_id == ^customer.id,
        limit: ^limit,
        order_by: {:desc, t.created_at}
    )
  end
end
