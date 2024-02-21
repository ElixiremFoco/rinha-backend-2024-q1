defmodule Rinha.Consumer do
  @moduledoc false

  use GenStage

  require Logger

  def start_link(_opts) do
    case GenStage.start_link(__MODULE__, :ok) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info("already started at #{inspect(pid)}, returning :ignore")
        :ignore
    end
  end

  @impl true
  def init(:ok) do
    {:consumer, :nao_importa, subscribe_to: [{via_tuple(Rinha.Producer), max_demand: 350}]}
  end

  @impl true
  def handle_events(events, _from, state) do
    for event <- events do
      {:ok, _} = Rinha.transact(event)
      # IO.inspect({self(), event})
    end

    {:noreply, [], state}
  end

  def via_tuple(name), do: {:via, Horde.Registry, {Rinha.Registry, name}}
end
