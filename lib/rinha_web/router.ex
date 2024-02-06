defmodule RinhaWeb.Router do
  use RinhaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RinhaWeb do
    pipe_through :api

    scope "/healthcheck", log: false do
      forward "/", Healthcheck
    end
  end
end
