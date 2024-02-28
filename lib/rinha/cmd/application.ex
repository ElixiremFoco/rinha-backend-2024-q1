defmodule Rinha.CMD.Application do
  use Commanded.Application, otp_app: :rinha

  router(Rinha.CMD.Router)

  def init(config) do
    {:ok, config}
  end
end
