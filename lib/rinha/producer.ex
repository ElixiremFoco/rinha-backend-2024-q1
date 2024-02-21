defmodule Rinha.Producer do
  @moduledoc false

  use GenStage

  require Logger

  ## Public API

  def start_link(_opts) do
    case GenStage.start_link(__MODULE__, :ok, name: via_tuple(__MODULE__)) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, pid}} ->
        Logger.info("already started at #{inspect(pid)}, returning :ignore")
        :ignore
    end
  end

  def enqueue(event) do
    GenStage.cast(via_tuple(__MODULE__), {:notify, event})
  end

  ## Callbacks

  @impl true
  def init(:ok) do
    {:producer, {:queue.new(), 0}}
  end

  @impl true
  def handle_cast({:notify, event}, {queue, pending_demand}) do
    queue = :queue.in(event, queue)
    dispatch_events(queue, pending_demand, [])
  end

  @impl true
  def handle_demand(incoming_demand, {queue, pending_demand}) do
    dispatch_events(queue, incoming_demand + pending_demand, [])
  end

  defp dispatch_events(queue, 0, events) do
    {:noreply, Enum.reverse(events), {queue, 0}}
  end

  defp dispatch_events(queue, demand, events) do
    case :queue.out(queue) do
      {{:value, event}, queue} ->
        dispatch_events(queue, demand - 1, [event | events])

      {:empty, queue} ->
        {:noreply, Enum.reverse(events), {queue, demand}}
    end
  end

  def via_tuple(name), do: {:via, Horde.Registry, {Rinha.Registry, name}}
end
