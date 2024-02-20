defmodule RinhaWeb.TransactionController do
  use RinhaWeb, :controller

  action_fallback Rinha.FallbackController

  def transact(conn, payload) do
    :ok = Rinha.Producer.enqueue(payload)

    conn
    |> put_status(:ok)
    |> json("")
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
