defmodule RinhaWeb.TransactionController do
  use RinhaWeb, :controller

  action_fallback Rinha.FallbackController

  def transact(conn, payload) do
    with {:ok, transaction} <- Rinha.transact(payload) do
      conn
      |> put_status(:ok)
      |> json(transaction)
    end
  end

  def statement(conn, %{"id" => account_id}) do
    with {:ok, account} <- Rinha.fetch_account(account_id) do
      statement = Rinha.generate_statement(account)

      conn
      |> put_status(200)
      |> json(statement)
    end
  end
end
