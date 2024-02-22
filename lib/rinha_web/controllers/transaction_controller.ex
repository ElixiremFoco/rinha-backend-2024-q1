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

  def statement(conn, %{"id" => customer_id}) do
    with {:ok, customer} <- Rinha.fetch_customer(customer_id) do
      statement = Rinha.generate_statement(customer)

      conn
      |> put_status(200)
      |> json(statement)
    end
  end
end
