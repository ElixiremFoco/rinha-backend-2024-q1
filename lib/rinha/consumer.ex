defmodule Rinha.Consumer do
  @moduledoc false

  use GenStage

  @producer {:global, Rinha.Producer}

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok)
  end

  @impl true
  def init(:ok) do
    {:consumer, :nao_importa, subscribe_to: [{@producer, max_demand: 350}]}
  end

  @impl true
  def handle_events(events, _from, state) do
    for event <- events do
      IO.inspect({self(), event})
    end

    {:noreply, [], state}
  end
end
