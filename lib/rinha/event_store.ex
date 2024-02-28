defmodule Rinha.EventStore do
  use EventStore, otp_app: :rinha

  def init(config) do
    {:ok, config}
  end
end
