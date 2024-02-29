defmodule Rinha.CustomerLimits do
  use Agent

  import Ecto.Query

  alias Rinha.Customer
  alias Rinha.Repo

  def start_link(_initial_value) do
    query = from a in Customer, select: %{id: a.id, limit: a.max_limit}

    result = Repo.all(query)

    Agent.start_link(fn -> result end, name: __MODULE__)
  end

  def get(id) do
    Agent.get(__MODULE__, fn list ->
      Enum.find(list, fn item ->
        id == item.id
      end)
      |> case do
        nil -> {:error, :not_found}
        item -> {:ok, item.limit}
      end
    end)
  end
end
