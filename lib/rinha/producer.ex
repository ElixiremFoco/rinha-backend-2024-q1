defmodule Rinha.Producer do
  @moduledoc false

  use GenStage

  @name {:global, __MODULE__}

  ## Public API

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: @name)
  end

  def enqueue(event) do
    GenStage.cast(@name, {:notify, event})
  end

  ## Callbacks

  @impl true
  def init(:ok) do
    {:producer, {:queue.new(), 0}, dispatcher: GenStage.BroadcastDispatcher}
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
end
