defmodule RinhaWeb.Router do
  use RinhaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RinhaWeb do
    pipe_through :api

    scope "/clientes/:id" do
      post "/transacoes", TransactionController, :transact
      post "/extrato", TransactionController, :statement
    end

    scope "/healthcheck", log: false do
      forward "/", Healthcheck
    end
  end
end
